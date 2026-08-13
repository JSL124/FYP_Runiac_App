# Source-to-Implementation Drift Register

*Covers both project documents: the Project Proposal (basis of Chapter 1) and the PRD (basis of Chapter 2).*

## 0. Proposal-era drift — the two biggest design changes in the project

These do not appear in the PRD comparison below, because the PRD had already absorbed part of them. They are the most consequential changes the project made and both belong in Chapter 1 and Chapter 10.

### 0.1 F8 was a grid-tile territorial ownership game — REDESIGNED

The proposal's §8.4 and §8.5 describe the client converting GPS coordinates into grid tile identifiers, recording visited tiles, and the backend deduplicating them and resolving *tile ownership* through Firestore transactions with recency-based conflict resolution. Clusters of adjacent tiles were to approximate user-defined territories.

None of this exists. There is no tile model, no ownership, no territory. The delivered F8 aggregates validated activity by Singapore planning area and league division on a monthly period and publishes ranking documents. The motivational intent — localised, achievable competition — survived; the ownership game did not.

The proposal itself flagged this as risk R17 at High likelihood and High impact. Chapter 1 §1.9.2 records R17 as realised and resolved by redesign, which is the honest and the strongest framing: the risk register predicted the problem and the team acted on it.

### 0.2 F9 was Running Heatmap Visualization — REPLACED

The proposal's F9 rendered running activity density on a map from pre-aggregated per-tile counts. It depended entirely on the tile model in 0.1 and did not survive its removal. The F9 slot was reassigned to the Runner Level and XP Progression System — which the PRD had already done, and which F8 requires in order to group runners into fair divisions.

Chapter 1 §1.2.4 therefore carries "running heatmap visualisation" as a separate row marked *not delivered*, rather than silently dropping it from the comparison table.

### 0.3 Proposal MVP allocation differed from the PRD's

The proposal's MVP was F1, F2, F3, F4, F6, F8 and F10, with F5, F7 and F9 (the heatmap) held for Phase 2. The PRD later moved F8 and F10 out of the MVP and pulled F9 (by then the XP system) in. Chapter 1 §1.3.4 presents the proposal's allocation and the delivered outcome side by side rather than either version of the plan alone.

---

# PRD-to-Implementation Drift Register

Project: Runiac (FYP-26-S2-38)
Compiled: 4 August 2026
Purpose: internal working document — not a submitted chapter

## How to read this

This register lists every point at which `PRD.md` and the delivered system disagree. It exists because the Final Project Document is written PRD-first but code-true: wherever the two conflict, the report describes what was built and, where the difference is material, says so plainly.

Each entry carries a disposition:

- **CORRECT** — the report states the implemented behaviour and silently drops the PRD wording. Used where the PRD was simply a plan that evolved.
- **DECLARE** — the report states the implemented behaviour *and* explicitly acknowledges the change, because an assessor comparing the PRD to the report would otherwise see an unexplained gap.
- **GAP** — the PRD promised something that was not built. The report declares it and carries it into Chapter 9 (Future Enhancements) or Chapter 10 (Conclusion).
- **BONUS** — the system does something the PRD never promised. The report describes it as delivered scope beyond the original plan.

---

## A. Scope and phasing

### A1. Every "Phase 2" feature was actually delivered — BONUS / DECLARE

PRD §3.4 places F5 (social sharing and competitions), F7 (community route sharing), F8 (level-based territorial leaderboard) and F10 (AI-assisted post-run summary) in "Phase 2 (post-MVP)", with the MVP limited to F1, F2, F3, F4, F6 and F9.

All four Phase 2 features exist in the shipped system. F5 is the `feed` module (42 Dart files) with `publishActivityToFeed`, likes, comments and engagement notifications. F7 is the `maps` module with `sharedRoutes`. F8 is the monthly regional leaderboard with scheduled aggregation. F10 is `activityFeedbackAgent`, backed by an actual LLM.

*Report treatment:* Chapter 2 presents F1–F10 as all delivered, and Chapter 10 records completing the full feature set as a project outcome rather than restating the MVP/Phase 2 split as if it still applied.

### A2. Challenges are a whole feature that the PRD never described — BONUS, folded into F5

The system contains a complete distance-tier challenge subsystem: 39 Dart files under `features/challenge`, eleven Cloud Function callables (`createChallengeLobby`, `inviteChallengeFriends`, `respondToChallengeInvitation`, `startChallenge`, `getActiveChallenge`, `leaveChallenge`, `abandonChallenge` and others), a settlement scheduler running every minute, six Firestore collections (`challengeInstances`, `challengeInvitations`, `challengeSlots`, `challengeRewardGrants`, `challengePremiumHolds`, `challengeBadges`) and a badge reward model. Tiers at or above 100K are premium-gated server-side with a `PREMIUM_REQUIRED` rejection.

*Report treatment:* the team has decided the report keeps exactly ten features, so challenges are documented **inside F5**, which is reframed from "connect with social media and initiate competitions" to "social connection, sharing and competition". UC-F5 therefore covers three capabilities under one use case — feed publication, external sharing, and distance challenges — because they share actors, entitlement model and moderation path. No F11 is created.

### A3. Friends, moderation, newsletter, admin console and public website are all beyond the PRD — BONUS

The PRD describes a mobile application. The delivered system also includes a friends graph with requests and blocking (22 Dart files, `searchFriends`, `sendFriendRequest`, `getFriendLevels`), a reporting and moderation pipeline (`reports`, `moderationCommands`, `reportCreated`, `escalateStaleReports`), a double-opt-in newsletter system, a Next.js 16 public marketing website, and a thirteen-section Platform Administrator console with a full audit log.

*Report treatment:* Chapters 4 and 5 must present the system as three deployable units — Flutter client, Firebase backend, Next.js web tier — not the two-tier client/backend picture in PRD §11.3. This is the single largest structural difference between the PRD and the delivered system.

---

## B. Progression and leaderboard mechanics

### B1. There is no weekly XP and no weekly consistency bonus — GAP / DECLARE

PRD §3.3 F9, §4.2, §9.3 and §11.4 all describe weekly XP as a stored quantity and a "weekly consistency bonus" as an XP source, and PRD §3.3 F8 states that the leaderboard ranks on "weekly XP or monthly XP" on "a weekly or monthly basis".

In the implementation, `weeklyXp` exists only as a **rejected** field name: it appears in the `protectedKeys` list of `functions/src/run/validateRunPayload.ts` and in `backendOwnedKeys()` in `firestore.rules`, so that a client cannot forge it. Nothing writes it. There is no weekly consistency bonus in `progressionCalculator.ts`. The XP sources that actually exist are base completion (20 XP), distance (10 XP per whole kilometre), active duration (5 XP per whole ten minutes), a plan completion bonus (20 XP), a cool-down bonus, and streak milestone rewards at 3, 7, 14 and 30 days paying 30, 90, 220 and 600 XP respectively.

Monthly XP is likewise not a stored counter. `sumMonthlyXp` in `functions/src/progression/progressionAuditHelpers.ts` recomputes it per transaction by querying `progressionEvents` for the current Singapore month, and stores the result only as an audit field on the event document.

*Report treatment:* Chapter 2 states the XP model as implemented with its real constants. Chapter 3 documents `progressionEvents` as the audit ledger from which monthly totals are derived. Chapter 9 lists weekly XP and the weekly consistency bonus as unimplemented.

### B2. The leaderboard is monthly only, and regions are Singapore planning areas — CORRECT / DECLARE

PRD §3.3 F8 describes a leaderboard that zooms from country down through district and neighbourhood, with weekly and monthly cadences.

The implementation has one cadence, monthly, keyed `YYYY-MM` on the Singapore calendar (`leaderboardTypes.ts`, `leaderboardTimezone = "Asia/Singapore"`), and one region model: the Singapore planning areas in `functions/src/leaderboard/singaporePlanningAreas.ts`. There is no country or multi-level zoom hierarchy. The `seasonLengthDays: 30` config value exists but is explicitly not wired, per a comment in `monthlyLeaderboardWriter.ts`.

Ordering is `scoreXp` descending with ties broken deterministically by `ownerUid.localeCompare` — not by recency. Aggregation runs every sixty minutes under a lease document, publishes a top-10 snapshot per region-and-division, and gives each user a rank document with a five-row neighbour window.

*Report treatment:* Chapter 2 and Chapter 4 describe the monthly, planning-area model as the delivered design and note that multi-level geographic zoom is future work.

### B3. Level bands are defined and finite — CORRECT

The PRD does not specify how level derives from XP. The implementation does: `levelIncrements: [100,150,220,300,400,520,660,820,1000,1200]` applied in bands of ten levels, `maxLevel: 100`, and ten leagues of ten levels each (`tier_01` Iron through `tier_10` Challenger). Chapter 2 should state these values, since they are the substance of F9.

### B4. Premium confers no competitive advantage — VERIFIED, not a drift

PRD §4.4 promises that Premium users receive no XP, ranking or scoring advantage. The code holds to this. `premiumEarnsXp` defaults to `true` and `excludePremium` defaults to `false`, so Premium runners use the identical formula on the identical board. The only premium-related branch in the XP path is `suppress = isPremium && !config.premiumEarnsXp`, which is inert by default and would be a penalty rather than an advantage if enabled.

*Report treatment:* this is a claim the report can make and prove. Chapter 7 should carry an explicit test case for it, since it is the project's most distinctive fairness commitment.

---

## C. Validation, safety and privacy

### C1. Kalman filtering and GPS outlier rejection were not implemented — GAP / DECLARE

PRD §12.2 R1 commits to "Kalman filtering and outlier rejection on raw GPS samples" with a confidence indicator, and PRD §6.4 says the system "shall reject or flag implausible activity data, such as unrealistic speed, sudden GPS jumps".

Server-side validation in `functions/src/run/` is scalar and structural, not geometric. It bounds duration (≤86,400 s), distance (≤100,000 m) and pace (120–3,600 s/km); it cross-checks that duration, active duration, paused time and wall-clock elapsed agree within 60 s; it checks that the implied pace derived from distance and duration matches the reported pace within a tolerance of `max(15, ceil(impliedPace × 0.02))` seconds per kilometre; and it rejects a `completedAt` more than six hours in the future. It does not examine the route geometry for speed outliers or position jumps. `validateRoutePreview.ts` only bounds the shape of the preview — at most 64 segments and 256 points, coordinates quantised to three decimal places.

There is also no server-side minimum distance or duration; the 50 m / 60 s minimum is client-side only.

*Report treatment:* Chapter 2 states the validation that exists, with its real thresholds. Chapter 9 lists GPS-level outlier rejection as future work. Chapter 10 acknowledges R1 and R5 as only partially mitigated.

### C2. Route privacy is coordinate quantisation, not privacy zones — GAP / DECLARE

PRD §6.2 and §12.2 R8 describe masking route start and end points near sensitive locations, in the manner of Strava's privacy zones.

What exists is a `routePrivacy` field on activity documents and the quantisation of shared route coordinates to three decimal places — roughly 110 metres of positional granularity — together with default-private visibility and explicit share actions. There is no user-defined privacy zone feature and no start/end masking.

*Report treatment:* declare the delivered protection accurately rather than claiming privacy zones. Carry the gap into Chapter 9.

### C3. Wearable and health integration — NOT DELIVERED (re-corrected 13 Aug 2026)

**This entry has now been wrong in both directions. Read the whole sequence before citing it.**

It first read "not implemented", which was wrong: the claim was made from `pubspec.yaml`, which contains no health package, but the integration was native rather than a Flutter plugin, so it never appeared there. On 4 Aug 2026 it was corrected to "partially delivered", describing `RuniacHealthKitImportChannel.swift`, the `com.apple.developer.healthkit` entitlement, `AppleHealthWorkoutImportRepository` and its mock. That description was accurate on the day it was written.

**It was obsolete two days later.** `65b41c49` ("remove the unimplemented HealthKit import surface", 6 Aug 2026) deleted all of it — 2,409 lines across 26 files: the method channel and its AppDelegate registration, the entitlement, `NSHealthShareUsageDescription`, the repository interface with both implementations, the imported-workout candidate and metric-contract mapper, and the Watch and Health Apps screen. The removal was deliberate, and its own commit message states the reason: the import chain was never finished, so the app "advertised a feature it could not deliver" — a settings row leading to a screen whose Apple Watch, Garmin and Health Connect entries only said "Health connections come next", behind a real iOS Health permission prompt with nothing on the other side.

What exists today: nothing HealthKit-facing. Verified 13 Aug 2026 — no health package in `pubspec.yaml`, no health file in `ios/Runner/`, an empty `Runner.entitlements`, and no match for `healthWorkoutImport` anywhere in `implementation/mobile/runiac_app/lib/`.

What survives, and is not HealthKit: the generic metric-source taxonomy (`RunSourceType`, `WorkoutMetricSource`, `AdvancedAnalysisMetricSource`) and the heart-rate analysis classes `AdvancedAnalysisHeartRateBuilder`, `AdvancedAnalysisHeartRateZonePolicy` and `HeartRateAnalysisEligibility`. These are real code, but with the import path gone there is no longer any source of heart-rate data, so they compute nothing in practice and report unavailability instead. Heart-rate zone analysis is **not** a delivered capability.

*Report treatment:* revert to declaring wearable synchronisation and heart-rate zone analysis undelivered. **Chapter 1 Risk R3 still carries the 4 Aug wording** ("HealthKit access sits behind a single repository interface with a mock implementation alongside it") and is now false — see the correction applied alongside this entry. Chapter 9 should carry the whole capability as future work, not just the Android half.

**Lesson for the remaining chapters:** a Flutter manifest is not sufficient evidence of absence — check `ios/Runner`, `android/app/src/main` and method-channel registrations. But the sharper lesson is the second failure, not the first: a code audit is true only on its audit date. Re-verify against the working tree before a claim reaches the submitted report, because the fastest way to make a register wrong is to correct it and then let the code move.

### C3-superseded-2. Wearable and health integration — PARTIALLY DELIVERED — SUPERSEDED BY C3

Recorded 4 Aug 2026, accurate then, obsolete from 6 Aug 2026. It described the native iOS import chain listed above and treated Android Health Connect, Bluetooth pairing and live heart-rate capture as the outstanding parts. `65b41c49` removed the delivered half, so the entry now describes code that does not exist.

### C3-original. Wearable and health integration is not implemented — SUPERSEDED BY C3

PRD §3.3 F1 says activity data is collected "through smartphone sensors and optional wearable devices via Bluetooth or Wi-Fi"; PRD §12.2 R3 discusses HealthKit and Health Connect API risk; the market survey table in §2.4 marks "wearable device synchronization" and "heart-rate zone analysis" as delivered for Runiac.

`pubspec.yaml` contains no health, HealthKit or Health Connect package. Sensor input is `geolocator` for GPS and `sensors_plus` for motion. The "Watch and health apps" screen in `features/profile/presentation/watch_health_apps_screen.dart` is a configuration surface, and `healthWorkoutImport` exists as a feature key, but no device SDK is integrated. Heart-rate zone analysis is therefore not delivered either.

*Report treatment:* this is the most significant unfulfilled claim in the PRD and must be declared clearly in Chapters 2 and 10 rather than left for an assessor to discover. The comparison table in Chapter 8 must be corrected before reuse.

### C4. Apple Sign-In is not implemented — GAP

PRD §6.1 specifies "Google Sign-In and Apple Sign-In". Only `google_sign_in` is present in `pubspec.yaml`; the website additionally supports email and password. Apple Sign-In is a store requirement for iOS release and belongs in Chapter 9 as a known prerequisite for App Store submission.

---

## D. Technology choices

### D1. Mapbox, not Google Maps — CORRECT

PRD §11.3 says "Google Maps or Mapbox". The implementation is `mapbox_maps_flutter ^2.25.0` throughout, with the access token supplied at runtime through `--dart-define` and never committed. State the delivered choice and the reason.

### D2. GeoFlutterFire was not used — CORRECT

PRD §9.1 and §9.2 justify Firestore partly through GeoFlutterFire geospatial indexing. No geohashing library is used. Regions are resolved through a static Singapore planning-area lookup, which is simpler and adequate for a single-city deployment. Chapter 3 should present the actual approach and note why geohashing proved unnecessary at this scope.

### D3. The LLM is OpenAI `gpt-4o-mini` through LangChain — CORRECT / ADD

The PRD refers to "LLM-based AI assistance" without naming a provider. The implementation uses `ChatOpenAI` with `gpt-4o-mini` in all three agents, at temperature 0.2 for the home guide and activity feedback and 0.3 for the workout briefing, with JSON-schema-constrained responses for two of the three. This deserves a full subsection in Chapters 4 and 5, including the daily quotas (five activity-feedback and five workout-briefing generations per user per Singapore day), the per-day fingerprint cache for the home guide, the consent gate, and the prompt-injection defence that instructs the model to treat plan context as untrusted display data.

### D4. State management is hand-rolled — ADD

No Bloc, Riverpod or Provider package is used. The client uses nineteen `ChangeNotifier` controllers and sixteen `InheritedWidget` scopes in a "CurrentSession" pattern, with the composition root in `features/shell/runiac_shell.dart`, and navigation is imperative through `Navigator.push` with no named routes or router package. Chapter 5 must describe this accurately rather than assuming a conventional state-management library.

---

## E. Roles

### E1. The role model is three roles, and the Medical Trainer/Expert is removed entirely — RESOLVED BY TEAM DECISION

The PRD (§3.2) described four roles including a "Trainer / Medical Advisor", and the repository's standing rules describe a Medical Trainer/Expert who submits expert plan content for Platform Administrator approval, with wireframes for a submission form, a revision response screen and a status page.

The team has confirmed that this role is not part of the project. The delivered role model is:

- **Unregistered User** — public website, project documents, newsletter signup, application download; in the application, the welcome, sign-up, log-in and password-reset screens and the twelve-screen application tour.
- **Registered User** — differentiated by `subscriptionStatus` into Basic and Premium, deliberately not modelled as two subclasses.
- **Platform Administrator** — identified by `userRole == "platformAdmin"` (legacy literal `"Platform Administrator"` also accepted), acting only through the Next.js console under a revocation-checked session cookie.

This matches the code exactly: the client carries no role enum, only a display string; `firestore.rules` never branches on role; and `expertPlans` is authored and published administratively through the Admin SDK, with Premium users able to read published plans and enrol through `planEnrollments`.

*Report treatment:* the Trainer / Medical Advisor actor is removed from Chapter 1 §1.3.2, from every Chapter 2 use case, and from the F3 use case diagram, where Platform Administrator replaces it as the publisher of goal-oriented plans. Goal plans are described as administratively published content, not as expert-authored content. This is **not** listed as a gap in Chapter 9 — it was never in scope.

### E2. Role storage and enforcement — CORRECT

`userRole` lives on `users/{uid}` and is server-owned: it is in `backendOwnedKeys()` and in the `completeRun` protected key list, so no client can write it. `firestore.rules` never branches on it; administrative work goes through Admin SDK command collections and the Next.js console, where `requireAdmin()` re-verifies a revocation-checked session cookie on every mutation. Chapter 3 should present this as the access-control design, since it is stronger than the PRD described.

---

## F. Items where the PRD is simply out of date

The PRD's Sprint plan (§7.3.1) and timeline (§7.4) assign F8 and F10 to Sprint 5 ending 2 August 2026 and describe integration finishing 7 August 2026. Chapter 1 should present the timeline as executed rather than as planned, and Chapter 10 should comment on schedule performance against it.

The PRD's data model table (§9.3) lists five conceptual collections. The delivered schema has roughly fifty-eight top-level collections. Chapter 3 replaces the table wholesale.

---

## G. Decisions taken

**Role model — decided.** Three roles: Unregistered User, Registered User (Basic / Premium), Platform Administrator. No Medical Trainer/Expert anywhere in the report. See E1.

**Feature count — decided.** Ten features, F1 to F10. The challenge subsystem is documented inside F5. See A2.

**Chapter 1 scope — decided.** Chapter 1 is the second version of the PRD rather than a short introduction. It carries PRD Sections 1, 2, 3, 4, 7, 8, 9, 10, 11 and 12 — team, market survey, project scope, business model, methodology, platform, database, languages, architecture and risk — each updated to describe the delivered system, and closes with §1.12 listing every change from the first version in one place. PRD Sections 5 and 6 become Chapter 2.

**Non-functional requirements — decided.** Chapter 2 §2.4 is the second version of PRD Section 6, keeping NF1 to NF5 with their original subjects and updating each to the delivered system, plus two additions the first version did not state as requirements: NF6 fairness of the paid tier, and NF7 operability and governance.

**Comparison table — decided by implication of the above.** The market comparison table in Chapter 1 §1.2.4 marks wearable synchronisation and heart-rate zone analysis as "not delivered" for Runiac rather than reproducing the PRD's tick marks.

**Still open.** Whether Chapter 8's pricing is presented as a proposal or as implemented configuration, given that the paywall is wired to real configuration documents and the website publishes S$5.99 monthly and S$49.99 annually, but no payment provider is integrated. This only affects Chapter 8 and can be settled when that batch is drafted.

## H. Diagrams needing revision

Chapter 2 references the use case, sequence and activity diagrams from the PRD. The following need redrawing before the document is compiled, because the behaviour they depict changed during implementation.

| Figure | Source asset | Required change |
| --- | --- | --- |
| 2.1 | `image2.png` | Remove the optional wearable device actor |
| 2.2 | `image3.png` | Submission is a callable invocation, not a Firestore write plus trigger |
| 2.4 | `image5.png` | Remove heart-rate zone analysis |
| 2.7 | `image8.png` | Replace Trainer / Medical Advisor with Platform Administrator |
| 2.11 | `image12.png` | Show device-local scheduling alongside backend dispatch |
| 2.13 | `image14.png` | Add in-application feed, friends graph and distance challenges |
| 2.14 | `image15.png` | Extend to cover feed publication and challenge lifecycle |
| 2.18 | `image19.png` | Remove the weekly consistency bonus branch |
| 2.20 | `image21.png` | Remove GeoFlutterFire indexing |
| 2.22 | `image24.png` | Remove multi-level map zoom |
| 2.26 | `image28.png` | Remove weekly and monthly experience counters |
| 2.28 | `image30.png` | Extend to include home guide and workout briefing |
