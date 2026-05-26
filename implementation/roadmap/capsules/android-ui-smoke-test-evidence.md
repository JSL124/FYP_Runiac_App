# android-ui-smoke-test-evidence

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Validation-only.

## Status

Status: Closed.

Completed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `docs(roadmap): record android smoke test evidence`.

Completion review:

- A6_REVIEW PASS.
- A8_OUTPUT_CHECKER PASS.
- `flutter devices` PASS.
- `flutter analyze --no-pub` PASS.
- `flutter test` PASS.
- `flutter run -d emulator-5554` PASS for launch evidence.
- `git diff --check` PASS.
- Governance CI PASS.

This capsule is closed. Do not add further work to it.

## Goal

Verify the current static Flutter UI baseline on Android emulator `emulator-5554` before any further product UI changes.

This capsule records evidence only. It does not authorize product code changes, source expansion, dependency changes, Firebase setup, or Phase 02 work.

## Allowed Scope

- Run the listed validation commands from the repository or Flutter app root as appropriate.
- Confirm Android emulator `emulator-5554` is detected.
- Launch the current static app on Android emulator `emulator-5554`.
- Visually confirm the app opens successfully.
- Visually confirm bottom navigation is visible with Home / Maps / Run / Leaderboard / You.
- Record command outputs and concise Android smoke-test evidence during closure.
- Manually stop `flutter run -d emulator-5554` after visual verification if needed.

## Forbidden Scope

- No product code edits.
- No Flutter source edits.
- No Flutter test edits.
- No `pubspec.yaml` or dependency changes.
- No Android native edits.
- No iOS or CocoaPods work.
- No Firebase setup, Firebase files, `firebase init`, or FlutterFire commands.
- No scaffold, build, init, deploy, or dependency-resolution commands.
- No GPS, tracking, authentication, Firestore, leaderboard, plan, profile, XP, streak, level, rank, premium-state, subscription privilege, expert-plan publication, or backend-owned logic.
- No Phase 02 selection.

## Exact Target Files

Routing files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/android-ui-smoke-test-evidence.md`

Expected product files modified: none.

## Required Tests

No new tests are created in this capsule.

Existing validation command:

```bash
flutter test
```

## Required Validation

Run:

```bash
git status --short
flutter devices
flutter analyze --no-pub
flutter test
flutter run -d emulator-5554
./tools/governance-ci/run-all-checks.sh
git diff --check
git status --short
```

Manual evidence note:

- `flutter run -d emulator-5554` may require manual stop after visual verification.

## Required Evidence

Record during closure:

- `git status --short` output before validation.
- `flutter devices` output showing Android emulator `emulator-5554`.
- `flutter analyze --no-pub` result.
- `flutter test` result.
- `flutter run -d emulator-5554` launch evidence.
- Visual confirmation that the app launches successfully.
- Visual confirmation that bottom navigation shows Home / Maps / Run / Leaderboard / You.
- Confirmation that no runtime crash was observed during the smoke test.
- `./tools/governance-ci/run-all-checks.sh` result.
- `git diff --check` result.
- Final `git status --short` output.

## Evidence Recorded

Command evidence:

- Initial `git status --short`: no output.
- Initial `git status -sb`: `## main...origin/main`.
- `git log --oneline -5` showed latest commit `f9cf8e7 docs(roadmap): route android smoke evidence capsule`.
- Source label inspection found current labels `Home`, `Maps`, `Run`, `Leaderboard`, and `You` in `implementation/mobile/runiac_app/lib/app.dart` and widget-test assertions.
- Source label inspection found no old `Explore` label and no old bottom-navigation `Plan` label. The lowercase placeholder text `Your plan will appear here` remains non-navigation copy.
- `flutter devices` detected `sdk gphone16k arm64 (mobile) • emulator-5554 • android-arm64 • Android 17 (API 37) (emulator)`.
- `flutter analyze --no-pub`: `No issues found!`.
- `flutter test`: `All tests passed!`.
- `flutter run -d emulator-5554`: built, installed, synced files, exposed VM service, and showed no runtime crash in console output during smoke observation.
- Temporary screenshot captured outside the repository at `/private/tmp/runiac-android-smoke.png` for visual inspection. The screenshot is not committed.
- Visual observation: app launched successfully on `emulator-5554`; bottom navigation was visible with `Home / Maps / Run / Leaderboard / You`; old `Plan / Explore` bottom-navigation labels were not visible.
- Visual observation: app remained static UI only; no Firebase, GPS, authentication, Firestore, or backend behavior was observed.
- Stop method: direct `q` input was unavailable because the tool session stdin was closed; the Flutter CLI process was stopped with `kill 90876`, after which the run session reported `Lost connection to device`.
- Post-run `git status --short`: no output.

No product code was modified. No Flutter source, Flutter test, `pubspec.yaml`, Android, iOS, Firebase, dependency, build config, GPS, authentication, Firestore, leaderboard, XP, streak, level, rank, premium-state, or backend-owned logic changes were made.

## Rollback Conditions

Stop and do not close the capsule if:

- Android emulator `emulator-5554` is not detected.
- The app does not launch.
- A runtime crash is observed during smoke testing.
- Bottom navigation labels are not visible as Home / Maps / Run / Leaderboard / You.
- Product files are modified.
- Firebase, native, dependency, build, init, deploy, GPS, authentication, Firestore, leaderboard, XP, streak, level, rank, premium-state, or backend-owned logic appears.

## Exit Criteria

- [x] Android emulator `emulator-5554` detected.
- [x] App launches successfully on Android emulator.
- [x] Bottom navigation visible with Home / Maps / Run / Leaderboard / You.
- [x] No runtime crash observed during smoke test.
- [x] Required command outputs recorded.
- [x] No product files modified.
- [x] Final git status reviewed.
- [x] Snapshot updated if state changed.
- [x] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
