# flutter-source-structure-refactor

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter source-structure refactor capsule.

## Status

Status: Ready for commit.

Routed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `chore(mobile): split static Flutter source structure`.

Completion review:

- A0_ORCH PASS.
- A9_TRACE PASS.
- A10_FLUTTER_IMPL PASS.
- A6_REVIEW PASS.
- A12_QA_TEST PASS.
- A8_OUTPUT_CHECKER PASS.
- `flutter analyze --no-pub` PASS.
- `flutter test` PASS.
- `git diff --check` PASS.
- Governance CI PASS.
- Android smoke evidence PASS on `emulator-5554`.

This capsule is ready for commit. It is not staged, committed, or pushed.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Refactor the static Flutter mobile source from a monolithic `app.dart` into a behavior-preserving feature-first-lite structure before additional UI capsules increase maintenance risk.

## Allowed Scope

- Keep `RuniacApp` and `MaterialApp` wiring in `implementation/mobile/runiac_app/lib/app.dart`.
- Move Runiac colors and theme construction under `lib/core/theme/`.
- Move shared visual primitives under `lib/core/widgets/`.
- Move shell navigation under `lib/features/shell/`.
- Move currently implemented Home, Maps, Run, Leaderboard, and You UI into their feature presentation folders.
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Preserve visible static UI copy and behavior.
- Add a concise mobile source-structure guardrail to `implementation/mobile/AGENTS.md`.
- Update `CURRENT.md`, `snapshots/latest.md`, and this capsule with confirmed state.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Phase 02 selection.
- No Firebase, Auth, Firestore, Cloud Functions, or backend work.
- No GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, timer, distance, pace, duration, heart-rate, cadence, or activity submission logic.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription, premium entitlement, or backend-owned state changes.
- No fake route metrics, fake run metrics, fake AI advice, fake premium entitlement, or fake backend-owned values.
- No dependency changes.
- No native Android/iOS changes.
- No GitHub Actions workflow changes.
- No domain, data, repository, service, or viewmodel folders.
- No empty Plan feature folder or Plan navigation.
- No unrelated UI redesign.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/core/theme/runiac_colors.dart`
- `implementation/mobile/runiac_app/lib/core/theme/runiac_theme.dart`
- `implementation/mobile/runiac_app/lib/core/widgets/*.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/**/*.dart`
- `implementation/mobile/runiac_app/lib/features/maps/presentation/**/*.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/**/*.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/AGENTS.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/flutter-source-structure-refactor.md`
- `tools/governance-ci/check-diff-hygiene.sh`

## Evidence

- Initial `git status --short`: no output.
- A0_ORCH finding: implementation-approved mode applies to this explicitly requested structural refactor; the working tree was clean; the Maps capsule is recorded as ready for commit but its source state is already tracked, so this refactor can safely preserve it as the next routed capsule.
- A9_TRACE finding: the change is structural only and preserves current Home, Maps, Run, Leaderboard, and You behavior; bottom navigation remains Home / Maps / Run / Leaderboard / You; Plan remains a future independent feature reachable from You and is not added as a bottom-navigation tab.
- A10_FLUTTER_IMPL summary: split `app.dart` into a thin app composition file, core theme/widgets, shell navigation, and currently implemented feature presentation files without adding domain/data/repository/service/viewmodel layers.
- A6_REVIEW finding: no visible copy, backend-owned value, Firebase/Auth/Firestore/GPS/backend, dependency, native platform, Plan navigation, or speculative Plan implementation change was introduced.
- A12_QA_TEST finding: required validation passed, including Android smoke on `emulator-5554`.

## Required Validation

- `git status --short` before changes.
- `flutter analyze --no-pub`.
- `flutter test`.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- Android smoke evidence on `emulator-5554` if available.
- `git status --short` after validation.

## Exit Criteria

- [x] Source split completed.
- [x] No product behavior changes introduced.
- [x] No forbidden files or scopes touched.
- [x] Required validation completed.
- [x] Capsule, CURRENT.md, and snapshot updated.
- [x] Ready for commit only; not staged, committed, or pushed.
