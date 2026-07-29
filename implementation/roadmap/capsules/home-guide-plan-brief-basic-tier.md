# home-guide-plan-brief-basic-tier

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md`, as an explicitly user-routed full-stack capsule under ADR-003. It touches one `functions/src/config` default and no callable logic, so it carries no emulator-first backend behaviour change.

## Status

Routed on 2026-07-29 Asia/Singapore at the user's explicit request, after an audit of where a Basic account can reach the OpenAI API. Implemented and validated locally. Not deployed.

## Goal

Stop Basic accounts from spending OpenAI calls on the Home guide bubble, and give them a bubble that simply reads today's plan back instead.

The audit found exactly two OpenAI call paths, both server-side:

1. `homeGuideAgent` → `homeGuideModel.ts` (`ChatOpenAI`) — the Home stage-map speech bubble.
2. `activityFeedbackAgent` → `activityFeedbackModel.ts` (`ChatOpenAI`) — the run-summary feedback sheet.

Path 2 was already Premium by default and denies Basic before the model call. Path 1 was open: `DEFAULT_FEATURE_ACCESS_CONFIG.aiHomeCoach` was `basic`, so every consenting Basic runner generated AI guide copy (bounded at three attempts per runner per Singapore day by `homeGuideQuotaCache`). This capsule closes path 1 and replaces what Basic sees.

## Contract Summary

- `aiHomeCoach` defaults to `minimumTier: "premium"` in `functions/src/config/configLoader.ts`, mirrored in the admin console's hand-maintained copy and in the app's offline `FeatureAccessReadModel` default key list. The server gate in `homeGuideAgentHandler.ts` is unchanged — it already read this document; only the shipped default moved.
- **The tier stays console-flippable by explicit user decision.** Setting `aiHomeCoach` back to `basic` in `config/featureAccess` re-opens the AI guide, and therefore the OpenAI spend, for Basic accounts. No hard floor was added: the Platform Administrator remains the authority over the tier, exactly as for every other key in the catalog.
- Basic runners get `PlanBriefHomeGuideAgent`, a new on-device guide that performs no network I/O of any kind. It composes one message from `HomeGuideRequest` display copy the client already rendered: a summary line (`"Today's Mon session is Easy Run for about 25 minutes."`) followed by the plan's own steps, numbered, capped at six. A plan without steps yields the summary line alone. A rest day states the fact and stops (`"Today's Wed is a rest day. No session is scheduled."`) with no encouragement copy and no step list.
- The guide seam is no longer three-slot-only. `HomeGuideAgent.explainTodayPlan` returns `HomeGuideContent` (an ordered, non-empty `messages` list). `HomeGuideBundle` implements it with its existing three named slots; `HomeGuidePlanBrief` implements it with a single multi-line message. `HomeGuideCycleController` advances modulo the resolved message count instead of a hardcoded `3`, and the bubble offers a tap affordance and an advance hint only when there is more than one message.
- `HomeGuideAgent` gained `requiresDataConsent`. Only the remote adapter returns true. The Home stage map gates the bubble on consent **only for an agent that answers true**, so declining personalized-guide data use now downgrades the runner to their own plan instead of removing the bubble. That was the user's explicit choice: the consent covers sending run totals to the AI provider, and it never covered showing the runner the plan they already own.
- An unresolved consent status still withholds the bubble, preserving the first-Home-entry consent sheet.
- Privacy & Safety states the tier boundary in the consent card. The versioned disclosure string (`homeGuideConsentDisclosure`, pinned by `HOME_GUIDE_DISCLOSURE_VERSION` server-side) is deliberately unchanged, so no existing consent is invalidated and no runner is re-prompted.
- No progression divergence. Premium buys the AI wording of the guide, not XP, level, rank, streak, or leaderboard score, and nothing here reads or writes a backend-owned value.

## Allowed Scope

- Modified: `functions/src/config/configLoader.ts` (the `aiHomeCoach` default tier and its comment), `functions/test/configLoader.test.ts` (the expected default-tier map), and `functions/test/homeGuideAgentCallableSurface.test.ts` (its runner fixture is now entitled, plus the Basic denial case).
- Flutter, under the approved scaffold prefix: `home_guide_agent.dart` (the `HomeGuideContent` seam, `HomeGuidePlanBrief`, the `planBrief` message kind, `requiresDataConsent`), the new `plan_brief_home_guide_agent.dart`, `rule_based_home_guide_agent.dart` and `cloud_function_home_guide_agent.dart` (seam conformance), `home_guide_cycle.dart`, `home_stage_map.dart` and `home_stage_map_guide.dart`, `home_tab.dart` (agent selection), `feature_access_read_model.dart` (offline default keys), and `privacy_safety_screen.dart` (tier note).
- Tests: new `plan_brief_home_guide_agent_test.dart`; updated `home_stage_map_widget_test.dart`, `home_guide_cycle_test.dart`, `cloud_function_home_guide_agent_test.dart`.
- The admin console mirror `website/src/lib/admin/config-validation.ts`, which lives in its own repository and commits separately.
- This capsule plus one append-only CURRENT routing line.

## Forbidden Scope

- No production `runiac-fypp` deploy. The default is inert in production while `config/featureAccess` exists there, so the tier must be changed through the admin console (see Deployment).
- No change to `homeGuideAgent`, `activityFeedbackAgent`, their handlers, quota, consent, or model code. The entitlement check itself was already correct.
- No hard-coded tier floor that overrides `config/featureAccess`. The user chose to keep the console authoritative.
- No change to the versioned consent disclosure copy or `HOME_GUIDE_DISCLOSURE_VERSION`.
- No `firestore.rules`, index, or `storage.rules` change; no new dependency or secret; no client-side computation of any backend-owned value; no edits inside the isolated `adaptive-character-guidance` worktree.

## Deployment

Not deployed, and the code default alone changes nothing in production: `loadFeatureAccessConfig` deep-merges the stored `config/featureAccess` document over the defaults, so a stored `aiHomeCoach: basic` still wins. Closing the path in production requires the Platform Administrator to set `aiHomeCoach` to Premium in the admin console (or the document to be absent/invalid, which falls back to the new default). The mobile client change ships with the next app release.

## Validation

Completed on 2026-07-29 Asia/Singapore.

- `functions`: `npx tsc --noEmit` clean; `configLoader` + `featureEntitlement` suites 77/77 pass.
- Emulator (`firebase emulators:exec --only auth,functions,firestore,storage --project runiac-functions-test`, JDK 21): the full main suite **605/605 pass**. Recorded because the first push failed hosted Governance CI: `homeGuideAgentCallableSurface` seeded a consent document but no `users/{uid}`, so its runner read as Basic and every AI-path case took the new denial. The fixture now provisions a Premium runner, and a new case pins the denial contract — a Basic runner gets HTTP 403 `PERMISSION_DENIED` with no `agentGuidanceDaily` document, proving the entitlement check runs before the quota reservation that precedes every model dispatch. The local pre-push run had exercised only the two config suites, which is what let this through.
- `node tests/cross-system/config-contract-drift.mjs` PASS after the website mirror was updated in the same change.
- Flutter: `flutter analyze --no-pub` clean.
- New Flutter cases: the plan brief is a single `planBrief` message; summary-then-numbered-steps ordering; the six-step cap drops the remainder; a step-less plan renders the summary alone; a rest day states the fact and lists nothing; blank steps are dropped and whitespace normalized; the agent is deterministic and reports `requiresDataConsent == false`.
- New widget cases: the on-device brief renders with consent explicitly not granted, and a single-message bubble lists every step at once, announces `"Today's plan and its steps."`, and does not cycle on tap. The existing "hides the guide until consent is granted" case still passes, now against a fake that reports `requiresDataConsent == true`.
