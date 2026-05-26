# home-dashboard-reference-layout-alignment

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI layout-alignment capsule.

## Status

Status: Complete.

Routed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `fix(mobile): align home dashboard reference layout`.

Completed on: 2026-05-26 Asia/Singapore.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Align the existing static Home dashboard more closely with the provided Home Dashboard wireframe structure while preserving static-only Flutter UI boundaries and safe placeholder copy.

## Allowed Scope

- Refactor only the Home tab static layout in `implementation/mobile/runiac_app/lib/app.dart`.
- Use the wireframe as a structural reference only.
- Preserve the Home section order:
  - greeting/profile placeholder
  - Today's Plan card
  - Training Goal/preparation card
  - Runner Progress card
  - This Week's Plan card
  - Last Run card
  - Post-run Feedback card
  - Recommended Routes card
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Update `widget_test.dart` only if visible expectations must change.
- Update roadmap and snapshot files for routing and closure.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS.
- No tracking.
- No real map SDK or map integration.
- No route generation.
- No timer logic.
- No distance, duration, pace, heart-rate, cadence, calories, or route metrics.
- No activity recording.
- No activity submission.
- No run completion flow.
- No fake run result.
- No fake AI advice.
- No fake premium entitlement.
- No XP/streak/level/rank updates or fake displays.
- No fake leaderboard score.
- No backend-owned value mutation or display.
- No dependency changes.
- No native Android/iOS changes.
- No Phase 02 selection.
- No unrelated design overhaul.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if visible text expectations must change
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/home-dashboard-reference-layout-alignment.md`
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

## Rollback Conditions

Stop and do not close this capsule if implementation:

- Modifies files outside the allowed scope.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, native Android/iOS, dependency, backend, activity recording, timer, real map behavior, fake AI advice, or fake premium entitlement.
- Adds fake distance, duration, pace, heart-rate, cadence, GPS readiness, route metrics, activity result, calories, XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription state, premium state, or any backend-owned value.
- Selects Phase 02.
- Fails required validation.

## Exit Criteria

- [x] Target files completed.
  - Evidence: `implementation/mobile/runiac_app/lib/app.dart` adjusted the existing static Home dashboard layout only.
- [x] Required tests or validation completed.
  - Evidence: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- [x] Required evidence recorded.
  - Evidence: Android smoke on `emulator-5554` launched successfully with no runtime crash; screenshots captured outside the repository at `/private/tmp/runiac-home-reference-layout-top.png` and `/private/tmp/runiac-home-reference-layout.png`.
- [x] Snapshot updated.
- [x] CURRENT.md active capsule returned to none selected after closure.
