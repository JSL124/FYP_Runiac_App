# workout-detail-briefing-agent

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly routed IMPLEMENTATION_MODE follow-up for the planned-workout detail surface.

## Goal

Replace the static Coach note card on the planned-workout detail screen with an on-demand AI briefing: a sparkle button in the header opens the existing character run-in overlay, whose four bubble pages explain today's planned session in beginner-friendly English through a new premium-gated Firebase callable and server-side OpenAI provider.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Backend Guarded Lane (ADR-002 emulator-first, ADR-003 lane rules), plus Flutter You/core UI and the admin-console feature-access catalog.
- Status: `In progress`.
- Required terminal state: `Ready for user screen QA` and `Ready for manual commit`.
- Real-screen boundary: agent may run iOS Simulator QA for this explicitly routed feature and must record evidence.
- Commit boundary: no automatic commit. Stop at `Ready for commit` and provide manual git commands.
- Deploy boundary: `workoutBriefingAgent` is a new export, not an update. No production `runiac-fypp` deploy without a separate explicit user authorization recorded in `CURRENT.md`.

## Required Agent / Review Chain

`A0_ORCH -> A10_FLUTTER_IMPL -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Allowed Scope

- Removal of `_CoachNoteCard` and its call site from the workout detail screen. The `coachNotes` data field, its generator, and its Firestore round-trip stay untouched and become AI prompt context instead of rendered copy.
- Extraction of `CharacterGuidanceOverlay` into `lib/core/widgets/`, with `ActivityFeedbackOverlay` reduced to a behaviour-preserving wrapper that keeps its public constructor and every existing widget key. The running summary screen is not modified.
- Sparkle AI button in `RuniacBackHeader.trailing` on the workout detail screen, on both entry paths (You tab in-place swap and Home tab push), coexisting with the existing edit-schedule action.
- Display-string-only Flutter payload built from `WeeklyWorkoutDetailSnapshot`, plus one new optional `WorkoutBriefingContext` field (`planId`, `weekNumber`, `weekFocus`) populated by the generated-plan display adapter.
- Flutter domain port, payload builder with a deterministic content fingerprint, local 7-day cache store, caching decorator, and callable adapter that never throws.
- New authenticated Cloud Functions callable `workoutBriefingAgent` with request/response contracts, strict input parsing, server-side OpenAI provider with structured JSON output, safe output validation, privacy-safe logging, and an enforced per-user 5-attempts-per-Asia/Singapore-day quota.
- Registration of the `workoutBriefing` feature key in the Functions config catalog, the admin-console config catalog and policy labels, and the app's offline feature-access defaults, premium catalog, and paywall QA launcher.
- Focused Flutter and Functions tests, plus governance and simulator QA evidence.
- Roadmap routing files and governance checker predicates for this capsule only.

## Forbidden Scope

- No production `runiac-fypp` deploy of any kind without a separate explicit user authorization recorded in `CURRENT.md`.
- No raw GPS coordinates, route geometry, polyline, route names, persistent activity or plan identifiers, nicknames, timestamps, or any PII in OpenAI prompts or logs. `planId` is cache-key material only and is never sent over the wire.
- No Flutter-side OpenAI calls, OpenAI keys, or prompt/response persistence in Firestore or any durable store.
- No mutation of XP, level, rank, streak, leaderboard score, weekly/monthly XP, subscription privilege state, or expert-plan publication state, and no client-side computation of any backend-owned value.
- No premium-vs-basic divergence in any scoring rule. The briefing is presentation and coaching value only.
- No `firestore.rules`, `firestore.indexes.json`, or `storage.rules` change. The quota counter writes to `agentUsage`, which is already deny-all to clients.
- No removal of the `coachNotes` field from the domain model, plan generator, Firestore persistence, demo snapshots, or existing tests.
- No change to `activityFeedbackAgent`, `homeGuideAgent`, or their handlers, models, quotas, contracts, or consent logic. No extraction of a shared OpenAI provider module in this capsule.
- No modification of `view_summary_screen.dart` or any existing `activity_feedback_overlay_test.dart` assertion.
- No new dependencies or secrets. `OPENAI_API_KEY` is reused as-is.
- No RAG, vector store, embeddings, tool-calling, or LangGraph usage.
- No edits inside the isolated `adaptive-character-guidance` worktree, and no staging of unrelated pre-existing changes.

## Accepted Trade-offs

- The OpenAI provider trio, `invokeWithTimeout`, and the secret-resolution block become a third copy rather than a shared module. Extracting them would drag `activityFeedbackModel.ts` and `homeGuideModel.ts` into this capsule's allowlist and simultaneously into two other capsules' file lists, for zero runtime benefit. A `functions/src/agent/openaiProvider.ts` extraction is left as a separate future refactor capsule.
- `LocalWorkoutBriefingCacheStore` duplicates roughly 120 lines of `LocalActivityFeedbackCacheStore`, whose encode/decode hardcodes the four run-shaped section keys. Generalizing it would mean editing a file inside the shipped activity-feedback capsule.
- Caching is composed as a decorator rather than embedded in the callable adapter, diverging from `CloudFunctionActivityFeedbackAgent`. The existing shape forces its test to mock Firebase Functions in order to assert cache behaviour; separating them keeps TTL and fingerprint invalidation purely testable.
- `ActivityFeedbackOverlay` becomes a wrapper over the shared overlay. Its constructor, keys, and rendered behaviour are unchanged, which its existing test suite must prove without modification.
- RAG and tool-calling were evaluated and rejected: the workout being explained is already fully present in the request, a multi-hop loop would not fit the 10-second callable budget behind an 800 ms run-in animation, a Firestore-reading tool would open an unvetted data channel through the inbound guard, and a tool graph cannot be faked by the deterministic provider the emulator tests depend on.

## Exact Target Files

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/workout-detail-briefing-agent.md`
- `tools/governance-ci/check-diff-hygiene.sh`
- `tools/governance-ci/check-pre-scaffold-scope.sh`
- `functions/src/agent/workoutBriefing*.ts`
- `functions/src/index.ts`
- `functions/src/config/configLoader.ts`
- `functions/package.json`
- `functions/test/workoutBriefing*.test.ts`
- `functions/test/feedCallableSurface.test.ts`
- `functions/test/configLoader.test.ts`
- `implementation/mobile/runiac_app/test/feature_access_read_model_test.dart`
- `website/src/lib/admin/config-validation.ts`
- `website/src/components/admin/PolicySettings.tsx`
- `implementation/mobile/runiac_app/lib/core/widgets/character_guidance_overlay.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/activity_feedback_overlay.dart`
- `implementation/mobile/runiac_app/lib/features/you/domain/models/workout_briefing_agent.dart`
- `implementation/mobile/runiac_app/lib/features/you/domain/services/workout_briefing_payload_builder.dart`
- `implementation/mobile/runiac_app/lib/features/you/data/cloud_function_workout_briefing_agent.dart`
- `implementation/mobile/runiac_app/lib/features/you/data/local_workout_briefing_cache_store.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/weekly_workout_detail_screen.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/weekly_workout_detail_cards.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/data/weekly_workout_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/adapters/generated_plan_you_display_adapter.dart`
- `implementation/mobile/runiac_app/lib/features/paywall/domain/models/feature_access_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/paywall/domain/models/premium_feature_catalog.dart`
- `implementation/mobile/runiac_app/lib/features/paywall/presentation/qa/premium_paywall_qa_launcher.dart`
- `implementation/mobile/runiac_app/test/character_guidance_overlay_test.dart`
- `implementation/mobile/runiac_app/test/workout_briefing_payload_builder_test.dart`
- `implementation/mobile/runiac_app/test/cloud_function_workout_briefing_agent_test.dart`
- `implementation/mobile/runiac_app/test/weekly_workout_detail_briefing_test.dart`

## Required Tests

- `cd implementation/mobile/runiac_app && flutter test --no-pub test/activity_feedback_overlay_test.dart test/run_flow_static_ui_test.dart` must pass with those files unmodified, as the overlay-extraction regression proof.
- `cd implementation/mobile/runiac_app && flutter test --no-pub test/character_guidance_overlay_test.dart test/workout_briefing_payload_builder_test.dart test/cloud_function_workout_briefing_agent_test.dart test/weekly_workout_detail_briefing_test.dart`
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`
- `cd implementation/mobile/runiac_app && flutter test --no-pub` (full suite; pre-existing baseline failures recorded, not newly introduced)
- `cd functions && npm run build && npm test`
- `bash tests/governance/config_contract_drift_test.sh`
- `bash tests/governance/backend_functions_scope_test.sh`
- `./tools/governance-ci/run-all-checks.sh`
- `git diff --stat` reviewed before staging, to prove the newer local `dart format` did not rewrite untouched files.

## Required Validation

- ADR-002 emulator-first: the callable is exercised against the Functions emulator with the deterministic fake provider (`FUNCTIONS_EMULATOR=true`, `GCLOUD_PROJECT=runiac-functions-test`, `RUNIAC_WORKOUT_BRIEFING_FAKE_PROVIDER=deterministic`) so no real OpenAI call is made during verification.
- A13_SECURITY_RULES review of the entitlement re-check, the quota counter, and the inbound/outbound prompt guards.
- A6_REVIEW of the feature-key catalog mirroring between `functions/src/config/configLoader.ts` and `website/src/lib/admin/config-validation.ts`.

## Required Evidence

- Overlay extraction regression output showing the two pre-existing test files green without modification.
- Functions build and full test counts before and after the new callable.
- Governance checker output with the new predicates active.
- Simulator screenshots: Coach note absent, sparkle present on the You tab entry path, sparkle present on the Home tab today-plan path, Basic account paywall interception, Premium overlay run-in and all four bubble pages, and the reduced-motion path.

## Rollback Conditions

- Revert if the overlay extraction cannot keep `test/activity_feedback_overlay_test.dart` passing unmodified.
- Revert if the config contract drift test cannot be satisfied by mirrored catalog edits alone.
- Stop and re-route if any required change falls outside the Exact Target Files list.

## Exit Criteria

- [ ] Coach note card is gone from the workout detail screen and `coachNotes` remains intact in the model, generator, and Firestore round-trip.
- [ ] Sparkle button appears in the header top-right on both entry paths and coexists with the edit-schedule action.
- [ ] Tapping it as a Basic account intercepts with the paywall and makes no callable request.
- [ ] Tapping it as a Premium account runs the character in and renders four beginner-friendly English pages.
- [ ] The callable requires auth and App Check, re-checks entitlement server-side, enforces the daily quota, validates input and output, keeps OpenAI server-side, and persists no prompt or generated text.
- [ ] Only whitelisted display strings leave the device; no identifiers, timestamps, or location data are sent.
- [ ] `ActivityFeedbackOverlay` behaviour is unchanged, proven by its unmodified test suite.
- [ ] Feature key is registered in all six catalogs and the config contract drift test passes.
- [ ] Focused and full Flutter tests, Functions tests, and governance checks pass.
- [ ] Simulator QA evidence recorded.
- [ ] Snapshot updated.
- [ ] No production deploy performed.
