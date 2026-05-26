# Runiac Mobile Implementation Instructions

## Scope
- Applies to future Flutter mobile application work under `implementation/mobile/`.
- A10_FLUTTER_IMPL owns Flutter UI, navigation, state, forms, GPS UI, local interaction, FCM handling, and client integration.
- `implementation/mobile/runiac_app/` now exists as the approved stock Flutter scaffold baseline.
- The scaffold baseline is not permission to add Runiac production features, custom tests, Firebase configuration, or dependency changes.
- Future mobile source changes require explicit routing and approval.

## Test Placement
- Future Flutter unit and widget tests belong under `implementation/mobile/runiac_app/test/`.
- Future Flutter integration tests belong under `implementation/mobile/runiac_app/integration_test/`.
- Root-level `tests/` is for cross-system tests only.

## Constraints
- Flutter may display XP, streak, level, rank, weekly XP, monthly XP, and leaderboard values, but must not directly write trusted values.
- Basic/Premium access uses `subscriptionStatus`.
- Operational and governance access uses `userRole`.
- Premium UI gating must be backed by backend enforcement.
- Do not run `flutterfire configure`, add Firebase config files, add production features, add custom tests, or run build/deploy commands unless separately approved.
