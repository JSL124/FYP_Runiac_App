# run-tab-static-placeholder

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI product-code-changing capsule.

## Status

Status: Closed.

Routed on: 2026-05-26 Asia/Singapore.

Completed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `feat(mobile): add static run tab placeholder`.

Completion review:

- A9_TRACE PASS.
- A5_WIRE PASS.
- A10_FLUTTER_IMPL PASS.
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

Implement a static Run tab placeholder that visually follows the provided RunLandingPage wireframe structure without starting GPS, map, route, timer, tracking, activity recording, or backend behavior.

## Allowed Scope

- Replace the current Run placeholder tab with a static RunLandingPage-style screen.
- Include a large map/route-looking visual placeholder area, static route line, and small marker/flag-style placeholder icons.
- Include a floating Today's Plan card with safe empty-state copy.
- Include static Setting, Start, and Switch Route controls.
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Preserve the Runiac palette:
  - Primary Blue `#2F50C7`
  - Accent Orange `#FC6818`
  - White `#FFFFFF`
  - Background `#F7F8FC`
  - Text Primary `#172033`
  - Text Secondary `#6B7280`
  - Border `#E6EAF2`
- Update `widget_test.dart` only if visible text expectations must change.
- Update roadmap and snapshot files for routing and closure.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS.
- No tracking.
- No real map integration.
- No timer logic.
- No distance calculation.
- No pace calculation.
- No heart-rate data.
- No cadence data.
- No calories.
- No activity recording.
- No activity submission.
- No run completion flow.
- No XP/streak/level/rank updates.
- No fake run result.
- No fake backend-owned values.
- No premium entitlement logic.
- No dependency changes.
- No native Android/iOS changes.
- No Phase 02 selection.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if visible text expectations must change
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/run-tab-static-placeholder.md`
- `tools/governance-ci/check-diff-hygiene.sh` only for exact allowlisting of this capsule file

## Required Tests

- Inspect whether `./tools/governance-ci/run-all-checks.sh` includes `flutter test`.
- If Governance CI does not include `flutter test`, run `flutter test` once after `flutter analyze --no-pub`.
- Do not run `flutter test` twice unless the first run fails and a fix is applied, or Governance CI behavior is unclear and the reason is recorded.

## Required Validation

- `flutter analyze --no-pub`
- `flutter test` once if not already covered by Governance CI
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- `git status --short`
- Android smoke evidence if `emulator-5554` is available

## Required Evidence

- Initial git state.
- A9_TRACE findings.
- A5_WIRE findings.
- A10_FLUTTER_IMPL implementation summary.
- A6_REVIEW findings.
- A12_QA_TEST factual validation evidence.
- A8_OUTPUT_CHECKER readiness findings.
- Android smoke evidence or factual reason it was not run.
- Final modified file list.

Evidence recorded:

- Initial `git status --short`: no output.
- Initial `git status -sb`: `## main...origin/main`.
- Initial `git log --oneline -5` latest entry: `39dd0f1 fix(mobile): stabilize home dashboard scrolling`.
- A9_TRACE finding: the change supports the Track part of the Runiac core loop only as a static Run entry surface; it does not implement tracking, activity recording, route data, sensor data, or backend submission.
- A5_WIRE finding: the Run tab resembles the provided RunLandingPage wireframe structurally with a large route/map-looking placeholder area, static route line, route marker/flag placeholders, a floating Today's Plan card, Setting control, central Start button, Switch Route control, and preserved bottom navigation.
- A5_WIRE finding: the copy is beginner-friendly and low-pressure: `Ready for an easy run?`, `Route details will appear after setup.`, `Recommended effort will appear here.`, and `Tracking setup will be enabled later.`
- A10_FLUTTER_IMPL summary: replaced the generic Run placeholder with `_RunTab`, `_RunMapPlaceholder`, static custom-painted map/route visuals, `_RunPlanCard`, `_RunControls`, and marker/flag visual placeholder widgets in `implementation/mobile/runiac_app/lib/app.dart`.
- No visible widget-test expectations changed; `widget_test.dart` was not modified.
- Governance CI exact allowlist was updated only for `implementation/roadmap/capsules/run-tab-static-placeholder.md`.
- Governance CI inspection: `./tools/governance-ci/run-all-checks.sh` does not run `flutter test`, so `flutter test` was run separately exactly once.
- `flutter analyze --no-pub`: `No issues found!`.
- `flutter test`: `All tests passed!`.
- `git diff --check`: no output.
- `./tools/governance-ci/run-all-checks.sh`: `All Governance CI checks passed.`
- `git status --short`: only approved files changed.
- `flutter devices` detected `sdk gphone16k arm64 (mobile) • emulator-5554 • android-arm64 • Android 17 (API 37) (emulator)`.
- `flutter run -d emulator-5554`: built, installed, synced files, exposed VM service, and showed no runtime crash in console output during smoke observation.
- Temporary screenshot captured outside the repository at `/private/tmp/runiac-run-placeholder-smoke.png`.
- Visual observation: Run tab showed a static map/route-looking placeholder only, static route line, marker/flag placeholders, Today's Plan card, Setting button, central Start button, Switch Route button, supportive static copy, and bottom navigation Home / Maps / Run / Leaderboard / You.
- Start button smoke tap produced no navigation change, no tracking transition, and no new console output.
- No fake GPS ready state, timer, distance, pace, heart rate, cadence, calories, activity result, route data, Firebase, Auth, Firestore, backend behavior, XP/streak/level/rank, leaderboard score, premium state, dependency changes, native Android/iOS changes, or Phase 02 selection was introduced.
- Stop method: `flutter run` was stopped with `q`, and the session reported `Application finished.`

## Rollback Conditions

Stop and do not close this capsule if implementation:

- Modifies files outside the allowed scope.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, native Android/iOS, dependency, backend, activity recording, timer, or real map behavior.
- Adds fake distance, pace, heart-rate, cadence, GPS readiness, route data, activity result, calories, XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription state, premium state, or any backend-owned value.
- Selects Phase 02.
- Fails required validation.

## Exit Criteria

- [x] Target files completed.
- [x] Required tests or validation completed.
- [x] Required evidence recorded.
- [x] Snapshot updated.
- [x] CURRENT.md active capsule returned to none selected after closure.
