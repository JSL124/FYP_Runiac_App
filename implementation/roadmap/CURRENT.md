# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md` (closed)
- Current active capsule: None selected
- Most recent completed capsule: `implementation/roadmap/capsules/artifact-inventory-schema-persistence.md`
- Current status: Phase 01 governance CI closed; Artifact Inventory Schema persistence completed; repository remains pre-scaffold
- Current state: Post-schema-persistence governance state; next work requires explicit routing
- Current active milestone: None selected

## Required Reading Order

1. `implementation/roadmap/CURRENT.md`
2. No active phase document is selected until future routing explicitly selects one.
3. Relevant ADRs listed below
4. `implementation/roadmap/snapshots/latest.md`

Do not load future phase documents unless explicitly requested.

## Relevant ADRs

- `implementation/roadmap/decisions/ADR-001-tier-gate-system.md`
- `implementation/roadmap/decisions/ADR-002-emulator-first.md`

## Allowed Work

- Maintain roadmap/context governance files under `implementation/roadmap/`.
- Maintain completed governance capsule status under `implementation/roadmap/capsules/` when explicitly routed.
- Maintain root `AGENTS.md` roadmap context protocol when required.
- Update `snapshots/latest.md` from confirmed repository state only.
- Update CURRENT.md immediately when active phase, active capsule, gate status, or forbidden scope changes.

## Forbidden Work

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands.
- Do not create production implementation code.
- Do not modify existing implementation logic.
- Do not modify `docs/submissions/`, `PRD.md`, or frozen submitted PDD snapshots.
- Do not load `roadmap-stretch.md`, archived snapshots, or future phase docs unless explicitly requested.

## Next Gate

Select the next work item explicitly before any further governance or implementation task.

Run A6_REVIEW and A8_OUTPUT_CHECKER on any proposed next-phase routing.

Artifact Inventory Schema persistence is complete:

- Routing commit: `ce8a2d9 docs(roadmap): route artifact inventory schema persistence capsule`
- Completion commit: `7aaacf1 docs(meta): add artifact inventory schema`
- Created document: `docs/meta/ARTIFACT_INVENTORY_SCHEMA.md`

No active implementation capsule should be inferred from this completed work.

This post-completion state does not approve Phase 02 implementation, Flutter scaffold execution, Firebase setup, dependency installation, build, init, deploy, tests, source changes, or production implementation.
