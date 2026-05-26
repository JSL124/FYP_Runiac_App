# flutter-app-shell-baseline

## Status

Status: Closed.

Completed on: 2026-05-26 Asia/Singapore

Completion commit: `e48a348 feat(mobile): add static Runiac app shell`

Completion review:

- A6_REVIEW PASS.
- A8_OUTPUT_CHECKER PASS.
- `flutter analyze --no-pub` PASS.
- Governance CI PASS.

This capsule is closed. Do not add further work to it.

## Purpose

Transition the mobile app shell from the stock Flutter counter template into a minimal, static, offline Runiac app shell.

This capsule was the routing and implementation contract for the static shell patch. The implementation checkpoint completed in `e48a348 feat(mobile): add static Runiac app shell`.

## Current Baseline

- Static offline Runiac app shell exists at `implementation/mobile/runiac_app/`.
- `implementation/mobile/runiac_app/lib/` contains `main.dart` and `app.dart`.
- The stock Flutter counter template has been replaced with a static shell.
- The shell has exactly five placeholder tabs: Home, Plan, Run, Explore, and Leaderboard.
- Firebase remains uninitialized.
- `flutterfire configure` has not been run.
- No Firebase config/source files are present.
- No Firebase, GPS, authentication, leaderboard, XP, or backend-owned logic has been added.

Modified implementation files:

- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`
- `implementation/mobile/runiac_app/pubspec.lock`

## Completed File Scope

Production implementation files modified:

- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/app.dart`

Validation-support file modified:

- `implementation/mobile/runiac_app/test/widget_test.dart`

Lockfile updated:

- `implementation/mobile/runiac_app/pubspec.lock`

No further files should be added to this capsule.

Strict file layout rule:

- Do not create separate screen files in this capsule.
- Do not create `lib/screens/`.
- Do not create feature folders.
- Do not create assets.
- Do not create additional test files.
- Do not edit `pubspec.yaml`.

## Explicitly Forbidden Files

- `implementation/mobile/runiac_app/pubspec.yaml`
- Additional test files.
- `implementation/mobile/runiac_app/lib/screens/**`
- `implementation/mobile/runiac_app/android/**`
- `implementation/mobile/runiac_app/ios/**`
- Firebase files.
- Firestore rules.
- Cloud Functions files.
- Generated Firebase options.
- Phase 02 files.
- `PRD.md`
- `docs/pdd/**`
- `docs/submissions/**`
- `diagrams/**`
- `wireframes/**`
- `implementation/roadmap/roadmap-stretch.md`
- `tools/**`
- Unrelated roadmap, capsule, or ADR files.

## Explicitly Forbidden Commands

- `flutter create`
- `flutter pub get`
- `dart pub get`
- `flutterfire configure`
- `firebase init`
- `npm install`
- `pod install`
- `flutter build`
- `flutter test`
- `firebase deploy`
- Dependency resolution commands.
- Build, deploy, scaffold, or init commands.

## Shell UI Scope

- Static/offline only.
- Default Flutter theme only.
- Placeholder labels/messages only.
- Exactly five tab destinations:
  - Home
  - Plan
  - Run
  - Explore
  - Leaderboard
- A vanilla `MaterialApp` and stock `BottomNavigationBar` pattern is acceptable for the future implementation.
- No custom design system.
- No typography system.
- No custom color token system.
- No route exploration logic.
- No leaderboard logic.
- No onboarding logic.
- No analytics.

## Backend-Owned Boundary

The Flutter client must not implement, mock, calculate, mutate, or display fake operational examples for:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state
- validated activity contribution state

Explicitly forbidden:

- fake XP cards
- mock leaderboard rows
- hardcoded streak examples
- hardcoded rank examples
- subscription gating logic
- local calculations that appear authoritative

Allowed only:

- static placeholder tab labels
- static placeholder screen titles/messages
- non-functional shell UI

## Validation Evidence

Completion validation:

```bash
git status --short
git diff --check
flutter analyze --no-pub
./tools/governance-ci/run-all-checks.sh
```

Explicitly forbidden validation commands:

- `flutter pub get`
- `dart pub get`
- `flutter build`
- `flutter test`
- dependency resolution
- Firebase commands
- deploy/init commands

## A6_REVIEW Checklist

A6_REVIEW must verify:

- scope boundary
- scaffold boundary
- backend-owned state isolation
- no Firebase
- no native file edits
- no dependency changes
- no mock operational data
- no tab feature logic

## A8_OUTPUT_CHECKER Checklist

A8_OUTPUT_CHECKER must verify:

- output contract
- allowed files only
- validation evidence
- no forbidden commands
- routing consistency
- unexpected file modification check

## Done When

- [x] The capsule document exists.
- [x] `CURRENT.md` selected this capsule as the active capsule during implementation.
- [x] `latest.md` records `e48a348 feat(mobile): add static Runiac app shell` as the latest verified commit.
- [x] The stock Flutter counter template was replaced with a static offline Runiac app shell.
- [x] The shell has exactly five placeholder tabs: Home, Plan, Run, Explore, and Leaderboard.
- [x] No Firebase, GPS, authentication, leaderboard, XP, or backend-owned logic was added.
- [x] No Firebase, native, build, init, or deploy action was performed.
- [x] A6_REVIEW and A8_OUTPUT_CHECKER passed.
- [x] `flutter analyze --no-pub` passed.
- [x] Governance CI passed.

## Out of Scope

- Further Flutter source implementation beyond the static shell baseline.
- Separate screen files.
- `lib/screens/`.
- Feature folders.
- Assets.
- `pubspec.yaml` edits.
- Firebase setup or configuration.
- Authentication.
- GPS or location permissions.
- Real onboarding.
- Real plans, routes, activities, XP, streaks, ranks, leaderboard data, subscription state, or expert plan state.
- State management libraries.
- Dependency changes.
- Backend-owned logic.
- Native Android/iOS edits.
- Phase 02 work.

## Human Approval Gates

This capsule is closed and does not authorize further Flutter source changes.

Future source changes require a new explicit route and a separate implementation-approved prompt. Review output alone is not approval for broader implementation, Firebase setup, dependency resolution, native file changes, build, deploy, scaffold, or init work.

## Rollback / Recovery Note

This capsule is closed. If closure metadata is incorrect, recover by patching only the roadmap memory files unless a separate implementation-approved task explicitly authorizes source changes. Do not modify Flutter, Firebase, native, dependency, build, or deploy files as part of rollback unless separately approved.
