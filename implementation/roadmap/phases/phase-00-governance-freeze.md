# Phase 00 - Governance Freeze

## Goal

Initialize the roadmap/context architecture and freeze the current pre-scaffold governance state without starting implementation.

## Scope

- Create the initial roadmap/context files.
- Preserve the current Phase 1 setup-gate state.
- Record a compressed operational snapshot from confirmed repository facts only.
- Append the root roadmap context protocol if it does not already exist.

## Allowed Files

- `AGENTS.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/roadmap-summary.md`
- `implementation/roadmap/roadmap-stretch.md`
- `implementation/roadmap/phases/phase-00-governance-freeze.md`
- `implementation/roadmap/phases/phase-01-governance-ci.md`
- `implementation/roadmap/decisions/ADR-001-tier-gate-system.md`
- `implementation/roadmap/decisions/ADR-002-emulator-first.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/capsule-template.md`

## Forbidden Actions

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands.
- Do not create production source/config files.
- Do not modify implementation logic, `PRD.md`, `docs/submissions/`, or frozen submitted PDD snapshots.
- Do not create placeholder future phase docs, capsule docs, or ADRs.

## Required Validation

- Confirm Phase 0 governance sources remain mutually consistent.
- Confirm `CURRENT.md` stays under 80 lines.
- Confirm `roadmap-stretch.md` contains the required not-for-current-implementation marker.
- Confirm `snapshots/latest.md` avoids unverified implementation claims.
- Confirm root `AGENTS.md` change is append-only and not duplicated.

## Required Evidence

- Worktree inspection output.
- Phase 0 drift status.
- Mechanical verification results.
- A6_REVIEW governance/context findings.
- A8_OUTPUT_CHECKER readiness verdict.

## Snapshot Update Requirement

Update `implementation/roadmap/snapshots/latest.md` before leaving this phase.

## CURRENT.md Update Requirement

Update `implementation/roadmap/CURRENT.md` immediately when the next phase becomes active.

## Exit Criteria

- [x] snapshots/latest.md updated
- [x] CURRENT.md updated to next phase
