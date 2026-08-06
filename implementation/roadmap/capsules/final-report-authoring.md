# Final Report Authoring

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as documentation-only
work. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-06 Asia/Singapore to restore Governance CI, which rejected `docs/final-report/**`
as an unrecognised path. The deliverable itself was already in progress and untracked; this routing
records it and re-opens the gate. Same situation and same remedy as
`user-manual-screenshots.md`, which was routed after `docs/user-manual/**` failed the same check.

## Goal

Recognise `docs/final-report/` as a routed documentation deliverable so that `check-diff-hygiene`
stops reporting its 33 files as unrelated modified paths.

## Background — why CI failed

`check-diff-hygiene` walks `git status --short` and rejects any path that no active capsule claims.
Nothing about the report is wrong; it simply had no routing anchor, so all 33 files were reported
twice each (once by the checker directly, once by `backend_functions_scope_test.sh`, which re-runs
it), for 66 findings and two FAILs. Every other check passed, and no path outside
`docs/final-report/` was implicated.

The deliverable is the CSCI321 Final Project Document for group FYP-26-S2-38: chapters 1-10,
annexes F and G, PlantUML sources with rendered PNGs, a `build-docx.js` assembly script, and the
draft `.docx`/`.xlsx` outputs. Its governing rule, recorded in `00-CHAPTER-PLAN.md`, is that the
report describes the application as actually built, with any divergence from the four prior project
documents recorded in the drift registers rather than smoothed over — which is consistent with
`judge from the current app, not the PDD` and needs no reconciliation with `docs/submissions/`.

## Allowed Scope

- Authoring and revising files under `docs/final-report/`, including its diagrams and generated
  document outputs.
- This capsule document, the `implementation/roadmap/CURRENT.md` routing anchor, and the
  `check-diff-hygiene.sh` predicate pair.

## Forbidden Scope

- No `docs/submissions/` edit. The submitted snapshots stay frozen; where the report and a
  submitted document disagree, the divergence is recorded in the drift registers.
- No Flutter, Firebase, Cloud Functions, rules, index, or test source change. The report reads the
  implementation; it never edits it.
- No production service, deploy, or secret action.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.

## Note on `build-docx.js`

`docs/AGENTS.md` forbids production source code under `docs/`. `build-docx.js` is a documentation
assembly script — it reads the chapter Markdown in this folder and emits the `.docx`, is not
imported by the app, the Functions, or the website, and ships in no build. It is classified as part
of the deliverable rather than as production source. Recorded here explicitly so the classification
is on the record rather than silently assumed.

## Exact Target Files

- `implementation/roadmap/capsules/final-report-authoring.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `docs/final-report/**` (the deliverable, authored outside this capsule's scaffolding change)

## Required Validation

- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- `CURRENT.md` anchors: 48 `- Newly routed` before this capsule's line is appended, 49 after;
  exactly 1 `- Current active capsule` throughout.

## Evidence (2026-08-06)

**Before** — every finding, and both FAILs, from this one directory:

```
66 finding=Unrelated modified path is outside Governance CI scope: docs/final-report/...
 2 CHECK check-diff-hygiene FAIL
   FAIL tools/governance-ci/check-diff-hygiene.sh exit=1
   FAIL tests/governance/backend_functions_scope_test.sh exit=1
```

No finding named any path outside `docs/final-report/`; the other 14 checks passed.

**After** — all sixteen checks pass, zero findings:

```
All Governance CI checks passed.
$ ./tools/governance-ci/run-all-checks.sh 2>&1 | grep -c "finding="
0
```

## Note — the hosted job was failing for an unrelated reason

Local Governance CI and the hosted `governance-ci` job are not the same gate. While this capsule
was being routed, hosted run `31080194069` showed `governance-ci` PASS and `mobile-integration-tests`
PASS, with only `backend-emulator-tests` failing — on a feed entitlement test unrelated to the
report. That is fixed separately under `feed-entitlement-test-ambient-tier.md`; the two failures
share no cause and neither one masked the other.
