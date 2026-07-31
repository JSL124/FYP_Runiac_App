#!/usr/bin/env bash
set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

# check-test-enumeration
#
# What this protects:
#   Both backend test suites are enumerated BY FILENAME inside npm scripts
#   rather than discovered by a glob over the test directory:
#     - functions/package.json      -> test, test:feed, test:moderation,
#                                      test:challenge, test:friends
#     - tests/firebase-rules/package.json -> test, test:feed
#   A test file that is added to the tree but not added to the matching script
#   is never executed, and nothing else in CI notices. The suite still reports
#   green, so the omission reads as "covered".
#
#   This is not hypothetical. See implementation/roadmap/capsules/
#   review-triage-notification-privacy-quota.md fix #8: friends.firestore.rules.test.mjs
#   had never run in CI because it was missing from the rules enumeration.
#
#   This check reconciles, in both directions:
#     ORPHAN - a test file on disk that no script runs.
#     GHOST  - a filename a script runs that is not on disk.
#
# Note on functions/: the scripts run compiled JS from lib/test/*.js, so each
# entry is mapped back to its functions/test/*.ts source before comparison.
#
# Support files (fixtures, helpers, emulator guards) are excluded structurally:
# only *.test.ts and *.test.mjs are collected, so nothing has to be hardcoded.
#
# What to do when it fails:
#   ORPHAN -> add the file to the correct npm script, or register it below as
#             intentionally standalone WITH a reason.
#   GHOST  -> remove the stale filename from the script, or restore the file.

# Tests that deliberately do not run in the enumerated suites.
# Format: "path|reason". A reason is mandatory - an entry without one is a
# failure, so this list cannot quietly become a dumping ground.
INTENTIONAL_STANDALONE=(
  # "tests/firebase-rules/example.test.mjs|needs a dedicated emulator project"
)

# Entries are passed as argv, not stdin: `node -` already consumes stdin to read
# the script body below, so a pipe here would be silently discarded.
node - "${INTENTIONAL_STANDALONE[@]+"${INTENTIONAL_STANDALONE[@]}"}" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

const findings = [];

const standalone = new Map();
const raw = process.argv.slice(2).map((a) => a.trim()).filter(Boolean);
for (const line of raw) {
  const [p, ...rest] = line.split("|");
  const reason = rest.join("|").trim();
  if (!reason) {
    findings.push(`Intentional-standalone entry has no reason: ${p}`);
    continue;
  }
  standalone.set(p.trim(), reason);
}

function readScripts(pkgPath) {
  try {
    return JSON.parse(fs.readFileSync(pkgPath, "utf8")).scripts || {};
  } catch (error) {
    findings.push(`Cannot read ${pkgPath}: ${error.message}`);
    return {};
  }
}

function walkTests(dir, suffix, prefix = "") {
  let out = [];
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const entry of entries) {
    if (entry.isDirectory()) {
      out = out.concat(walkTests(path.join(dir, entry.name), suffix, `${prefix}${entry.name}/`));
    } else if (entry.name.endsWith(suffix)) {
      out.push(prefix + entry.name);
    }
  }
  return out;
}

const globToRegExp = (glob) =>
  new RegExp(`^${glob.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*")}$`);

function reconcile({ label, dir, scripts, scriptKeys, extract, toSource, suffix }) {
  const patterns = new Set();
  for (const key of scriptKeys) {
    if (!(key in scripts)) {
      findings.push(`${label}: expected npm script "${key}" is missing`);
      continue;
    }
    for (const hit of scripts[key].match(extract) || []) patterns.add(toSource(hit));
  }
  if (patterns.size === 0) {
    findings.push(`${label}: no test files were extracted from ${scriptKeys.join(", ")}`);
    return { label, disk: 0, patterns: 0 };
  }

  const disk = walkTests(dir, suffix);
  const regexes = [...patterns].map((p) => [p, globToRegExp(p)]);

  for (const file of disk) {
    const rel = `${dir}/${file}`;
    if (standalone.has(rel)) continue;
    if (!regexes.some(([, re]) => re.test(file))) {
      findings.push(`${label}: ORPHAN - ${rel} is on disk but no npm script runs it`);
    }
  }
  for (const [pattern, re] of regexes) {
    if (!disk.some((file) => re.test(file))) {
      findings.push(`${label}: GHOST - "${pattern}" is enumerated but matches no file in ${dir}/`);
    }
  }
  return { label, disk: disk.length, patterns: patterns.size };
}

const summaries = [];

summaries.push(reconcile({
  label: "functions",
  dir: "functions/test",
  scripts: readScripts("functions/package.json"),
  scriptKeys: ["test", "test:feed", "test:moderation", "test:challenge", "test:friends"],
  extract: /lib\/test\/[A-Za-z0-9_.\-/]*\.js/g,
  toSource: (hit) => hit.replace(/^lib\/test\//, "").replace(/\.js$/, ".ts"),
  suffix: ".test.ts",
}));

summaries.push(reconcile({
  label: "firebase-rules",
  dir: "tests/firebase-rules",
  scripts: readScripts("tests/firebase-rules/package.json"),
  scriptKeys: ["test", "test:feed"],
  extract: /[A-Za-z0-9_.\-*]+\.test\.mjs/g,
  toSource: (hit) => hit,
  suffix: ".test.mjs",
}));

const scanned = "functions/package.json,tests/firebase-rules/package.json,functions/test,tests/firebase-rules";

if (findings.length === 0) {
  console.log("CHECK check-test-enumeration PASS");
  console.log(`scanned_paths=${scanned}`);
  for (const s of summaries) {
    console.log(`enumeration ${s.label}: ${s.disk} test files on disk, ${s.patterns} enumerated entries, fully reconciled`);
  }
  if (standalone.size > 0) {
    console.log(`intentional_standalone=${standalone.size}`);
    for (const [p, reason] of standalone) console.log(`  ${p}: ${reason}`);
  }
  console.log("message=Every enumerated suite exists and every test file on disk is executed by a script.");
  process.exit(0);
}

console.log("CHECK check-test-enumeration FAIL");
console.log(`scanned_paths=${scanned}`);
for (const finding of findings) console.log(`finding=${finding}`);
console.log("message=A test file is not wired into any npm script, or a script names a file that does not exist.");
console.log("next_step=Add the file to the correct npm script, remove the stale entry, or register an intentional-standalone exception with a reason.");
process.exit(1);
NODE
