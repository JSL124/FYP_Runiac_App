# PDD Security Decisions and Limitations

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested PDD documentation capsule. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-07-31 Asia/Singapore. PDD_MODE, documentation only. Third in the repository
consolidation sequence, after the governance CI gates and the release criteria.

## Goal

Close the two topical gaps in the PDD suite that a keyword survey found, and record the system's
limitations in writing.

## Background — the gap is topical, not volume

`docs/pdd/` already holds twelve documents totalling roughly 3,650 lines, plus four rendered
diagrams with PlantUML sources. Adding more architecture prose would duplicate existing work.

A keyword survey across `docs/pdd/*.md` located the actual gaps:

| Topic | Documents mentioning it |
|---|---|
| `server-owned` | 8 — the concept is well covered |
| **App Check** | **0** |
| **limitation / future work** | **0** |

App Check is live on 8 of 61 exported functions and appears nowhere in the design documentation.
Limitations are not recorded anywhere at all. For an assessment deliverable, an unstated boundary
reads as an unnoticed one.

The complementary work — mapping each requirement to its implementing file and verifying test —
is in `implementation/traceability/requirements-map.md` Part II and is deliberately kept out of
`docs/pdd/`, because that file is implementation-preparation territory and PDD_MODE path
protection separates the two.

## Allowed Scope

- Create `docs/pdd/07-security-and-privacy-decisions.md`: identity and trust boundary, the
  two-tier field protection model, App Check posture stated honestly, GPS/PII redaction, the
  `subscriptionStatus` / `userRole` separation, the Premium parity claim and its evidentiary
  limit, verification surface, secrets, and a decision log with accepted costs.
- Create `docs/pdd/08-limitations-and-future-work.md`: verification, environment, process, and
  operational limitations, deliberate scope boundaries, and prioritised future work.
- Update this capsule document and `implementation/roadmap/CURRENT.md` routing.

## Forbidden Scope

- No edits to `docs/submissions/pdd/` — the frozen submitted assessment snapshot.
- No rewrite of the existing `docs/pdd/00`–`06` documents, `RUNIAC_PDD_ASSEMBLED_DRAFT.md`,
  diagrams, or wireframe assets.
- No implementation change of any kind. In particular, **App Check enforcement is documented as
  an open decision and not altered** — broad enforcement would reject already-shipped clients.
- No production service, deploy, secret, or credential action.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.
- No Phase 02 selection.

## Exact Target Files

- `implementation/roadmap/capsules/pdd-security-and-limitations.md`
- `implementation/roadmap/CURRENT.md`
- `docs/pdd/07-security-and-privacy-decisions.md`
- `docs/pdd/08-limitations-and-future-work.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routing predicate only, if required)

## Required Tests

Not applicable — documentation only. Correctness is established by having every factual claim
name the file that enforces it, so any claim can be checked against the tree.

## Required Validation

- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- `CURRENT.md` anchors: 41 `- Newly routed` before this capsule's line is appended, 42 after;
  exactly 1 `- Current active capsule` throughout.
- Terminology check: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert used
  consistently, per root `AGENTS.md`.
- A6_REVIEW then A8_OUTPUT_CHECKER.

## Required Evidence

- Every quoted rules construct and file path verified against `main` @ `6eb6efef`.
- The App Check coverage figure (8 of 61, 1 deliberately public) stated identically in the PDD
  document, `implementation/release/RELEASE_CHECKLIST.md`, and
  `implementation/traceability/requirements-map.md` Part II §15.

## Rollback Conditions

- Revert if any documented claim cannot be traced to a file in the tree.
- Revert if the work is found to require changing App Check, rules, or any source file.
- Stop and re-route if the submitted PDD snapshot would need to change.

## Exit Criteria

- [ ] Both documents created, each claim naming its enforcement point.
- [ ] App Check posture documented as an open decision, not silently resolved.
- [ ] Limitations recorded, including the Premium parity evidentiary limit.
- [ ] Governance CI PASS locally; hosted CI green after push.
