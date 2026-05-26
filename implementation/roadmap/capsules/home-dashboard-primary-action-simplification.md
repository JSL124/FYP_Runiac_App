# home-dashboard-primary-action-simplification

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only Home dashboard polish capsule.

## Status

Status: Selected for implementation; implementation not started.

Routed on: 2026-05-27 Asia/Singapore.

Completion evidence commit target: `fix(mobile): simplify home dashboard primary action`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Make the Home dashboard primary beginner action clearer by giving Quick Start, or an equivalent static primary action, stronger visual priority while reducing competition from secondary inert calls to action.

## Allowed Scope

- Static frontend-only Home dashboard polish.
- Make Quick Start, or an equivalent primary action, visually dominant.
- Soften, reduce, or reposition secondary Home CTAs that compete with the primary action.
- Preserve the existing static Home dashboard section set unless a minor ordering or emphasis adjustment is needed for first-screen clarity.
- Preserve beginner-focused, supportive, non-shaming copy.
- Preserve mobile-first layout and current bottom navigation Home / Maps / Run / Leaderboard / You.
- Keep all Home actions static/inert unless a later capsule explicitly approves behavior.
- Add or update widget coverage only for the Home static copy, primary action presence, shell visibility, and non-backend boundary.
- Update `CURRENT.md`, `snapshots/latest.md`, and this capsule with confirmed state.
- Update Governance CI exact allowlist only for this capsule path if required.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/widgets/home_header.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/widgets/today_plan_card.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/widgets/weekly_plan_card.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/widgets/last_run_card.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`

## Forbidden Scope

- No Phase 02 selection.
- No Firebase, Auth, Firestore, Cloud Functions, or backend work.
- No GPS/location permission, current location state, or location behavior.
- No real run tracking, timers, distance, pace, duration, heart-rate, cadence, calories, or activity submission.
- No real plan generation, recommendation logic, or route generation.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, premium entitlement, or expert plan publication state computation or mutation.
- No backend-like data behavior, fake backend-owned values, fake run metrics, fake plan data, fake route data, fake premium entitlement, or fake AI advice.
- No dependency changes.
- No native Android/iOS changes.
- No scaffold, build, init, deploy, Firebase setup, or `flutterfire configure` commands.
- No unrelated Maps, Run, Leaderboard, You, shell, backend, governance workflow, or PDD changes.

## Done When

- Quick Start, or an equivalent primary action, is visually dominant on the Home dashboard.
- Secondary CTAs are softened, reduced, or repositioned so they do not compete with the primary beginner action.
- Home remains static, beginner-friendly, supportive, and non-shaming.
- No backend-owned boundary is touched.
- No Flutter source or test files outside the allowed list are changed.
- `flutter analyze --no-pub` passes.
- `flutter test` passes.
- `git diff --check` passes.
- `./tools/governance-ci/run-all-checks.sh` passes.

## Required Validation

- `git status --short` before changes.
- `flutter analyze --no-pub`.
- `flutter test`.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- `git status --short` after validation.

## Current Routing Evidence

- Home dashboard inspect-only pass found that the current static Home screen is welcoming but information-heavy for a beginner first screen.
- Inspect-only pass found that Quick Start is not visually dominant enough because it competes with secondary inert CTAs.
- A9_TRACE routing finding: this capsule is static frontend-only Home polish and does not introduce Firebase, Auth, Firestore, Cloud Functions, GPS/location, real run tracking, real plan generation, backend-like data behavior, premium/subscription logic, or backend-owned value mutation.
- A6_REVIEW routing finding: the capsule is small and deterministic because it targets first-screen Home action hierarchy only.
- A12_QA_TEST routing finding: future implementation must run Flutter analyze, Flutter widget tests, diff whitespace check, and local Governance CI before Ready for commit.

## Exit Criteria

- [ ] Home primary action hierarchy is simplified.
- [ ] Secondary CTAs no longer compete with the primary beginner action.
- [ ] Static frontend-only behavior preserved.
- [ ] No forbidden files or scopes touched.
- [ ] Required validation completed.
- [ ] Capsule, CURRENT.md, and snapshot updated with confirmed implementation state.
- [ ] Ready for commit only unless explicit commit approval is granted.
