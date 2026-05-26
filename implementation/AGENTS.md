# Runiac Implementation Agent Instructions

## IMPLEMENTATION_MODE Scope
- IMPLEMENTATION_MODE is used only when the user explicitly asks to implement, build, test, or fix code.
- This folder currently contains future IMPLEMENTATION_MODE instructions only.
- Stock Flutter scaffold baseline exists under `implementation/mobile/runiac_app/`; this is scaffold baseline only, not Runiac production feature implementation.
- No production Runiac feature implementation currently exists in this folder; instruction-only files here are not production implementation code.
- Production implementation files or scaffold changes should be added only when the user explicitly routes and approves implementation.
- Do not rewrite PDD-only files unless the implementation task explicitly requires documentation or traceability updates.
- Do not place production source code inside `docs/`.
- Firebase remains uninitialized. Do not run `firebase init`, `flutterfire configure`, or add Firebase config/secrets unless separately approved.

## Implementation Workflow
- A0_ORCH owns the workflow.
- Use A9_TRACE before implementation when requirements must be mapped from PRD/PDD to code.
- Use A10_FLUTTER_IMPL for Flutter UI, navigation, state, forms, and client integration.
- Use A11_FIREBASE_IMPL for Firebase, Firestore, Cloud Functions, FCM, Storage, and trusted backend logic.
- Use A12_QA_TEST after meaningful implementation changes.
- Use A13_SECURITY_RULES for auth, roles, Firestore rules, trusted writes, privacy, and fairness controls.
- Run A6_REVIEW when implementation decisions affect architecture, security, data model, roles, entitlements, XP, streaks, levels, ranks, or leaderboards.
- Run A8_OUTPUT_CHECKER before Ready for commit.

## Flutter UI Capsule Chain

Use this reusable checklist for Flutter UI/product-code-changing capsules, including visual polish capsules, `app.dart` UI/layout/navigation changes, `widget_test.dart` alignment, static Home/Run/Maps/Leaderboard/You UI capsules, beginner-friendly UX improvements, wireframe resemblance improvements, and Android smoke evidence after UI changes when relevant.

Do not use this chain for roadmap memory-only changes, capsule closure-only changes, pure Governance CI updates, PDD documentation-only work, Firebase/backend capsules, commit/push-only review, or purely mechanical formatting/import cleanup where A5_WIRE would not add useful UI/UX review.

Primary chain:

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

Shorter optional chain for mechanical Flutter fixes that do not affect UX, visual hierarchy, user-facing copy, navigation meaning, or wireframe alignment:

```text
A0_ORCH -> A9_TRACE light check if needed -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

Agent responsibilities:

- A0_ORCH confirms the active capsule and mode, defines scope and allowed files, defines forbidden work, coordinates specialists, and prevents phase or capsule drift.
- A9_TRACE performs a light traceability check, confirms the UI change supports Runiac's beginner-focused goals, confirms no PRD/PDD meaning drift, and avoids full redesign unless explicitly approved.
- A5_WIRE reviews UI/UX intent before implementation, checks beginner-friendly tone and cognitive load, checks visual hierarchy, CTA clarity, and wireframe resemblance, avoids shame/guilt/aggressive competition patterns, avoids metric overload, and must not implement Flutter code directly unless explicitly assigned under A10.
- A10_FLUTTER_IMPL implements approved Flutter UI, layout, and client changes, keeps UI static unless backend integration is explicitly approved, avoids fake backend-owned values, avoids new dependencies unless separately approved, and preserves the mobile-first layout and bottom navigation contract.
- A6_REVIEW checks architecture boundaries, scope isolation, backend-owned value protection, Firebase/GPS/Auth/Firestore leakage, and beginner-friendly UX constraints.
- A12_QA_TEST defines and runs approved validation, checks widget tests, recommends Android smoke evidence when relevant, and records factual test evidence.
- A8_OUTPUT_CHECKER verifies modified files, validation evidence, absence of invented results, READY/NOT READY verdict, and commit readiness.

A5_WIRE inclusion rule:

- Use A5_WIRE when the Flutter capsule changes visual hierarchy, layout, spacing, typography, user-facing copy, onboarding or guidance flow, Home dashboard presentation, navigation meaning, beginner-friendly UX, or wireframe alignment.
- Skip A5_WIRE only for purely mechanical Flutter fixes, test expectation repairs, import cleanup, non-visual refactors, or changes where UX meaning is unchanged.

Always protected backend-owned values:

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

Flutter UI capsule default validation:

- `flutter analyze --no-pub`
- `flutter test`
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- Android smoke evidence if the UI surface changed and an emulator is available

Default allowed future files for Flutter UI implementation capsules:

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if expectations must change
- Roadmap files during routing or closure only

Default forbidden files for Flutter UI implementation capsules:

- `pubspec.yaml` unless dependency approval exists
- `android/`
- `ios/`
- `firebase/`
- Generated or build files
- Unrelated roadmap or capsule files

Relationship to existing chains:

- `A0_ORCH -> A6_REVIEW -> A8_OUTPUT_CHECKER` remains appropriate for governance, roadmap memory, capsule closure, and commit/push-only review.
- `A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER` should be used for Flutter UI/product capsules.
- `A0_ORCH -> A5_WIRE -> A6_REVIEW -> A8_OUTPUT_CHECKER` remains appropriate for pure wireframe/PDD UI documentation.
- Firebase/backend work must use A11_FIREBASE_IMPL and A13_SECURITY_RULES instead of A10/A5 as primary agents.

## Implementation Constraints
- Flutter client must not directly write XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP.
- Premium UI gating must not be the only enforcement for premium-only features.
- `subscriptionStatus` controls Basic/Premium feature access.
- `userRole` controls operational/governance access.
- Medical Trainer/Expert cannot directly publish expert plans.
- Platform Administrator-only operations must be enforced through trusted backend logic.
- Premium users must not gain XP, ranking, leaderboard score, or competitive advantages.
- Future Flutter source changes require explicit routing and must preserve backend ownership of XP, streak, level, rank, leaderboard, subscription, and expert-publication state.

Detailed implementation role profiles are in `implementation/AGENT_ROLES.md`.
