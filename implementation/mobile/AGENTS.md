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

## Flutter Source Structure
- `lib/app.dart` must remain app composition only.
- New feature screens must live under `lib/features/<feature>/presentation/`.
- Feature-specific widgets must live under `lib/features/<feature>/presentation/widgets/`.
- Shared widgets must live under `lib/core/widgets/`.
- Theme and color definitions must live under `lib/core/theme/`.
- Plan is a separate future feature reachable from You, not a bottom-navigation tab.
- Future Plan files must live under `lib/features/plan/` only when an approved Plan capsule creates real implementation files.
- Do not create empty future feature folders.

## Constraints
- Flutter may display XP, streak, level, rank, weekly XP, monthly XP, and leaderboard values, but must not directly write trusted values.
- Basic/Premium access uses `subscriptionStatus`.
- Operational and governance access uses `userRole`.
- Premium UI gating must be backed by backend enforcement.
- Do not run `flutterfire configure`, add Firebase config files, add production features, add custom tests, or run build/deploy commands unless separately approved.
