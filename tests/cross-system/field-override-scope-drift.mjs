#!/usr/bin/env node
// field-override-scope-drift.mjs
//
// What this protects:
//   A `fieldOverrides` entry in firestore.indexes.json does NOT add to
//   Firestore's automatic single-field indexing for that field — it REPLACES
//   it. Declaring only
//
//     { "order": "ASCENDING", "queryScope": "COLLECTION_GROUP" }
//
//   therefore DELETES the COLLECTION-scoped ASC/DESC indexes Firestore would
//   otherwise maintain, and every collection-scoped query on that field starts
//   throwing FAILED_PRECONDITION. Nothing warns at deploy time; the indexes
//   simply stop existing once the override lands.
//
//   This has already shipped once. 297f890f (2026-08-06) added COLLECTION_GROUP
//   overrides so the account-deletion sweep could run its collection-group
//   queries. Deploying them on 2026-08-12 silently removed the collection-scope
//   index on comments.authorUid, which
//   FirebaseFeedPostMapper.mapReference depends on:
//
//     reference.collection('comments').where('authorUid', isEqualTo: viewerUid)
//
//   The Feed went blank for three days. It was expensive to diagnose because
//   FAILED_PRECONDITION is not PERMISSION_DENIED, so rules simulation, the
//   composite-index listing, and document validation all came back clean, and
//   the client swallowed the cause. Fixed in b32caac4 by restoring COLLECTION
//   ASC + DESC alongside the COLLECTION_GROUP entry.
//
//   account-deletion-index-drift.mjs is the mirror image of this check: it
//   verifies the COLLECTION_GROUP entries EXIST. Neither catches the other's
//   failure — that one passed throughout the Feed outage.
//
// Scope and known limitation:
//   Text-level matching. It finds `collection("<group>")` followed within a
//   short window by `.where("<field>"` or `.orderBy("<field>"`, across
//   implementation/mobile/runiac_app/lib (Dart) and functions/src
//   (TypeScript). It cannot resolve a collection reference held in a variable
//   across statements, nor a group or field name built at runtime. A miss here
//   is a false PASS, never a false FAIL, so an override still deserves a
//   manual look at the readers of that field.
//
// What to do when it fails:
//   Add the collection-scope entries back alongside the existing ones, which
//   restores what Firestore indexed automatically before the override:
//
//     { "collectionGroup": "<group>", "fieldPath": "<field>", "indexes": [
//       { "order": "ASCENDING",  "queryScope": "COLLECTION" },
//       { "order": "DESCENDING", "queryScope": "COLLECTION" },
//       { "order": "ASCENDING",  "queryScope": "COLLECTION_GROUP" } ] }
//
//   Then `firebase deploy --only firestore:indexes` and WAIT for the build.
//   A query returning zero rows is not proof the index is ready; check `state`
//   on GET .../collectionGroups/<group>/fields/<field> until it reads READY.
//   The client reports "That index is not ready yet" while it builds.
//
// Usage: node tests/cross-system/field-override-scope-drift.mjs
// Exit 0 = every overridden field with a collection-scope reader keeps a
//          COLLECTION-scoped index.
// Exit 1 = at least one reader would throw FAILED_PRECONDITION in production.

import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, relative, resolve } from "node:path";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
const INDEXES = join(repoRoot, "firestore.indexes.json");

// Where a collection-scoped read can legitimately live. Backend test code is
// excluded: the emulator does not enforce single-field indexes, so a test
// reader proves nothing about production.
const SOURCE_ROOTS = [
  { path: "implementation/mobile/runiac_app/lib", extensions: [".dart"] },
  { path: "functions/src", extensions: [".ts"] },
];

// How far apart the collection() call and the where()/orderBy() may sit and
// still be treated as one chain. Generous enough for a formatted multi-line
// builder, tight enough not to pair unrelated statements.
const CHAIN_WINDOW = 400;

function fail(message) {
  process.stdout.write(`FAIL field-override-scope-drift: ${message}\n`);
  process.exit(1);
}

if (!existsSync(INDEXES)) {
  fail("missing required file firestore.indexes.json");
}

let indexesDocument;
try {
  indexesDocument = JSON.parse(readFileSync(INDEXES, "utf8"));
} catch (error) {
  fail(`firestore.indexes.json is not valid JSON: ${error.message}`);
}

const overrides = indexesDocument.fieldOverrides ?? [];

// A zero match means the file's shape changed and this check silently stopped
// protecting anything — louder than a false pass.
if (overrides.length === 0) {
  fail(
    "found no fieldOverrides entries in firestore.indexes.json; either they " +
      "were removed or the shape changed and this check needs updating",
  );
}

function collectSourceFiles() {
  const files = [];
  for (const root of SOURCE_ROOTS) {
    const absolute = join(repoRoot, root.path);
    if (!existsSync(absolute)) {
      fail(`missing required source root ${root.path}`);
    }
    const stack = [absolute];
    while (stack.length > 0) {
      const current = stack.pop();
      for (const entry of readdirSync(current)) {
        const child = join(current, entry);
        if (statSync(child).isDirectory()) {
          stack.push(child);
        } else if (root.extensions.some((extension) => child.endsWith(extension))) {
          files.push(child);
        }
      }
    }
  }
  return files;
}

const sourceFiles = collectSourceFiles();
if (sourceFiles.length === 0) {
  fail("collected zero source files; the source roots moved");
}

const sources = sourceFiles.map((path) => ({
  path: relative(repoRoot, path),
  text: readFileSync(path, "utf8"),
}));

const escape = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

function readersOf(group, field) {
  const pattern = new RegExp(
    `collection\\(\\s*['"]${escape(group)}['"]\\s*\\)` +
      `[\\s\\S]{0,${CHAIN_WINDOW}}?` +
      `\\.(?:where|orderBy)\\(\\s*['"]${escape(field)}['"]`,
  );
  return sources.filter((source) => pattern.test(source.text)).map((source) => source.path);
}

const checked = [];
const violations = [];

for (const override of overrides) {
  const group = override.collectionGroup;
  const field = override.fieldPath;
  const scopes = (override.indexes ?? []).map((index) => index.queryScope);
  const hasCollectionScope = scopes.includes("COLLECTION");
  checked.push(`${group}.${field}`);

  if (hasCollectionScope) {
    continue;
  }

  const readers = readersOf(group, field);
  if (readers.length > 0) {
    violations.push({ group, field, scopes: [...new Set(scopes)], readers });
  }
}

if (violations.length > 0) {
  const detail = violations
    .map(
      (violation) =>
        `  ${violation.group}.${violation.field} declares only ` +
        `[${violation.scopes.join(", ")}], which removes the COLLECTION-scope index,\n` +
        `    but these query it at collection scope:\n` +
        violation.readers.map((reader) => `      ${reader}`).join("\n"),
    )
    .join("\n");
  fail(
    `${violations.length} fieldOverride(s) would break a collection-scoped query ` +
      `with FAILED_PRECONDITION:\n${detail}`,
  );
}

process.stdout.write(
  `PASS field-override-scope-drift: ${checked.length} fieldOverride(s) checked ` +
    `against ${sources.length} source files; no overridden field loses an index ` +
    "a collection-scoped reader depends on\n",
);
