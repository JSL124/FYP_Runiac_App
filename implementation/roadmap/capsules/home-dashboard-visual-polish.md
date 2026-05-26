# home-dashboard-visual-polish

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI product-code-changing capsule.

## Status

Status: Closed.

Completed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `feat(mobile): polish static home dashboard`.

Completion review:

- A9_TRACE PASS.
- A5_WIRE PASS.
- A6_REVIEW PASS.
- A12_QA_TEST PASS.
- A8_OUTPUT_CHECKER PASS.
- `flutter analyze --no-pub` PASS.
- `flutter test` PASS.
- `git diff --check` PASS.
- Governance CI PASS.
- Android smoke evidence PASS on `emulator-5554`.

This capsule is closed. Do not add further work to it.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Improve the static Home dashboard visual quality and beginner-friendly presentation without adding backend behavior or fake backend-owned values.

## Implemented Scope

- Improved Home dashboard spacing.
- Improved typography hierarchy.
- Improved card/button visual structure.
- Improved Start Run CTA presentation.
- Applied a minimal Runiac logo color baseline using Primary Blue `#2F50C7`, Accent Orange `#FC6818`, White `#FFFFFF`, Background `#F7F8FC`, Text Primary `#172033`, Text Secondary `#6B7280`, and Border `#E6EAF2`.
- Improved beginner-friendly guidance text.
- Improved static empty-state/supportive copy.
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Keep the app static UI only.

## Forbidden Scope Preserved

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS/tracking.
- No real run recording.
- No fake XP.
- No fake streak.
- No fake level.
- No fake rank.
- No fake leaderboard score.
- No fake premium state.
- No fake run history.
- No backend-owned values.
- No dependency changes.
- No native Android/iOS changes.

## Modified Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/home-dashboard-visual-polish.md`

`implementation/mobile/runiac_app/test/widget_test.dart` did not require changes because the existing navigation-label assertions remained valid.

## Validation Evidence

- `flutter analyze --no-pub`
- `flutter test`
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- `flutter devices`
- `flutter run -d emulator-5554`
- `flutter screenshot -d emulator-5554 -o /private/tmp/runiac-home-polish-smoke.png`

Evidence recorded:

- Initial `git status --short`: no output.
- Initial `git status -sb`: `## main...origin/main`.
- `flutter analyze --no-pub`: `No issues found!`.
- `flutter test`: `All tests passed!`.
- `git diff --check`: no output.
- `./tools/governance-ci/run-all-checks.sh`: `All Governance CI checks passed.`
- `flutter devices` detected `sdk gphone16k arm64 (mobile) • emulator-5554 • android-arm64 • Android 17 (API 37) (emulator)`.
- `flutter run -d emulator-5554`: built, installed, synced files, exposed VM service, and showed no runtime crash in console output during smoke observation.
- Temporary screenshot captured outside the repository at `/private/tmp/runiac-home-polish-smoke.png`; screenshot is not committed.
- Visual observation: polished Home dashboard appeared with the Runiac blue/orange/white palette, prominent blue `Start Run` CTA, small orange accents, white cards, supportive guidance card, and bottom navigation visible with Home / Maps / Run / Leaderboard / You.
- Stop method: direct `q` input was unavailable because the tool session stdin was closed; the Flutter CLI process was stopped with `kill 4239`, after which the run session reported `Lost connection to device`.

## A5_WIRE Responsibilities

- Confirm beginner-friendly UX.
- Confirm low cognitive load.
- Confirm supportive tone.
- Confirm CTA clarity.
- Confirm no metric overload.
- Confirm no shame/guilt/aggressive competition.
- Confirm visual polish stays aligned with wireframe intent.

## A10_FLUTTER_IMPL Responsibilities

- Implement approved Flutter UI/layout changes only.
- Preserve static UI-only behavior.
- Preserve the bottom navigation contract.
- Avoid dependencies.
- Avoid fake backend-owned values.

## A12_QA_TEST Responsibilities

- Run `flutter analyze --no-pub`.
- Run `flutter test`.
- Confirm widget test expectations.
- Recommend Android smoke evidence if the UI changed significantly.
- Record factual validation evidence.

## Done Criteria

- [x] Home visual polish implemented within approved scope.
- [x] Tests/analyze pass.
- [x] Governance CI passes.
- [x] No product-code scope drift.
- [x] No backend-owned values added.
- [x] Capsule closure recorded after implementation.

## Rollback Conditions

Stop and do not close the capsule if implementation:

- Modifies files outside the allowed implementation scope.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, native Android/iOS, dependency, or backend behavior.
- Adds fake XP, streak, level, rank, leaderboard score, premium state, run history, or any backend-owned value.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Fails required validation.
