# Runiac Roadmap Summary

This file is strategic context only. Operational routing belongs in `CURRENT.md`, the active phase document, and any active capsule document.

## Track Overview

- Track A - Governance and readiness: context discipline, gate policy, minimal CI governance, and pre-scaffold approval hygiene.
- Track B - MVP implementation: Flutter/Firebase prototype work after explicit phase and tier approval.
- Track C - Stretch scope: future extensions only, isolated in `roadmap-stretch.md`.

## MVP vs Stretch

MVP work is limited to approved Runiac prototype scope and must preserve backend ownership of trusted fields such as XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP.

Stretch work is deferred and must not be planned or implemented during active MVP work unless explicitly instructed by the human operator.

## Validation-First Workflow

Runiac work proceeds through small governed phases, explicit gates, reviewable evidence, and compressed context snapshots. Tier classification controls how much approval is required before a change proceeds.

See ADR-001 for tier definitions.

## Context Discipline Rules

- `CURRENT.md` is the single mandatory operational entry point.
- `snapshots/latest.md` is the only active snapshot file.
- Archived snapshots, future phase documents, and stretch scope are not loaded by default.
- Strategic summaries must not override operational routing.
- ADRs preserve decisions without expanding active task context.

## CONTEXT POINTERS

- Active phase path: `implementation/roadmap/phases/phase-00-governance-freeze.md`
- Active snapshot path: `implementation/roadmap/snapshots/latest.md`
- Relevant ADR paths:
  - `implementation/roadmap/decisions/ADR-001-tier-gate-system.md`
  - `implementation/roadmap/decisions/ADR-002-emulator-first.md`
