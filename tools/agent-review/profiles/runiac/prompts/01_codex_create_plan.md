# Codex Create Inspect-Only Plan

Use A0_ORCH as the workflow owner.

Create an inspect-only plan for the requested Runiac task. Do not modify, create, delete, stage, commit, run tests, run builds, run Flutter, run Firebase, run npm, deploy, or execute production-affecting commands.

Check consistency against:

- `AGENTS.md`
- `PRD.md`
- `docs/submissions/pdd/` as the official frozen submitted PDD baseline
- `docs/pdd/` as detailed internal working/reference material only
- current git state and existing repository scaffolding

The plan must preserve these Runiac constraints:

- Flutter owns UI, navigation, GPS tracking UI, local interaction, and client integration.
- Firebase Authentication owns identity.
- Cloud Firestore stores app data.
- Cloud Functions own trusted XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, validation, aggregation, entitlement, and expert-plan governance logic.
- Basic/Premium access uses `subscriptionStatus`.
- Platform Administrator and Medical Trainer/Expert access uses `userRole`.
- Medical Trainer/Expert cannot publish expert plans directly.
- Premium must not create XP, rank, leaderboard score, or competitive advantages.

Output using exactly these headings:

## Goal

## Repo Context Checked

## Review Scope

Include:

- Files expected to change
- Files Claude may need to read for review
- Files explicitly out of scope
- Risk tags:
  - touches XP/streak/level/rank/leaderboard: yes/no
  - touches Firebase ownership or Cloud Functions ownership: yes/no
  - touches roles/entitlements/premium fairness: yes/no
  - touches security rules: yes/no
  - touches PRD/PDD consistency: yes/no
  - touches production source code: yes/no
- Recommended review mode: lite or standard

Recommend lite only for low-risk documentation or workflow changes. Recommend standard for anything touching XP, streak, level, rank, leaderboard, roles, entitlements, Firebase ownership, Cloud Functions ownership, security rules, PRD/PDD consistency, or production source code.

## Proposed Plan

## Files Affected If Executed

## Files That Must Remain Untouched

## Risks

## Approval Gate
