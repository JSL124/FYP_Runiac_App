# maps-tab-static-placeholder

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI product-code-changing capsule.

## Status

Status: Ready for commit.

Routed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `feat(mobile): add static maps tab placeholder`.

Completion review:

- A0_ORCH PASS.
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

This capsule is ready for commit. It is not committed, staged, or pushed.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Implement a static Maps tab placeholder that visually follows the provided MapsLandingPage wireframe structure without starting map SDK, GPS/location permission, route generation, saved-route persistence, Firebase, backend, or real route discovery behavior.

## Allowed Scope

- Replace the current generic Maps placeholder tab with a static MapsLandingPage-style screen.
- Include a full map-like background across the Maps tab area above bottom navigation.
- Include a top overlay with a static search bar and static Saved control.
- Include decorative roads, route-like lines, subtle map blocks, and marker placeholders.
- Include a draggable bottom shared route panel with safe placeholder cards.
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Preserve the Runiac palette:
  - Primary Blue `#2F50C7`
  - Accent Orange `#FC6818`
  - White `#FFFFFF`
  - Background `#F7F8FC`
  - Text Primary `#172033`
  - Text Secondary `#6B7280`
  - Border `#E6EAF2`
- Update `widget_test.dart` only for visible static Maps expectations.
- Update roadmap and snapshot files for routing and readiness.
- Update Governance CI exact allowlist only for this capsule path if required.

## Forbidden Scope

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS or location permissions.
- No current location state.
- No real map SDK.
- No route generation.
- No route recommendation logic.
- No route persistence.
- No saved-route persistence.
- No fake route names.
- No fake place names.
- No fake distances.
- No fake pace.
- No fake duration.
- No fake difficulty.
- No fake ratings.
- No fake saved counts.
- No fake community activity.
- No XP/streak/level/rank updates.
- No fake backend-owned values.
- No premium entitlement logic.
- No dependency changes.
- No native Android/iOS changes.
- No Phase 02 selection.
- No workflow configuration changes.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/maps-tab-static-placeholder.md`
- `tools/governance-ci/check-diff-hygiene.sh` only for exact allowlisting of this capsule file

## Acceptance Criteria

- Maps tab is no longer a generic blank placeholder screen.
- Maps tab visually resembles the MapsLandingPage wireframe structure.
- Full Maps area above bottom navigation reads visually as a map-like background.
- Search bar appears at the top over the map background.
- Search bar placeholder text is `Search routes or area`.
- Saved button appears to the right of the search bar.
- Saved button is a rounded capsule using a Runiac guide color with a white bookmark-outline icon and white `Saved` text.
- Bottom shared route panel appears over the map background and can slide down/up so more of the map-like background can be viewed.
- Route preview cards use safe placeholder copy only.
- Bottom navigation remains Home / Maps / Run / Leaderboard / You.
- Layout is readable and does not overflow.
- Static UI only; no real map, GPS, route, saved-route, Firebase, backend, XP, leaderboard, or premium behavior is added.

## Required Tests

- Inspect whether `./tools/governance-ci/run-all-checks.sh` includes `flutter test`.
- If Governance CI does not include `flutter test`, run `flutter test` once after `flutter analyze --no-pub`.
- Do not run `flutter test` twice unless the first run fails and a fix is applied, or Governance CI behavior is unclear and the reason is recorded.

## Required Validation

- `git status --short` before changes.
- `flutter analyze --no-pub`.
- `flutter test` once if not already covered by Governance CI.
- `git diff --check`.
- `./tools/governance-ci/run-all-checks.sh`.
- `git status --short`.
- Android smoke evidence if `emulator-5554` is available.

## Evidence

- Initial `git status --short`: no output.
- Initial `git status -sb`: `## main...origin/main`.
- Initial `git log --oneline -5` latest entry: `526cde3 fix(mobile): align home dashboard reference layout`.
- A0_ORCH finding: implementation-approved mode applies only to this explicitly routed static Maps UI capsule; active capsule was none before routing; Phase 02 remains unselected.
- A9_TRACE finding: the change is Maps tab static route discovery placeholder UI only; it does not change product behavior, backend ownership, GPS/location, real route data, route generation, XP, streak, level, rank, leaderboard, subscription, or validated activity state.
- A5_WIRE finding: the Maps tab follows the provided MapsLandingPage structure with full map-like background, top search and Saved overlay, decorative map elements, draggable bottom shared routes panel, and preserved bottom navigation.
- A5_WIRE finding: the Saved control follows the requested pill style using Runiac primary blue, with a white bookmark-outline icon placed before white `Saved` text.
- A10_FLUTTER_IMPL summary: replaced the generic Maps placeholder with `_MapsTab`, static custom-painted map visuals, top search/Saved overlay, marker placeholders, draggable bottom shared routes sheet, and safe route preview cards in `implementation/mobile/runiac_app/lib/app.dart`.
- A10_FLUTTER_IMPL summary: updated `widget_test.dart` to assert visible static Maps placeholder copy after selecting the Maps tab.
- Governance CI exact allowlist was updated only for `implementation/roadmap/capsules/maps-tab-static-placeholder.md`.
- Governance CI inspection: `./tools/governance-ci/run-all-checks.sh` does not run `flutter test`, so `flutter test` was run separately once after `flutter analyze --no-pub`.
- `flutter analyze --no-pub`: `No issues found!`.
- `flutter test`: `All tests passed!`.
- `git diff --check`: no output.
- `./tools/governance-ci/run-all-checks.sh`: `All Governance CI checks passed.`
- `flutter devices` detected `emulator-5554`.
- `flutter run -d emulator-5554`: launched successfully with no runtime crash observed in console output during smoke observation.
- Temporary screenshots captured outside the repository at `/private/tmp/runiac-maps-draggable-default.png`, `/private/tmp/runiac-maps-draggable-collapsed.png`, and `/private/tmp/runiac-maps-draggable-expanded.png`.
- Visual smoke observation: Maps tab is selectable, bottom navigation remains Home / Maps / Run / Leaderboard / You, map-like background fills the tab area above bottom navigation, search bar and primary-blue Saved pill are visible, draggable bottom shared routes panel can slide down to reveal more map area and slide back up to show the full placeholder card list, and route cards use safe placeholder copy only.
- No fake route/place/distance/duration/difficulty/saved-count data, GPS/location behavior, Firebase/Auth/Firestore/backend behavior, dependency change, native platform change, workflow configuration change, or Phase 02 selection was introduced.

## Rollback Conditions

Stop and do not close this capsule if implementation:

- Modifies files outside the allowed scope.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, real map SDK, route generation, saved-route persistence, route recommendation logic, native Android/iOS, dependency, backend, or real map behavior.
- Adds fake route names, place names, distances, pace, duration, difficulty, ratings, saved counts, community activity, GPS readiness, XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription state, premium state, or any backend-owned value.
- Selects Phase 02.
- Modifies workflow configuration.
- Fails required validation.

## Exit Criteria

- [x] Target files completed.
- [x] Required tests or validation completed.
- [x] Required evidence recorded.
- [x] Snapshot updated.
- [x] CURRENT.md active capsule records this capsule as ready for commit.
