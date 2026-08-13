# Presentation Scripts

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as documentation-only
work. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-13 Asia/Singapore to restore Governance CI, which rejected
`docs/presentation/RUNIAC_VIDEO_AND_DEMO_SCRIPTS.md` as an unrecognised path. The deliverable was
already written and untracked; this routing records it and re-opens the gate. Third instance of the
same situation and the same remedy as `final-report-authoring.md` and `user-manual-screenshots.md`,
both of which were routed after their own `docs/` directory failed this check.

## Goal

Recognise `docs/presentation/` as a routed documentation deliverable so that `check-diff-hygiene`
stops reporting it as an unrelated modified path.

## Background — why CI failed

`check-diff-hygiene` walks `git status --short` and rejects any path that no active capsule claims.
Nothing about the script is wrong; it simply had no routing anchor. Because
`backend_functions_scope_test.sh` re-runs the same checker, the single unrouted file produced two
findings and two FAILs, leaving the whole gate red for any change anywhere in the repository — which
is how it was found, while committing an unrelated feature-key removal.

The deliverable is the video and demo script set for the CSCI321 presentation: the recording running
order, the demo walkthrough, and a correction table that reconciles the pitch against what the
application actually does. That table is the reason the file belongs under governance rather than
outside it — it makes claims about delivered behaviour, and those claims drift exactly like the
report's do. It follows the same governing rule as the final report: describe the application as
actually built, and record divergence rather than smoothing it over.

## Allowed Scope

- `implementation/roadmap/capsules/presentation-scripts.md`
- `implementation/roadmap/CURRENT.md` (one appended `- Newly routed …` line)
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate pair only)
- `docs/presentation/**` (the deliverable, authored outside this capsule's scaffolding change)

## Forbidden Scope

- No `docs/submissions/` edit. The submitted snapshots stay frozen.
- No Flutter, Firebase, Cloud Functions, rules, index, or test source change.
- No production service, deploy, or secret action.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line. The anchors are
  append-only CI contracts; rewording one silently revokes a permission branch.

## Why a new capsule rather than extending `final-report-authoring`

`docs/presentation/` is a distinct deliverable with a distinct audience, and the final report
capsule's Allowed Scope is written as `docs/final-report/` specifically. Widening that capsule's
prefix would have granted it a directory its own scope statement excludes, so the established
one-deliverable-one-predicate-pair shape is kept instead.

## Required Validation

- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- `CURRENT.md` anchors: 51 `- Newly routed` before this capsule's line is appended, 52 after;
  exactly 1 `- Current active capsule` throughout.

## Evidence (2026-08-13)

**Before** — one unrouted file, reported twice, failing two checks:

```
finding=Unrelated modified path is outside Governance CI scope: docs/presentation/RUNIAC_VIDEO_AND_DEMO_SCRIPTS.md
CHECK check-diff-hygiene FAIL
FAIL tests/governance/backend_functions_scope_test.sh exit=1
Governance CI checks failed: 2
```

No finding named any path outside `docs/presentation/`; every other check passed.

**After** — every check passes, zero findings:

```
All Governance CI checks passed.
$ ./tools/governance-ci/run-all-checks.sh 2>&1 | grep -c "finding="
0
```

Anchor count verified after appending: 52 `- Newly routed`, 1 `- Current active capsule`.
