# Chapter 7: System Testing

This test plan outlines and defines the strategy and approach taken to perform formal system qualification tests on the Runiac mobile application, the Firebase backend, and the Runiac public website and Platform Administrator console.

The plan is written against the delivered system rather than against a planned one. Every result reported in Section 7.9 comes from an executed test run; where a tier of the suite has not yet been executed, it is reported as pending rather than presented as a pass.

## 7.1 Objectives

The objective of this testing is to ensure that the functions are well tested so that users will encounter minimal errors when using the system, and that the properties the project treats as non-negotiable actually hold in the running system.

Four objectives are specific to Runiac and shape the rest of the plan.

The first is that **progression cannot be forged**. Experience, level, streak, division and leaderboard score are computed by the backend and must be unwritable by a client through any path: the callable API, a direct database write, or a replayed submission.

The second is that **the paid tier confers no competitive advantage**. Premium and Basic users must pass through the identical award formula and appear on the identical leaderboard. This is the project's most distinctive commitment and it is tested explicitly rather than assumed.

The third is that **health and location data stay private**. Onboarding health answers, precise routes and private activity must not be reachable by another user, and shared route data must be coarsened before publication.

The fourth is that **AI-generated guidance stays inside its safety envelope**: no medical or diagnostic language, no references to competitive standing, no unsupported numeric claims, and a deterministic fallback whenever generation fails or validation rejects the output.

## 7.2 Approach

The test members used the Project Proposal, the Project Requirements Document and the Preliminary Technical Document to prepare the necessary test scripts and reports. Test cases were derived from the use case descriptions in Chapter 2, from the security rules, and from the server-side validation and calculation modules.

The testing phase is done in 12 suites.

- Suite 1: Identity, account status, roles, profile and avatar
- Suite 2: Run tracking, activity validation and cool-down
- Suite 3: Progression (experience, level and streak)
- Suite 4: Leaderboard aggregation, ranking and seeding
- Suite 5: Entitlement, paywall configuration and premium fairness
- Suite 6: Social (feed publication, engagement, friends and route sharing)
- Suite 7: Challenges (catalogue, lobby, contribution and settlement)
- Suite 8: Notifications (device registry, scheduling and dispatch)
- Suite 9: AI-assisted features and generated-copy safety
- Suite 10: Moderation, error reporting, feedback and administrator console
- Suite 11: Newsletter subscription and campaigns
- Suite 12: Interface, device, permissions and performance (manual)

Suites 1 to 11 are automated and target the Cloud Functions layer, because that layer owns every property listed in Section 7.1. Suite 12 is manual and covers what no automated suite can reach: permission prompts, live GPS behaviour on a physical device, push notification delivery, platform-specific capability, and the administrator console.

The manual test scripts in Annex F are organised by the sprint that delivered the functionality they verify, rather than by the automated suite numbering. This keeps the test asset aligned with the Scrum structure described in Chapter 1: each sprint's scripts verify that sprint's deliverables, and the two integration stages verify that everything delivered up to that point works together rather than only in isolation.

| Script group | Sprint | Scope | Scripts |
| --- | --- | --- | --- |
| 1.x.x | Sprint 1: MVP Foundation | Authentication, profile, onboarding, F1 run tracking | 22 |
| 2.x.x | Sprint 2: MVP Core Support | F2 analysis, F3 plan, F4 reminders | 14 |
| 3.x.x | Sprint 3: MVP Habit and Progression | F6 streak, F9 experience and levels | 8 |
| 4.x.x | MVP Integration | Core workflow end to end | 3 |
| 5.x.x | Sprint 4: Phase 2 Social and Routes | F5 social and challenges, F7 routes | 12 |
| 6.x.x | Sprint 5: Phase 2 Advanced | F8 leaderboard, F10 AI-assisted guidance | 7 |
| 7.x.x | Final Integration | Security, administration, performance, cross-platform | 9 |
| | | **Total** | **75** |

*Table 7.1: Manual test scripts by sprint*

Organising the scripts this way produced one useful side effect. Because each sprint's scripts had to account for everything that sprint delivered, writing them surfaced capability that no project document described (the cool-down flow, voice coaching, the low-data save path, character selection and the Instagram Story share among them), and each of those now has a script where previously it had neither documentation nor test.

A deliberate decision was taken to test the backend first and most heavily. The mobile client is the surface a user touches, but correctness lives in the backend. A client defect produces a bad display. A backend defect produces a wrong permanent record in a user's progression history, or an unfair leaderboard. Test effort was allocated accordingly.

## 7.3 Black box / functional testing

Black Box Testing is a testing technique of having no knowledge of the internal functionality or structure of the system. This testing technique treats the system as a black box or closed box. The tester will only know the formal inputs and projected results, and does not know how the program arrives at those results. Hence the tester tests the system based on the functional specifications given to them.

The advantages of black box testing are:

- As the tester and developer are independent of each other, the test is balanced and unprejudiced
- There is no need to have detailed functional knowledge of the system for the tester
- Tests will be done from an end user's point of view
- Test cases can be designed as soon as the functional specifications are completed

In Runiac, black box testing covers the whole of Suite 12, the callable-surface tests that exercise a Cloud Function purely through its public contract without reference to its implementation, and the access-control tests that probe what a client can and cannot reach.

## 7.4 White box testing

White Box Testing is a testing technique having knowledge of the internal functionality or structure of the system. White Box testers have access to the source code and are aware of the system architecture. A White Box tester typically analyses source code, derives test cases from knowledge about the source code, and targets specific code paths to achieve a certain level of code coverage.

The advantages of white box testing are:

- Increased effectiveness
- Reveal hidden code flaws

In Runiac, white box testing covers the calculation and validation modules: the experience formula with its per-activity cap, daily cap and streak-milestone exemption; the streak day-delta logic with its protected-rest-day branch; the payload field allow-list; the timestamp freshness clamp; and the leaderboard ordering and eligibility rules.

In conclusion, a system should consist of black box testing as well as white box testing to ensure a complete software examination of the system. Either technique alone would leave a gap in Runiac specifically: black box testing alone would not reach the interaction between the daily experience cap and the streak milestone exemption, and white box testing alone would not catch a security rule that permits a read the specification forbids.

## 7.5 Features to be tested

This plan will execute specific tests that exist in order to exercise the features provided and specified in Chapter 2 of this document, for the Runiac mobile application, the Runiac backend and the Runiac website.

### 7.5.1 Graphical User Interface Testing

| | |
| --- | --- |
| **Test Objective** | Verify the following: navigation through the application including screen to screen, field to field and use of access methods; and that screen objects and characteristics, such as menus, size, position, state and focus, conform to the design system. |
| **Technique** | Create or modify tests for each screen to verify proper navigation and object states for each application screen and object, supported by manual review on physical devices at different screen sizes. |
| **Completion Criteria** | Each screen successfully verified to remain consistent with the design system, or within acceptable standard, with no layout breakage, overlapping content, unreadable text or inaccessible controls. |
| **Special Considerations** | The onboarding flow, the application tour and the run screen are prioritised, being the screens a beginner meets first and the screen used while in motion. |

*Table 7.2: Graphical User Interface Testing*

### 7.5.2 Function Testing

The objective of these tests is to demonstrate that the functions and limiting conditions specified throughout the system requirements have been met for each function.

| | |
| --- | --- |
| **Test Objective** | Ensure proper target-of-test functionality, including navigation, data entry, processing and retrieval. |
| **Technique** | Execute each use case, using case flow or function, using valid and invalid data, to verify the following: the expected results occur when valid data is used; and the appropriate error or warning messages are returned when invalid data is used. |
| **Completion Criteria** | All planned tests have been executed. All identified defects to be addressed immediately with the action taken recorded in their respective test case document. |
| **Special Considerations** | Server-side validation is exercised with deliberately malformed payloads, including payloads carrying backend-owned fields, to confirm outright rejection rather than silent acceptance. |

*Table 7.3: Function Testing*

### 7.5.3 Security and Access Control Testing

| | |
| --- | --- |
| **Test Objective** | Verify that a user can reach only the resources their role and subscription permit; that backend-owned fields cannot be written by any client; and that administrative operations are unreachable from the mobile application. |
| **Technique** | Attempt reads and writes as an unauthenticated client, as an owner, as a non-owner, as a Basic user against premium-gated features, and as a non-administrator against administrative collections. Inspect the security rules for a deny-by-default posture. |
| **Completion Criteria** | Every unauthorised attempt refused. Every backend-owned field rejected on submission and denied at the rule layer. No collection reachable that no rule explicitly opens. |
| **Special Considerations** | Suspended, banned and deleting account states are tested separately, since they must block operations that an otherwise valid session would permit. |

*Table 7.4: Security and Access Control Testing*

### 7.5.4 Progression Fairness Testing

| | |
| --- | --- |
| **Test Objective** | Verify that Premium and Basic users earn experience under the identical formula, that neither is excluded from nor advantaged on the leaderboard, and that no subscription-conditional branch in the experience path grants an advantage. |
| **Technique** | Compute an award for identical activity data under both subscription states and compare. Inspect the leaderboard eligibility filter for subscription-based exclusion. Verify the configuration defaults that govern both. |
| **Completion Criteria** | Awards identical under both subscription states. Both tiers present on the same board. The only subscription-conditional branch confirmed to suppress rather than enhance, and confirmed inactive by default. |
| **Special Considerations** | This is the project's central fairness claim, so it is tested directly rather than inferred from the absence of a defect report. |

*Table 7.5: Progression Fairness Testing*

### 7.5.5 Generated Content Safety Testing

| | |
| --- | --- |
| **Test Objective** | Verify that AI-generated guidance contains no medical or diagnostic language, no references to experience, level or ranking, and no unsupported numeric claims; and that the system falls back to deterministic copy when generation fails or validation rejects the output. |
| **Technique** | Exercise the output validators against strings containing medical terms, diagnosis phrasing and over-length content. Exercise the evidence model to confirm only supplied fact identifiers are used. Simulate provider unavailability and confirm fallback. |
| **Completion Criteria** | Every prohibited pattern rejected by the validator. Fallback copy produced on every failure path. Quota and consent gates enforced before generation. |
| **Special Considerations** | Prompt-injection resistance is tested by placing instruction-like text in user-controlled plan fields and confirming it is treated as display data rather than as instruction. |

*Table 7.6: Generated Content Safety Testing*

### 7.5.6 Performance Testing

| | |
| --- | --- |
| **Test Objective** | Verify that common read operations complete within two to three seconds, that activity synchronisation completes within five to ten seconds, and that leaderboard rankings are served from pre-aggregated records rather than recomputed per request. |
| **Technique** | Time the dashboard load, activity history load, leaderboard load, run submission and summary generation on a physical device under normal network conditions. Inspect the leaderboard read path for client-side computation. |
| **Completion Criteria** | Measured timings within the stated targets. No client read observed to trigger a ranking computation. |
| **Special Considerations** | Timings are recorded per device, since a mid-range Android device and a recent iPhone are not comparable. |

*Table 7.7: Performance Testing*

### 7.5.7 Features Not to be Tested

Three areas are outside the scope of this test plan and are recorded here so that their absence is not mistaken for a gap in execution.

Third-party service internals are not tested. Firebase Authentication, Firestore, Cloud Messaging, Mapbox rendering and the language model provider are treated as trusted dependencies; testing verifies Runiac's use of them, not their own correctness.

Payment processing is not tested, because no payment provider is integrated. Subscription state exists and is enforced, but it is set administratively rather than purchased.

Neither Android Health Connect nor Apple Health workout import is tested, because no wearable or health-platform import path is delivered. The iOS path was built and then withdrawn before submission, so there is no user-reachable behaviour to verify.

## 7.6 Item Pass/Fail Criteria

The test items detailed above, as the targets of this test plan, will be tested for the Runiac mobile application, backend and website.

The system will be deemed to have **passed** testing if:

- All tests defined have been executed, and
- The number of tests executed without any defects is more than 95% of the total, and
- Any defects detected have a severity classification of Low.

The system will be deemed to have **failed** testing if:

- The number of tests executed with defects is more than 5% of the total, or
- There are defects with a severity classification of High.

In addition, and overriding the percentage criteria above, any defect that allows a client to write a backend-owned progression field, that grants a subscription-based advantage in experience or ranking, or that exposes another user's health or precise location data is classified High regardless of how infrequently it occurs, and its presence fails the release.

## 7.7 Test Deliverables

The following documents are generated by the test members and are created after test completion. The test scripts are generated, signed and attached in the testing document (Annex F). A copy is also appended in the construction document.

- Test Plan
- Test Scripts
- Test Summary Reports
- Captured execution logs, written to `test-evidence/reports/` in the project repository

## 7.8 Test Environment

The whole Runiac project can be seen as three areas: the mobile application, the backend services, and the web interface comprising the public site and the administrator console.

**Backend and automated suites.** Node.js 22 with the Firebase Emulator Suite providing Authentication, Firestore, Cloud Functions and Cloud Storage. Suites are executed through the npm scripts defined in the functions package, which start the emulator, run the suite and shut the emulator down.

**Mobile application.** Since Runiac is a cross-platform Flutter application, testing must cover both mobile platforms. Platform-specific behaviour differs materially between them, so the two are not interchangeable for test purposes.

| Platform | Delivered behaviour requiring separate verification |
| --- | --- |
| Android | Foreground run-tracking service with foreground-service-location permission; native haptics; plan notification receiver and scheduler; runtime notification permission |
| iOS | Live Activity on the lock screen and Dynamic Island during a run; Instagram Story sharing channel |
| Both | GPS tracking, cadence estimation from phone motion, voice coaching, plan reminder scheduling |

*Table 7.8: Platform-specific test coverage*

The operating systems for testing the application are as follows:

- Android: at least one physical device, one small-screen and one large-screen where available
- iOS: at least one physical device, required for Live Activity verification

**Website and administrator console.** Executed in current versions of Chrome and Safari on desktop, against the emulator for data.

**Documentation environment.** Part of the automated execution reported in Section 7.9 was performed in an isolated environment without access to the Firebase emulator binaries. That limitation and its consequence are described in Section 7.9.2.

**Manual execution environment as used.** The seventy-five manual scripts in Annex F were executed on 6 August 2026 in the environment below. It differs from the environment planned above in two respects, both of which materially affected the result.

| Item | As executed |
| --- | --- |
| Application build | Flutter 3.44.0, debug build for the iOS Simulator, built with the production dart-defines |
| Devices | Five iOS 26.5 simulators: iPhone 17, iPhone 17 Pro, iPhone 17e, iPhone Air, iPhone 17 Pro Max |
| Backend | Production Firebase project `runiac-fypp`. No emulator was used, so every server-side result is the real deployed behaviour |
| Method | Scripted user-interface execution against the accessibility tree, driven by `idb` and `simctl`, with screenshots retained for visual assertions |
| Streams | Six streams in parallel, each owning one simulator and its own test accounts, so no stream's server state could disturb another's |

*Table 7.9: Manual execution environment*

The two departures from plan are that **no physical device and no Android device were available**. Neither is a matter of convenience: the plan calls for a physical iOS device because the simulator cannot produce genuine movement, and for Android because the foreground tracking service, native haptics and the runtime notification permission exist only there. The consequences are quantified in Section 7.9.1 and their cause is explained in Section 7.9.2.

## 7.9 Test Summary Report

The Cloud Functions suite comprises **84 test files** distributed across Suites 1 to 11. These divide into two tiers by what they require in order to run.

The **pure-logic tier** exercises calculation, validation, contract, policy and model code with no Firebase service attached. These files were executed and their results are reported below.

The **service-integration tier** requires a running Firebase Emulator Suite, because the code under test reads or writes the database, mints authentication tokens, or invokes a callable over HTTP. These files could not be executed in the documentation environment and are marked pending.

| Suite | Files | Executed | Pending | Assertions passed | Failures |
| --- | --- | --- | --- | --- | --- |
| Suite 1: Identity, account and profile | 10 | 7 | 3 | 80 | 0 |
| Suite 2: Run tracking and validation | 4 | 1 | 3 | 8 | 0 |
| Suite 3: Progression (XP, level, streak) | 5 | 4 | 1 | 62 | 0 |
| Suite 4: Leaderboard aggregation | 11 | 11 | 0 | 23 | 0 |
| Suite 5: Entitlement, paywall, fairness | 4 | 4 | 0 | 92 | 0 |
| Suite 6: Social (feed and friends) | 13 | 8 | 5 | 76 | 0 |
| Suite 7: Challenges | 9 | 3 | 6 | 62 | 0 |
| Suite 8: Notifications | 3 | 1 | 2 | 9 | 0 |
| Suite 9: AI features and safety | 13 | 13 | 0 | 70 | 0 |
| Suite 10: Moderation, errors, feedback | 7 | 6 | 1 | 21 | 0 |
| Suite 11: Newsletter | 5 | 5 | 0 | 53 | 0 |
| **Total** | **84** | **63** | **21** | **556** | **0** |

*Table 7.10: Cloud Functions test execution by suite*

The seventy-five manual scripts in Annex F were executed on 6 August 2026 against the production backend. The executed copy of the annex records the observed Actual Result for every step; nothing in it is inferred from source code or carried over from a passing automated test. The results by sprint group are as follows.

| Script group | Sprint | Scripts | P | F | O | BLOCKED |
| --- | --- | --- | --- | --- | --- | --- |
| 1.x.x | Sprint 1: MVP Foundation | 22 | 12 | 3 | 2 | 5 |
| 2.x.x | Sprint 2: MVP Core Support | 14 | 6 | 0 | 1 | 7 |
| 3.x.x | Sprint 3: MVP Habit and Progression | 8 | 0 | 0 | 0 | 8 |
| 4.x.x | MVP Integration | 3 | 0 | 0 | 0 | 3 |
| 5.x.x | Sprint 4: Phase 2 Social and Routes | 12 | 3 | 2 | 0 | 7 |
| 6.x.x | Sprint 5: Phase 2 Advanced | 7 | 3 | 2 | 2 | 0 |
| 7.x.x | Final Integration | 9 | 6 | 1 | 1 | 1 |
| | **Total** | **75** | **30** | **8** | **6** | **31** |

*Table 7.11: Manual script results by sprint group*

| Script | Defect observed | Severity assessment |
| --- | --- | --- |
| 1.3.2 Onboarding comparison case | On one account the personal-details step was skipped after sign-up, and no path in the application can reopen it: "Edit answers" returns only to the sixteen-step questionnaire, and a relaunch reports that no account setup exists while sign-up refuses the email as taken. The account is left permanently unusable. Reproduced three times on that account; the trigger for the initial skip was not isolated | **High.** A user who hits it cannot recover without support intervention |
| 1.3.4 Application tour for an unregistered visitor | No tour entry point exists on the welcome or sign-up screen. The tour auto-arms only on completing sign-up and onboarding | **Documentation defect rather than a product one.** The behaviour is coherent; the requirement was wrong. Chapter 2 has been corrected |
| 1.4.3 Live tracking with pause and resume | The run auto-paused within one to five seconds of every start and would not stay resumed. Reproduced across four independent runs | **Environment.** Same root cause as the blocked group; recorded as a fail because the script's steps could not be satisfied. The Live Activity integration was positively confirmed working during the same attempt |
| 5.2.2 Block and unblock a user | A blocked user's runner profile (level, league, streak, total distance, badge case) remained fully reachable from search by the blocking party's counterpart account. Only the friend-request action was refused | **Medium, and possibly by design.** No route or activity content was exposed. It is a direct mismatch against the written expectation and needs a design-intent decision, not necessarily a fix |
| 5.3.1 Distance challenge lifecycle | Once a lobby reaches two of two accepted but not started, the Challenge tab fails to load for **both** participants with "Something went wrong. Please try again.", and does not recover across a relaunch. The challenge could not be started | **High.** This is a functional break in a delivered feature, reproduced on four attempts and observed on both accounts. **Fixed 2026-08-07**, driven by this execution result: the client parsed a roster row's `levelLabelSnapshot` strictly, so one member who had never completed a run — and therefore carried no backend-resolved level — failed the whole `getActiveChallenge` response for everyone in the lobby. Regression-tested; the script itself awaits re-execution, so Annex F still records F |
| 6.2.1 AI activity feedback: safety and quota | Two failures. The sixth generation in a day returned fallback copy without communicating a reset time. On a Basic account, activity feedback opened the Premium paywall rather than the deterministic template copy the requirement describes | **Medium.** The refusal degrades gracefully in both cases; what is missing is the reset-time message. The Basic-tier behaviour is a requirement error, corrected in Chapter 2 |
| 6.2.3 AI workout briefing | The sixth briefing in a day returned generic copy with no reset-time message, as in 6.2.1 | **Medium.** Same defect, second surface |
| 7.4.1 Interface responsiveness across screen sizes | At the largest accessibility text size the live run screen overflowed its distance row by 62 pixels and the cool-down screen by 117, rendering Flutter's debug overflow indicator over the readout and putting the Skip control out of reach | **Medium.** Reproducible layout defect, confined to the largest Dynamic Type setting |

*Table 7.12: Defects raised by manual execution*

Two of the eight are environment or documentation artefacts rather than product defects. **Five are genuine and are carried into Chapter 9**: the unrecoverable onboarding state, the challenge-lobby load failure, the missing quota reset message, the blocked-profile visibility question and the accessibility text-size overflow.

**Six scripts returned an observation rather than a verdict.** In each of these the objective was met but a step could not be independently confirmed. The leaderboard aggregation cycle cannot be triggered on demand within a session; the AI home guide caches for a day, so its unavailable path cannot be forced; and the performance timings are simulator measurements on a debug build, so they cannot support a pass or fail against a release-build target. They are recorded as observations rather than passes.

**One script produced a finding that no test asked for.** Script 5.5.1 set out to browse the separate community route library and found no navigable entry point to it anywhere in the application. A read-only source check confirmed that `MapsTab`, `SharedRoutesSheet` and `SavedRoutesScreen` exist under `lib/features/maps/presentation/` but that the shell's five-item navigation routes the third slot to the run launch screen, and that no menu item, named route or navigation call anywhere reaches the maps feature. That library is backed by demonstration data and, in the delivered build, is unreachable. Chapter 2 Section 2.6.7 has been corrected to describe F7 as it is actually delivered, through the Activity Feed. This was the most consequential finding of the manual execution.

The table below maps each functional requirement to the test assets that exercise it, so that coverage can be judged per feature rather than only in aggregate. "Executed" counts only assets that have been run; "authored" counts assets that exist but await a development machine.

| Requirement | Backend assets | Client assets | Manual scripts | Manual result | Assessment |
| --- | --- | --- | --- | --- | --- |
| F1 Run tracking and activity data | 4 files (Suite 2) | ~65 files | 1.4.1–1.4.8 | 3 P, 1 F, 4 BLOCKED | **Weak as executed.** Three of four backend files are pending, and no qualifying run could be completed on a simulator |
| F2 Analysis | included in Suite 2 | advanced-analysis and summary mappers | 2.1.1–2.1.5 | 2 P, 1 O, 2 BLOCKED | Summary structure confirmed; metric values confirmed only from the production record |
| F3 Plan generation and scheduling | 1 file | 5 plan-generator files plus onboarding resolvers | 1.3.1–1.3.3, 2.2.1–2.2.5 | 4 P, 1 F, 3 BLOCKED | Generation and preview confirmed on the device; session completion blocked. Script 2.2.5 targets a goal-plan feature the delivered build does not offer |
| F4 Reminders | 3 files (Suite 8) | ~18 files | 2.3.1–2.3.4 | 2 P, 2 BLOCKED | Weak as executed |
| F5 Social, sharing and challenges | 22 files (Suites 6, 7) | ~44 files | 5.1.1–5.4.2 | 3 P, 2 F, 5 BLOCKED | Good breadth in the automated tier; the manual tier found a functional break in the challenge lobby |
| F6 Streak and consistency | included in Suite 3 | none (backend-owned) | 3.1.1–3.1.4 | 4 BLOCKED | Correctly backend-only; **no manual evidence at all** |
| F7 Route sharing through the Activity Feed | **0 files** | 1 static-UI file | 5.5.1, 5.5.2 | 2 BLOCKED | **Uncovered.** The scripts targeted the separate route library, which the manual run established is unreachable; the delivered feed path is covered by 5.1.1, itself blocked |
| F8 Leaderboard | 11 files (Suite 4) | ~6 files | 6.1.1–6.1.3 | 2 P, 1 O | **Strong** |
| F9 Experience and level progression | 5 files (Suite 3) | ~6 files | 3.2.1–3.2.4 | 4 BLOCKED | Automated coverage strong; **no manual evidence**, corroborated only from the production record |
| F10 AI-assisted guidance | 13 files (Suite 9) | overlay and payload builders | 6.2.1–6.2.4 | 1 P, 2 F, 1 O | Automated coverage strong; the manual tier found the missing quota reset message |
| NF1 Security and access control | entitlement, roles, account status | premium-gate widget tests | 7.1.1–7.1.3, 7.2.2 | 4 P | **Rules layer itself untested**, but every executed access check held |
| NF6 Fairness of the paid tier | 4 files (Suite 5) | paywall gate tests | 2.1.4, 5.3.2, 7.2.1, 7.2.3 | 4 P | **Strong**, and corroborated by a configuration change observed in the production record |

*Table 7.13: Test coverage by functional requirement*

Four observations follow from this table and are carried into Section 7.9.2 and 7.9.3.

**The strongest coverage sits where the project's distinctive claims live.** Leaderboard aggregation, experience progression, fairness and generated-content safety are all fully executed with no failures. That is the correct place for the effort to have gone, since those properties are invisible to a user and permanent in effect.

**The weakest executed coverage sits on the most core journey.** The run-completion path (submit, validate, award, write the leaderboard contribution) is concentrated in Suite 2, and three of its four files are in the pending tier because they require the emulator. Until those run, the single most important user journey in the application has one executed test file behind it. The cause is where the emulator boundary falls rather than how the suite was designed, but the current executed figure should not be read as covering the core flow.

**F7 has no coverage at all, and investigation of that gap revealed that the scripts were written against the wrong thing.** No backend test file references shared routes, and the only client test is a static interface test. Examining why found that the shared-routes collection stores no coordinates, no code path can move a route to published status, and the browsing interface reads demonstration data. Manual execution then established something the source reading had not: the maps area has no navigable entry point at all in the delivered build. The delivered form of this requirement is publication to the Activity Feed, which the F7 scripts do not target at all. This is recorded in Chapter 2 Section 2.6.7 and carried into Chapter 9.

**Manual execution reached a different part of the system from the automated suite, and found different things.** The automated tier is concentrated on the backend, where it found no failures. The manual tier is the only tier that touches navigation, layout, permission prompts and the paths a user actually walks, and all five of the genuine defects in Table 7.12 were found there. None of them would have been caught by a Cloud Functions test, because none of them is a backend defect.

### 7.9.1 Conclusion

- 84 Cloud Functions test files were generated, together with 277 Flutter test files and 75 manual test scripts organised by sprint.
- 63 test files (75% of the Cloud Functions suite) have been executed and generated a PASS, producing 556 passing assertions and no assertion failures.
- All 75 manual scripts were executed against the production backend on 6 August 2026: **30 passed, 8 failed, 6 returned an observation and 31 were blocked.**
- 298 automated test files remain pending execution on a development machine, so the overall pass criterion in Section 7.6 cannot yet be evaluated across the whole asset.
- Of the eight manual failures, five are genuine product defects and are carried into Chapter 9; the other three are an environment limitation and two requirement errors that have been corrected in Chapter 2 rather than raised against the code.
- Testing has hardened the system and made it more reliable. Defects found during integration have been fixed by the respective developers.

Thirty-one of seventy-five scripts is a large fraction, and the blocked group falls disproportionately on F6 and F9 (streak and experience progression), which have **no manual execution evidence whatsoever**. The claim that those features work rests on the automated calculator tests and on the record-derived corroboration below. A physical device would resolve almost all of it, and Section 7.9.3 carries that as the first improvement.

**Corroboration from the production record.** Because the manual run used the production project rather than an emulator, several outcomes the simulator could not reach were instead read directly from the `activities` collection for the project owner's account, covering sixteen runs performed on a physical iPhone. They are record-derived evidence rather than user-interface observations, and are reported as such. Four of them matter here. In all four of the most recent runs, elapsed wall time minus moving duration equals paused duration exactly, so pausing on a real device does stop the moving clock. Average pace equals duration divided by distance in every run, so the summary arithmetic is internally consistent. Every activity carries backend-owned fields the client never writes (`validationStatus`, `validatedActivityContributionState`, `processedAt` and a `payloadFingerprint`), with the award recorded as a server reason code. Finally, the 20 July run carries `countsTowardProgression: false` with reason `premium_no_progression` while every run from 22 July onward carries `run_completion_xp_awarded`, and no application release falls between them. Award behaviour therefore changed through a Firestore configuration document alone, which is what script 7.2.3 claims.

That last item also produced a finding about the project's own fairness rule. While `config/progression.premiumEarnsXp` was `false`, a Premium runner's qualifying activity was recorded as not counting toward progression. The project's stated invariant is that paying changes the scoring formula in neither direction, and suppressing Premium experience changes it in the disadvantage direction. The condition is absent from the current configuration and the affected window appears bounded by the 20 and 22 July activities, but the episode shows the invariant is enforced by convention in the configuration rather than by a constraint that would refuse such a setting. Section 7.9.3 carries that as an improvement.

Four findings from the executed portion are stated individually below, because they correspond to the objectives in Section 7.1.

**Progression cannot be forged.** The payload validation tests confirm that a submission carrying any backend-owned field (experience, totals, weekly or monthly experience, streak, level, rank, score, subscription status, role or validation status) is rejected outright rather than sanitised and accepted. The same field set is independently denied at the security-rule layer, so neither path is open.

**The paid tier confers no advantage.** The entitlement and configuration tests confirm that experience earning is enabled for Premium users and leaderboard exclusion is disabled, so both tiers use the identical formula on the identical board, and that the sole subscription-conditional branch in the experience path suppresses rather than enhances and is inactive by default.

**Generated content stays in its envelope.** Suite 9 executed in full: 13 files, 70 assertions, no failures. The validators reject medical and diagnostic phrasing and over-length output; the evidence model confirms only supplied fact identifiers reach the prompt; and the fallback path produces deterministic copy on every failure route.

**Award arithmetic is correct at its boundaries.** The progression calculator tests cover the per-activity cap, the daily cap, the interaction between the daily cap and the streak-milestone exemption, the cool-down bonus rounding and clamping, and the level-band thresholds. These are the places where an off-by-one would silently corrupt a user's permanent record.

### 7.9.2 Problems Faced

- **The iOS Simulator cannot produce a run.** This is the single largest problem the test phase encountered and it invalidated forty per cent of the manual asset. `simctl location` delivers position updates correctly, and the application's own instrumentation confirmed it was receiving them at roughly one hertz (`distanceDeltaM=3.01, impliedSpeedMps=3.00, speedMps=0.00`), but CoreLocation's `speed` field is never populated on a simulator. The movement classifier's distance-based fallback is written to apply only when speed is *absent*, and a reported `0.0` is present, so the fallback never engages and every sample is classified as stationary drift. Raising the simulated speed to fifteen metres per second changed nothing: all 87 samples still reported `speedMps=0.00`. The consequence was that no qualifying run existed, and twenty-seven scripts whose pre-requisite is a completed activity could not start. The correct fix is a physical device rather than a change to the application. The investigation did raise a further question: iOS reports `-1` for an invalid reading, and the same predicate would treat `-1` exactly as it treats `0.0`. Whether genuine GPS degradation on a physical device can stall tracking through that path was not established and is recommended for verification.

- **No physical device and no Android device were available to the test session.** The plan in Section 7.8 calls for both, and neither was obtainable within the schedule. Beyond the blocked group above, this left the Android-only capability entirely unverified (the foreground tracking service, native haptics and the runtime notification permission), and script 7.5.1, cross-platform parity, could not be attempted at all. Coverage of screen-size variation was approximated instead by stress-testing one simulator with system appearance and Dynamic Type settings, which is what surfaced the layout overflow in Table 7.12. That is a reasonable substitute for text scaling, but not for a second physical screen.

- **Two scripts could not be executed for want of a Platform Administrator account.** Granting a Premium entitlement has no self-serve path from the client, by design, so advanced analysis for a Premium user and the feed moderation flow were both unreachable. The access control is working correctly and the test environment is incomplete; the remedy is a staging account rather than a change to the system.

- **The Firebase emulator could not be provisioned in the documentation environment.** The environment used to prepare this report has restricted network access, and the Firebase CLI fetches its emulator binaries on first use from a host that policy blocks. Java and the CLI itself were present, so the obstacle was specifically the binary download. The consequence was that 21 service-integration files could not be run there. Rather than report an untested suite as passing, or omit it, the suite was split into two tiers and each reported separately. The pending tier is executed on a development machine, where the emulator cache already exists.

- **Test files that require a service fail in a way that resembles a defect.** When run without the emulator, the pending files report connection refusals and missing application default credentials, and some report a small number of passing assertions before failing. Reading those partial counts as results would have inflated the reported total by 37 assertions. The summary therefore counts only files that ran to completion, and the partial figures are discarded.

- **A platform capability was initially recorded as missing because it is native rather than a package.** An early review concluded from the Flutter dependency manifest alone that the application had almost no native integration, because none of it appears there. Inspecting the iOS and Android project directories surfaced eight native method channels: cadence estimation and its event stream, the Android foreground tracking service, the iOS Live Activity, haptics, notification permissions, plan reminder scheduling and Instagram Story sharing. None of them appear in any earlier project document. The same inspection settled the Apple Health question in the other direction: the entitlement is declared and a Dart-side channel name exists, but no native handler was ever written, which is part of why that capability was withdrawn. The error affected the accuracy of Chapters 1 and 2 before it was caught, and the point to carry forward is that a dependency manifest is unreliable evidence of what native integration a cross-platform application does or does not contain.

- **A feature with no tests turned out to be a feature the scripts had mis-scoped.** F7, community route sharing, had no backend test file and only a static interface test on the client. Rather than write tests against it, the team examined why the gap existed and found that the collection carries no route geometry, that no code path sets a route to published status, and that the maps interface reads demonstration data. The test plan had correctly identified an area with no coverage, but it had not asked why, and the answer changed a requirement's delivery status. Chapters 1 and 2 were corrected as a result. An untested area is therefore worth investigating before test writing is scheduled against it, since the absence of tests is sometimes evidence about the code rather than about the suite.

- **No Firestore security rule specifications exist.** The repository contains a package manifest for rules testing but no specification files. Access control is therefore verified indirectly, through the entitlement and ownership tests in the Cloud Functions suite and through inspection of the rules themselves. This is a genuine gap and is recorded in Section 7.9.3 rather than presented as covered.

### 7.9.3 Improve Test Assets

The purpose of this activity is to maintain and improve test assets. Five improvements would materially strengthen the suite, listed in the order they would repay the effort.

- **Write Firestore security rule specifications.** This is the largest gap. The rules file is roughly fourteen hundred lines and carries a substantial share of the system's access control, yet nothing tests it directly. A specification suite built against the rules-unit-testing library should cover, at minimum: owner and non-owner reads on every user-scoped collection; the backend-owned-key rejection on the profile document; the published-only constraint on feed reads; the query result limits; and the deny-by-default catch-all.

- **Obtain a physical device and re-run the blocked group.** Thirty-one scripts are blocked and twenty-seven of them share one cause that a real phone removes. Nothing else on this list would improve the evidence base as much for as little effort, and until it is done the two requirements the project treats as most distinctive have no manual execution record.

- **Add a regression case for each of the five genuine defects.** The manual run produced real failures for the first time: the unrecoverable onboarding state, the challenge-lobby load error, the missing quota reset message, the blocked-profile visibility question and the accessibility overflow. Each should gain a test that reproduces it before the fix lands, so that the suite grows against observed failures as well as anticipated ones. Three of the five are reachable from a widget or integration test without a device.

- **Constrain the fairness-critical configuration rather than trusting it.** The production record shows a configuration state that disadvantaged Premium users while the project's stated invariant forbids advantage in either direction. A validation rule that refuses to save such a configuration, or a test that asserts the invariant against the live document, would turn a convention into a constraint.

- **Re-use the reusable.** In our case, test assets that can be re-used are:
  - The authenticated-user setup helper
  - The run payload builder used across the validation tests
  - The emulator seeding helpers
  - The deterministic AI provider used to make generated-copy tests repeatable
  - The challenge lobby state fixtures

  Consolidating these as shared fixtures would shorten the writing of the rule specifications recommended above.

### 7.9.4 Achievements

The automated tier achieved a 100% pass rate across the portion that could be executed: 556 passing assertions and no assertion failures across 63 Cloud Functions test files, comfortably inside the projected 5% failing rate. The manual tier gives a different figure. Of the 44 scripts that could be executed at all, 30 passed, 8 failed and 6 returned an observation, a pass rate of 68%.

The achievement the team considers most significant is that the project's central claims became testable at all. The decision to make every trusted field backend-owned, and to enumerate those fields in both the callable validator and the security rules, is what allows the fairness and anti-tampering properties to be demonstrated by test rather than asserted by inspection. That decision paid twice over: script 7.1.1 confirmed it from the client's side against the production backend, and the stored activity records confirmed it independently, since every activity carries server-written validation fields and a server reason code that no client path can produce. Had entitlement been enforced only by hiding controls in the client, the claim in Chapter 2 that Premium confers no competitive advantage would have rested on a reading of the source rather than on evidence.

The second achievement is that executing the manual scripts changed the report. Five statements in Chapter 2 described behaviour the delivered system does not have: the unregistered-visitor tour, deterministic AI copy for Basic users, the communicated quota reset, blocking hiding a profile, and a reachable community-route library. Each was a plausible reading of the source code and each was wrong. They were corrected because the application was walked through rather than read.

Both black box and white box testing have stressed the system and improved its reliability. The remaining work is genuinely split: 298 automated cases await a development machine with the emulator and Flutter toolchain, and 31 manual scripts await a physical device. Neither is a matter of authorship, since the assets exist for all 361 automated cases and all 75 manual scripts.
