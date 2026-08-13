# Running the test suites locally to complete Chapter 7

Chapter 7 reports only test results that were actually produced. Two tiers of the suite could not be executed in the documentation environment, and need to be run on your Mac. This file explains exactly what to run and where the output goes.

## Why this is needed

The documentation environment has no access to the Firebase Emulator Suite: the emulator JAR download is blocked by the sandbox network policy, and the offline VM that has the repository mounted has neither the JARs nor a network connection to fetch them. It also has no Flutter toolchain. Your development machine has all three, so the emulator-dependent and Flutter tests must run there.

What *was* executed for this report, in full, is the pure-logic tier of the Cloud Functions suite: 63 of 84 test files, 593 passing assertions, no genuine failures. Those numbers are already in Chapter 7 and do not need re-running.

## Tier 1 — Cloud Functions with the Firebase Emulator Suite

These 21 test files need Auth, Firestore, Functions and Storage emulators running:

`accountDeletion`, `challengeCallableSurface`, `challengeContribution`, `challengeLobby`, `challengeNotifications`, `challengePremiumLapse`, `challengeSettlement`, `completeCoolDown`, `completeRun`, `completeRunCallableSurface`, `feedEmulatorIntegration`, `feedEngagement`, `feedEngagementNotifications`, `feedEngagementPush`, `friendsCore`, `notificationDevices`, `notificationScheduledDispatch`, `profileAvatarEmulatorIntegration`, `reportAppError`, `runnerPublicProfileEmulatorIntegration`, `streakExpiry`.

They are covered by the five npm scripts already defined in `functions/package.json`. Run each and keep the output:

```bash
cd /Users/leejinseo/Desktop/FYP_Runiac/functions
mkdir -p ../test-evidence/reports

npm test               2>&1 | tee ../test-evidence/reports/functions-main.log
npm run test:feed      2>&1 | tee ../test-evidence/reports/functions-feed.log
npm run test:moderation 2>&1 | tee ../test-evidence/reports/functions-moderation.log
npm run test:challenge 2>&1 | tee ../test-evidence/reports/functions-challenge.log
npm run test:friends   2>&1 | tee ../test-evidence/reports/functions-friends.log
```

Note that `npm test` already chains `test:feed`, `test:moderation`, `test:challenge` and `test:friends` at the end, so running it alone is sufficient if it completes; the separate invocations are useful if one group fails and you want to re-run just that group.

The lines Chapter 7 needs from each log are the `# tests`, `# pass`, `# fail` and `# duration_ms` summary lines that `node --test` prints at the end of each file.

## Tier 2 — Flutter unit, widget and integration tests

291 Dart test files live under `implementation/mobile/runiac_app/test` and `implementation/mobile/runiac_app/integration_test`.

```bash
cd /Users/leejinseo/Desktop/FYP_Runiac/implementation/mobile/runiac_app
flutter test --reporter expanded 2>&1 | tee ../../../test-evidence/reports/flutter-unit-widget.log
```

For the integration tests, which need a booted simulator or a connected device:

```bash
flutter test integration_test --reporter expanded 2>&1 | tee ../../../test-evidence/reports/flutter-integration.log
```

If the run needs the Mapbox token, add `--dart-define=MAPBOX_PUBLIC_ACCESS_TOKEN=...` as the repository's own notes require.

## Tier 3 — Firestore security rules

`tests/firebase-rules/` has a package manifest but no spec files yet. Chapter 7 currently reports the rules as verified indirectly, through the server-side entitlement and ownership tests in the Functions suite. If you want direct rules coverage — and for a report that leans as heavily on `firestore.rules` as this one does, it is worth having — say so and the specs can be written against `@firebase/rules-unit-testing` to cover the ownership, backend-owned-field and premium-gate cases.

## Tier 4 — Manual test cases

The flows that no automated suite can cover are authored as numbered test scripts in the annex, in the format of the provided sample: Objective, Classification, Pre-requisites, then a step table with Action, Expected Result, Actual Result and P/F/O, followed by tester and witness signature blocks. These cover location and motion permission prompts, live GPS tracking and pause/resume, voice coaching playback, push notification delivery and scheduling, the premium paywall path, the admin console sections, and the account deletion flow. They are executed and signed by hand.

## What to send back

Once the logs exist under `test-evidence/reports/`, they can be read directly from the repository and folded into the Test Summary Report. No manual transcription is needed — the raw `node --test` and `flutter test` output is enough.
