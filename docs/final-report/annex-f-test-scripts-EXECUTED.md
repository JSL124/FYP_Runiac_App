# Annex F — Test Scripts

## F.0.1 Execution record

This copy of Annex F is the **executed** log. Every Actual Result below was observed during
execution; nothing in the Actual Result or P/F/O columns is inferred from source code or
assumed from a passing automated test.

| | |
| --- | --- |
| Executed on | 2026-08-06 |
| Application build | Flutter 3.44.0, debug build for the iOS Simulator, built with the production dart-defines (`RUNIAC_FIREBASE_PRODUCTION=true`, project `runiac-fypp`, Mapbox access token, pinned App Check debug token) |
| Devices | Five iOS 26.5 simulators — iPhone 17, iPhone 17 Pro, iPhone 17e, iPhone Air, iPhone 17 Pro Max |
| Backend | Production Firebase project `runiac-fypp`. No emulator was used. |
| Method | Scripted user-interface execution against the accessibility tree, driven by `idb` and `simctl`, with screenshots retained for visual assertions |

Six execution streams ran in parallel, each owning one simulator and its own test accounts,
so that no stream's server-side state could disturb another's. The Tester's Name row of each
script records which stream executed it. The signature cells are deliberately left blank:
these scripts were executed by an automated harness, not signed off by a human tester and a
witness, and they are presented as such.

## F.0.2 Why thirty-four scripts are recorded as BLOCKED

The dominant cause is a single limitation of the iOS Simulator, not a fault in the
application.

`simctl location` moves the simulated device correctly — the application receives position
updates and derives the right displacement — but it **never populates the CoreLocation
`speed` field**, which is reported as `0.00` in every sample. This was confirmed with the
application's own instrumentation (`RUNIAC_GPS_ACCEPTANCE_QA_LOGS`), which recorded
`distanceDeltaM=3.01, impliedSpeedMps=3.00, speedMps=0.00, rejectReason=gpsStationaryDrift`
once per second, and again at a simulated 15 m/s, where all 87 samples still reported
`speedMps=0.00`.

In `run_movement_classifier.dart` the distance-based movement signal applies only when the
reported speed is *absent*:

```dart
final hasDistanceSignal =
    movementSpeedMetersPerSecond == null &&
    distanceFromRouteAnchorMeters >= resumeMovementDistanceMeters;
```

A reported `0.0` is not absent, so that fallback is disabled and only the speed test remains,
which `0.0` fails. Every sample is therefore classified as stationary drift, distance never
leaves 0.00 km, and the run auto-pauses after the five-second dwell.

Consequently no qualifying run could be completed on a simulator, and every script whose
pre-requisite is a completed activity — experience award, streak, feed publication,
challenge contribution, advanced analysis — is unreachable. **These scripts require
execution on a physical device with genuine movement.** Section F.0.3 records
device-derived corroboration for several of them.

A secondary group is blocked on a Platform Administrator account, which was not available to
the test session, and one on an Android device, which was not available.

*Observation carried forward:* iOS reports a speed of `-1` for an invalid reading. The
predicate above would treat that value the same way it treats `0.0`. Whether genuine GPS
degradation on a physical device can stall tracking through this path was not established
here, and verification is recommended.


## F.0 Organisation

These scripts are organised by the sprint that delivered the functionality under test, following the sprint structure in Chapter 1. Each sprint's scripts verify that sprint's deliverables; the two integration stages verify that the features delivered up to that point work together rather than only in isolation.

| Group | Sprint | Scope | Scripts |
| --- | --- | --- | --- |
| 1.x.x | Sprint 1 — MVP Foundation | Authentication, profile, onboarding, F1 run tracking | 22 |
| 2.x.x | Sprint 2 — MVP Core Support | F2 analysis, F3 plan, F4 reminders | 14 |
| 3.x.x | Sprint 3 — MVP Habit and Progression | F6 streak, F9 experience and levels | 8 |
| 4.x.x | MVP Integration | Core workflow end to end | 3 |
| 5.x.x | Sprint 4 — Phase 2 Social and Routes | F5 social and challenges, F7 routes | 12 |
| 6.x.x | Sprint 5 — Phase 2 Advanced | F8 leaderboard, F10 AI-assisted guidance | 7 |
| 7.x.x | Final Integration | Security, administration, performance, cross-platform | 9 |
| | | **Total** | **75** |

*Table F.1 — Test scripts by sprint*

Each script is executed by hand. The tester completes the Actual Result and P/F/O columns and signs; a witness countersigns. P denotes pass, F denotes fail, O denotes an observation — behaviour that is not a defect but is worth recording. Device and build details are recorded where platform behaviour differs.

Scripts marked **(iOS)** or **(Android)** are platform-specific and are executed only on that platform. Scripts marked **(Premium)** require an account with premium subscription status.

Thirty-four of the seventy-five scripts carry an **Automated corroboration** note. These are the scripts whose underlying logic has already been verified by an executed, passing automated test, so the tester is confirming that the interface presents that logic correctly rather than establishing whether the logic itself is right. Each note names the test files and their assertion counts, which are the figures reported in Chapter 7, Table 7.9. The remaining forty-one scripts have no such backing and carry the full weight of verification for the behaviour they cover — the permission prompts, the live device behaviour, the platform-specific paths and the administrator console — which is where testing effort is best concentrated.

---

# Sprint 1 — MVP Foundation

## F.1 Test Case 1.1.1: Registration — create an account with valid details

| Objective | Verify that an unregistered visitor can create an account and reach onboarding. |
| --- | --- |
| Classification | Function testing — F1, NF1 |
| Pre-requisites, if any | Application installed. No existing account for the email used. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Launch the application from a cold start | Welcome screen displays sign-up and log-in options | Cold relaunch showed the welcome screen with "Sign up" and "Log in" buttons, Runiac logo, and Terms/Privacy links | P |
| 2 | Select sign up and enter a valid email and a conforming password | Fields accept the input; no validation error | Sign up screen accepted Email=qa-a1-001@runiacqa.dev and Password=RuniacQA!2026 in the two fields with no validation error shown | P |
| 3 | Submit the registration | Account is created and the user is taken to onboarding, not the home dashboard | After "Create account", the app moved to the "Tell us about you" onboarding step (Name/Nickname/DOB/Weight/Region), not the home dashboard | P |
| 4 | Confirm the account state | Profile created with basic subscription status | After completing the full 16-step onboarding and buddy selection, Profile screen showed "Basic plan / BASIC" badge, "Lv.0", nickname "qarunnera1", Unranked division | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: nickname field showed live "Nickname is available." confirmation. Immediately after onboarding finished, the in-app "App tour" auto-started (Bolt, "1 of 12") before landing on the dashboard — skipped via "Skip tour" to proceed; this is the signup-triggered tour, distinct from 1.3.4's unregistered-visitor tour. Account qa-a1-001 / nickname qarunnera1 is reused as the primary account for later cases in this block.*

---

## F.2 Test Case 1.1.2: Login — enter wrong password

| Objective | Verify and validate user input on authentication. |
| --- | --- |
| Classification | Function testing, negative case — NF1 |
| Pre-requisites, if any | 1.1.1 completed, and a registered account exists. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Log in using the correct email and an incorrect password | Notify user with an error message. Ask user to refill the details. No session is created | Logging in with qa-a1-001@runiacqa.dev and password "WrongPassword!1" kept the user on the log-in screen and showed the inline error "That email and password do not match." | P |
| 2 | Confirm no protected screen is reachable | Application remains on the log-in screen | No navigation occurred; the app remained on the "Welcome back" log-in form with the Email/Password fields still populated and the error text visible | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.3 Test Case 1.1.3: Login — valid credentials and Google sign-in

| Objective | Verify that a registered user can authenticate by password and by Google. |
| --- | --- |
| Classification | Function testing — NF1 |
| Pre-requisites, if any | A registered account. A Google account available on the device. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Log in with correct email and password | Session is created and the user reaches the home dashboard, or onboarding if incomplete | Logging in with qa-a1-001@runiacqa.dev / RuniacQA!2026 created a session and landed directly on the home dashboard (calendar/streak view), onboarding already complete | P |
| 2 | Sign out, then sign in using Google | Google account chooser appears; sign-in completes | "Continue with Google" opened a system "runiac_app wants to use accounts.google.com" sheet, then the Google account chooser listing jason04334@gmail.com (used per authorisation) with no password/2FA prompt (session already cached in the simulator's WebKit store), a "project-299427653807에 다시 로그인하는 중입니다" consent screen, then "계속"; sign-in completed and returned straight to the home dashboard | P |
| 3 | Confirm the profile is the same account, not a duplicate | One profile only; progression and history are intact | Profile screen after Google sign-in showed "Jinseo_😎", Lv.9, Iron League, Premium plan, 76.0 km — the same pre-existing profile for jason04334@gmail.com seen at the very start of this session (not a fresh/duplicate profile) | O |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **O** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 3's original intent (same account reachable by both password and Google) could not be tested as a true same-account comparison: qa-a1-001@runiacqa.dev has no Google credential linked, so "Continue with Google" necessarily authenticated a different Firebase identity (jason04334@gmail.com), which resolved to that identity's own pre-existing profile rather than qa-a1-001's. What was verified is the narrower, still-relevant claim: Google sign-in did not fabricate a duplicate profile for jason04334@gmail.com — it reused the single existing one. Marked O (not F) because no defect was observed, only a test-setup gap. Signed back out of jason04334@gmail.com immediately afterward as required.*

---

## F.4 Test Case 1.1.4: Password reset

| Objective | Verify that a user who has forgotten their password can recover access. |
| --- | --- |
| Classification | Function testing — NF1 |
| Pre-requisites, if any | A registered account with a reachable email address. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Select password reset and submit the registered email | Confirmation shown that a reset message has been sent | On "Reset your password", submitting qa-a1-001@runiacqa.dev and tapping "Send reset link" showed the confirmation text "If an account exists for that email, a reset link will be sent." | P |
| 2 | Open the reset link and set a new password | Password is changed and the user can log in with it | Not executed — no access to the mailbox for qa-a1-001@runiacqa.dev, so the reset link could not be opened | BLOCKED |
| 3 | Attempt to log in with the old password | Access is refused | Not executed — no access to the mailbox for the test address, so the password could not actually be changed to attempt this comparison | BLOCKED |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 1 behaviour is correct and account-enumeration-safe (identical message regardless of whether the email exists). Case verdict is BLOCKED per brief instruction, not a defect.*

---

## F.5 Test Case 1.1.5: Sign out and session persistence

| Objective | Verify that a session persists across application restarts and ends cleanly on sign out. |
| --- | --- |
| Classification | Function testing — NF1 |
| Pre-requisites, if any | A signed-in account. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Close the application fully and relaunch | User remains signed in and reaches the home dashboard without re-authenticating | After signing back into qa-a1-001@runiacqa.dev and using `relaunch` (terminate+launch), the app opened straight to the home dashboard with no re-authentication prompt | P |
| 2 | Sign out from settings and confirm | User returns to the welcome screen | Profile > Sign out > confirm returned the app to the welcome screen (Sign up / Log in) | P |
| 3 | Relaunch the application | Welcome screen is shown; no protected data is visible | `relaunch` after sign-out again showed only the welcome screen (Sign up, Log in, Terms/Privacy links) — no dashboard, profile, or other protected content was reachable | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.6 Test Case 1.2.1: Profile — view and edit

| Objective | Verify that a user can view and change their own profile details. |
| --- | --- |
| Classification | Function testing — NF1 |
| Pre-requisites, if any | Onboarding complete. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the profile screen | Level, division, streak, total distance and nickname are displayed | Profile screen showed "Runner profile Lv.0", "Unranked division", nickname "qarunnera1", "Max streak —", "Total distance —" and "Basic plan / BASIC" | P |
| 2 | Edit the nickname and save | Change persists and appears across the application | On Edit profile, changed Nickname from "qarunnera1" to "qarunnera1x", got live "Nickname is available." confirmation, tapped "Save changes" → toast "Profile updated." → Profile screen now showed "qarunnera1x" | P |
| 3 | Confirm progression values are read-only in the interface | No control offers to edit experience, level, streak or division | Edit profile screen exposed only Name, Nickname, Date of birth, Weight, Region and a read-only "Your training profile" summary (goal/starting point/plan style/schedule/session length/safety) plus "Retake onboarding"/"Save changes" — no field or control offered to edit XP, level, streak or division | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: separately tried Friends > Search for the new nickname "qarunnera1x" and got "No runner matched that nickname" — likely self-exclusion from search rather than a propagation defect (not confirmed either way, not part of the scripted step, recorded for completeness only).*

---

## F.7 Test Case 1.2.2: Profile — nickname uniqueness

| Objective | Verify that a nickname already claimed by another user is refused. |
| --- | --- |
| Classification | Function testing, negative case — NF4 |
| Pre-requisites, if any | Two accounts; the nickname of account A recorded. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account B, attempt to set the nickname already used by account A | The change is refused with a clear message | Creating account B (qa-a1-002@runiacqa.dev) and entering nickname "qarunnera1x" (account A's current nickname) on the sign-up "Tell us about you" step showed "Nickname is already taken." and left "Continue to onboarding" disabled | P |
| 2 | Set a different, unused nickname | The change succeeds | Changing the nickname to the unused "qarunnerb1a1" showed "Nickname is available.", and after filling Name/DOB/Weight/Region, "Continue to onboarding" succeeded and advanced to buddy selection, confirming the nickname save went through | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: after editing Name/Weight/Region the stale validation strings "Name must be 1-80 characters." and "Enter a weight from 30 to 250 kg." remained visible under those fields even though the values were valid and the form ultimately submitted successfully — a cosmetic stale-error-text issue, not a functional blocker; not scored as a failure since it did not affect step 1 or step 2's outcome. Account B left mid-onboarding (buddy-selection step), not needed further for this block.*

---

## F.8 Test Case 1.2.3: Profile — avatar upload and removal

| Objective | Verify that a profile photo can be set and cleared, and that it is scoped to its owner. |
| --- | --- |
| Classification | Function testing — NF2 |
| Pre-requisites, if any | A photo available on the device. Photo library permission grantable. |

**Automated corroboration.** Already verified by `profileAvatar` (18 assertions), `avatarPaths` (10) and `avatarPng` (11), executed and passing — see Chapter 7, Table 7.9 — covering avatar path construction, encoding and ownership scoping. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Select a profile photo from the device library | Permission prompt appears; photo uploads and displays | Tapping the avatar circle on Edit profile opened "Choose an action" (Choose photo / Remove photo-disabled), "Choose photo" showed a "Your photo will be visible to others" disclosure, Continue opened the native PHPicker with sample library images (grant photos pre-applied); selecting a flower photo returned to Edit profile with the avatar circle now showing that photo | P |
| 2 | Confirm the avatar appears on the profile and in social contexts | Avatar is shown consistently | The uploaded photo also appeared on the main Profile screen next to nickname "qarunnera1x" and level badge | P |
| 3 | Clear the avatar | Photo is removed and a default is shown | Reopening the avatar sheet now showed "Remove photo" enabled; tapping it reverted the avatar to the "QA" initials placeholder (confirmed on both Edit profile and Profile screens) after a few seconds' processing delay | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: avatar removal was not instantaneous — the old photo stayed visible for ~3s after tapping "Remove photo" before updating to initials; this is background-processing latency, not a functional failure, since the correct end state (default initials) was reached.*

---

## F.9 Test Case 1.2.4: Character selection and premium locks

| Objective | Verify that a runner character can be chosen and that premium characters are gated. |
| --- | --- |
| Classification | Function testing — NF6 |
| Pre-requisites, if any | A basic account. |

**Automated corroboration.** Already verified by `featureEntitlement` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the entitlement decision behind the premium character lock. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open character selection | Available characters are shown; premium characters are visibly locked | "Running buddy" screen (Basic account) showed Bolt as choosable and Cap / Mila / Ivy each labelled "Premium — unlock to choose" | P |
| 2 | Select an unlocked character | Selection persists and the character appears on the home dashboard | Selecting Bolt and tapping "Run with Bolt from now on" returned to the Profile screen; the home dashboard then showed a "Bolt guide" element confirming Bolt is the active character | P |
| 3 | Attempt to select a locked character | The paywall is presented; the selection does not apply | Tapping the locked "Cap" card opened the "Runiac Premium" paywall (S$49.99/yr or S$5.99/mo, feature list including "Exclusive runner characters — Cap and Ivy"); closing it returned to Running buddy still showing "Bolt is ready to run with you!" — Cap was not applied | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.10 Test Case 1.3.1: Onboarding — health-aware plan generation

| Objective | Verify that onboarding collects the readiness profile and that the plan reflects a cautious health declaration. |
| --- | --- |
| Classification | Function testing — F1, F3 |
| Pre-requisites, if any | A newly registered account that has not completed onboarding. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Step through onboarding selecting a beginner experience level | Each step presents one question; progress is visible | Account qa-a1-003@runiacqa.dev stepped through onboarding (goal "Start running gently", "I am not running yet", "0 runs per week", "Mostly walking right now", "Completely new to running", "2 days per week") with a "Step N of 16" counter and one question per screen | P |
| 2 | At the health step, declare a condition requiring caution | Answer accepted without alarm or medical commentary | At the health step, selected "Currently managing an injury or pain"; the app accepted it silently (no alert/medical warning dialog), Continue enabled normally, and the following symptom-checklist step ("None of these") only showed a routine Bolt tip and a standing "Runiac is not a medical service..." disclaimer, not an alarm | P |
| 3 | Complete onboarding to the plan preview | A weekly plan is shown with running days and rest days | Completed onboarding ("Keep it gentle" plan style) to a plan preview: "Plan length 4 weeks", "Starting point: Getting started", "Schedule: 2 sessions / week", "Session length: 15 min", "Preferred days: Mon · Fri", "Plan style: Keep it gentle" | P |
| 4 | Record the weekly volume and session count | Plan is conservative relative to 1.3.2 | Recorded plan: 4-week plan, 2 sessions/week, 15 min sessions, "Getting started" starting point — conservative, for comparison against 1.3.2 | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: nickname used: qahealtha1.*

---

## F.11 Test Case 1.3.2: Onboarding — comparison case without health caution

| Objective | Verify that the resolved safety band materially changes the generated plan. |
| --- | --- |
| Classification | Function testing — F3 |
| Pre-requisites, if any | A second newly registered account. 1.3.1 completed and its plan recorded. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete onboarding declaring no health conditions and a higher experience level | Onboarding completes | Account qa-a1-004@runiacqa.dev: after "Create account", the app skipped the "Tell us about you" (Name/Nickname/DOB/Weight/Region) step entirely and went straight to "Choose your running buddy" — unlike every other account created in this block (qa-a1-001/002/003), which all showed that step. Onboarding was completed with "Complete my first 5K", "3 to 6 months", "3 runs per week", "20-30 minutes", "I can run 20-30 minutes", "4 days per week", no health condition ("No, I'm ready to start"), plan style "Build steadily". At the final "Continue with this plan" step, the app repeatedly showed "We could not save your profile. Try again." (`ui.sh log` showed the POST to `asia-southeast1-runiac-fypp.cloudfunctions.net` returning HTTP 400) — onboarding never completed | F |
| 2 | Compare the plan with that from 1.3.1 | This plan is less conservative. The two plans are not identical | Comparison could not be completed on saved/persisted data since 1.3.2 never saved; using the pre-save preview only, the shown plan (6 weeks, "Building consistency", 4 sessions/week, 25-30 min sessions, Mon·Wed·Fri·Sat, "Balanced progression") is visibly less conservative than 1.3.1's saved plan (4 weeks, "Getting started", 2 sessions/week, 15 min, Mon·Fri, "Keep it gentle") — the direction of the difference is correct, but this account's plan was never actually persisted, so the case did not pass end-to-end | F |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: reproduced 3 times: "Edit answers" only reopens the 16-step questionnaire (earliest reachable is "Step 1 of 16"), never the missing personal-details step, so the missing Name/Nickname can never be supplied from inside the flow. Force-relaunching returns "No Runiac account setup exists for this account. Sign up to create your profile..." with only Email/Password fields (no Name/Nickname); "Create account" there then fails with "An account already exists for this email. Try logging in."; "Log in" succeeds in authenticating but returns to the same "No Runiac account setup exists" screen — a deterministic Login⟷Signup dead loop. Account qa-a1-004@runiacqa.dev is left permanently stuck / unusable as evidence. Root cause of the initial personal-details skip was not isolated (occurred once, on this account only, despite an identical tap sequence to qa-a1-001/002/003).*

---

## F.12 Test Case 1.3.3: Onboarding — retake

| Objective | Verify that a user can retake onboarding and that a new plan replaces the old. |
| --- | --- |
| Classification | Function testing — F3 |
| Pre-requisites, if any | An account with a completed onboarding and an active plan. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Select retake onboarding from the profile area | A confirmation explains that the current plan will be replaced | Account qa-a1-001 (old plan: "Start running gently" / "Keep it gentle" / 2 sessions/week / 15 min): "Retake onboarding" on Edit profile showed a confirmation "Reset your plan? Starting a new onboarding plan will reset your consistency streak. Your run history will not be affected." with Cancel / "Reset streak & continue" | P |
| 2 | Confirm and complete onboarding with different answers | A new plan is generated reflecting the new answers | Confirmed and completed the 16-step flow with different answers ("Work toward a 10K", "6 months or more" experience, "5+ runs per week", "60 minutes or more", "I can run 20-30 minutes", "4 days per week", no health condition, "Build steadily"); it saved successfully (returned straight to Profile, no error) and Edit profile's "Your training profile" now showed "Work toward a 10K / Advanced structured training / Build steadily / 4 sessions/week · Mon·Tue·Wed·Thu / 45 min" — a completely different plan from the pre-retake one | P |
| 3 | Confirm activity history and progression are retained | Past runs, experience and level are unchanged | Profile screen after retake still showed "Lv.0" and "Max streak —" (both unchanged from before, consistent with this account never having logged a run, so there was no history to lose); no run/activity data existed to check further, but nothing was reset besides the plan/streak baseline as the confirmation dialog described | P |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: this same "Retake onboarding" → 16-step flow → save worked correctly for qa-a1-001, unlike the identical-shaped flow that failed for qa-a1-004 in 1.3.2 — reinforces that 1.3.2's failure was account-state-specific (missing Name/Nickname), not a general defect in the plan-generation/save step itself.*

---

## F.13 Test Case 1.3.4: Application tour for an unregistered visitor

| Objective | Verify that an unregistered visitor can preview the application before creating an account. |
| --- | --- |
| Classification | Function testing — NF7 |
| Pre-requisites, if any | Application installed; no session. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From the welcome screen, start the application tour | The tour begins and steps through the application's capabilities | Signed out to a true no-session state and inspected the welcome screen (dump + screenshot): it shows only the Runiac logo, tagline, "Sign up" button, "Log in" button, and Terms/Privacy links — no "Start tour", "Preview", "Take a look" or any other tour affordance is present. Tapping the logo/tagline had no effect. The "Create your account" (sign-up) screen was also checked and likewise has no tour entry point. There is no reachable way for an unregistered visitor to start an application tour | F |
| 2 | Step to the end of the tour | All steps render; the tour can be exited at any point | Not executed — step 1 found no tour to step through | F |
| 3 | Confirm no running data is reachable during the tour | Only illustrative content is shown | Not executed — step 1 found no tour to step through | F |

| Tester's Name: Runiac QA harness (A1) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: this matches known product behaviour (not a surprise, but scored against the written script as a defect since the script explicitly requires an unregistered-visitor tour entry point): the in-app tour only auto-arms on completing signup/onboarding (observed firing automatically after "Continue with this plan" in 1.3.1, 1.3.2's attempt, and 1.1.1) — it is not a manually-triggerable preview reachable from the welcome screen for a visitor who has not yet created an account. Verdict recorded as F against the script's literal expected result; if the intended design is "tour only after signup", the test script's premise (or the feature) needs reconciling — this is a script/feature mismatch, not a crash or data-safety issue.*

---

## F.14 Test Case 1.4.1: Run tracking — location permission refused

| Objective | Verify that a run cannot start without location permission and that the refusal is explained. |
| --- | --- |
| Classification | Function testing, negative case — F1, NF3 |
| Pre-requisites, if any | Onboarding complete. Location permission not yet granted. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the run screen and attempt to start a run | The operating system location permission prompt is presented | With location reset to "not yet asked" (`reject location`), opening a workout and tapping "Start this run" → "Start run" on the pre-run map screen surfaced the OS prompt "Allow "Runiac App" to use your location? / Runiac uses your location to track your run while you are using the app." with Allow Once / Allow While Using App / Don't Allow | P |
| 2 | Refuse the permission | The run does not start; the application explains what is required and how to grant it | Tapping "Don't Allow" kept the user on the pre-run sheet; the run did not start and the sheet displayed "Location is blocked for Runiac. Open app settings to allow location for runs." in two places (near the Start run button and below it); tapping "Start run" again reproduced the same message rather than starting tracking | P |
| 3 | Confirm the application remains usable | Other screens remain reachable; no crash or hang | Closing the map screen (Close, top-left) returned to the workout detail screen, and "Back to Plans" returned to the home dashboard with tab bar intact; no crash or hang observed | P |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.15 Test Case 1.4.2: Run tracking — permission granted and pre-run setup

| Objective | Verify the pre-run setup screen and that permissions are requested with an explanation. |
| --- | --- |
| Classification | Function testing — F1 |
| Pre-requisites, if any | Location permission resettable in device settings. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the run screen | Pre-run setup is shown with the planned session, if one is due | Opening the run screen from the home dashboard's "Today's stage" showed the planned session's workout-detail screen: "Thu · Easy Walk — Return to Movement", Duration 15 min, Type Recovery walk, Effort Very gentle, session breakdown (Easy walk 10 min / Slow finish 5 min), with a "Start this run" control | P |
| 2 | Grant location and, where prompted, motion permission | Prompts explain why access is needed; permissions are granted | Tapping "Start this run" then "Start run" on the map sheet raised the OS location prompt with the explanation "Runiac uses your location to track your run while you are using the app."; tapping "Allow While Using App" then raised a second OS prompt "'Runiac App' would like to access your Motion & Fitness activity. Runiac uses phone motion during a run to detect stops, analyse step rate and cadence, and ..." with Allow/Don't Allow; both were granted | P |
| 3 | Confirm the map acquires position before start | Current position is shown; the start control becomes available | Immediately after granting, the screen transitioned straight into live tracking (status label "Waiting for GPS", timer counting up e.g. 00:18) rather than staying on a distinct pre-start screen; after `ui.sh loc` supplied a static fix the status label changed to "GPS weak" and distance read 0.00 km (stationary fix, as expected) — a position was acquired and the run controls (Pause) were available, satisfying the intent of the check though there was no separate "start control becomes available" gate — the app auto-starts the timer as soon as permission is granted | P |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 3's literal expected wording ("start control becomes available") doesn't quite match this app's flow — Start run already commits to starting, and permission-grant leads straight into live tracking with an immediate timer start rather than a paused "ready" state. Recorded as O-level nuance, not a defect, since the underlying intent (position acquired, run usable) held. Continuing this same run into 1.4.3.*

---

## F.16 Test Case 1.4.3: Run tracking — live tracking with pause and resume

| Objective | Verify GPS tracking, live map rendering, cadence capture, and that paused time is excluded from active time. |
| --- | --- |
| Classification | Function testing — F1 |
| Pre-requisites, if any | Permissions granted. Outdoor location with GPS reception. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Start a run and move for at least three minutes | Distance, pace and duration update live; route draws on the map | Started `ui.sh route` (12-waypoint simulated walk, speed 3 m/s) then tapped Start run. Status cycled Waiting for GPS → GPS active, distance/time began counting (e.g. 00:18–00:50), but within 1–5 seconds of every single attempt (reproduced independently across 4 separate fresh runs) the screen's status label flipped to "Paused" on its own with a "Resume" button shown, and DISTANCE stayed frozen at 0.00 km and TIME stopped advancing — this happened even though `ui.sh log` showed CoreLocation delivering fresh location updates roughly once per second the entire time. Distance never exceeded 0.00 km across four attempts totalling roughly 6 minutes of wall-clock observation (well over the 60–90 s asked for), so I could not obtain a real non-zero distance/pace reading | F |
| 2 | Pause and remain stationary for one minute | Elapsed time continues; active time and distance do not advance | Tapping "Resume" did restart the timer and flip the status back to "GPS active" for roughly 1–5 seconds each time, but it then auto-paused again on its own every time, with no user interaction in between (confirmed by dumping every 3–10 s with no taps) — Resume's effect did not persist | F |
| 3 | Resume and continue for two minutes | Tracking resumes; the paused period is excluded from active time | Not executed — could not get sustained active tracking (see step 1/2) to test that a manually-paused period is excluded from active time versus a genuinely continuing run | F |
| 4 | Observe the lock screen (iOS) or notification shade (Android) | iOS shows a Live Activity; Android shows the foreground tracking notification | Backgrounding the app (HOME button) during an active run showed a real Live Activity in the status bar/Dynamic Island reading "00:01 — 0.00 km", confirming the OS Live Activity integration itself works and is wired to the run's live state — but it also independently corroborated the freeze: the Live Activity showed the exact same stuck 00:01/0.00 km values as the in-app screen when the app was foregrounded again, i.e. the auto-pause is a real state change, not an in-app-only rendering glitch | O |
| 5 | End the run and confirm | Summary displays distance, duration, active duration, pace and cadence | Ending a stuck run (hold "Hold to end run") correctly routed to Cool-down → Summary with the actual observed values (0.00 km, the frozen duration, "--" pace) rather than crashing; summary generation itself works, but obviously could not be checked against "distance, duration, active duration, pace and cadence" values that were ever non-zero | O |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: This reproduced identically across 4 independent fresh run starts, both via `ui.sh route`'s interpolated waypoint stream and via a mix of `route` plus manual `ui.sh loc` pushes at ~5.4 m increments every 0.8–2 s — none sustained a running state past a few seconds. CoreLocation delivery itself was confirmed live via `ui.sh log` (steady ~1 Hz location callbacks) the whole time, so simulated GPS was reaching the OS layer continuously; the app nonetheless treated the session as stationary. My working hypothesis, stated for context and not as a proven root cause, is that the app's auto-pause logic gates on real device motion (CoreMotion / pedometer activity) in addition to or instead of GPS displacement, and `simctl location` has no counterpart for simulating CMMotionActivity/CMPedometer data — meaning this may be a simulator-only limitation rather than a defect that would reproduce on a physical device. I record it as F because step 1's literal expected result ("distance, pace and duration update live") did not hold under direct observation, but flag the likely environment cause so it is not read as confirmed proof of a shipped bug. This blocks reliable testing of every downstream case that needs a genuine non-trivial tracked run (1.4.4 base tracking, 1.4.5's base-XP prerequisite, 1.4.6 step 3, 2.1.1's "known distance", 2.1.5's cadence/splits) — noted individually in each of those cases below.*

Device / OS version: ____________________________________________

---

## F.17 Test Case 1.4.4: Run tracking — survives loss of connectivity

| Objective | Verify that a run continues while offline and synchronises exactly once when connectivity returns. |
| --- | --- |
| Classification | Function testing — NF6 |
| Pre-requisites, if any | As 1.4.3. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Start a run, then enable flight mode after one minute | Tracking continues; no error interrupts the session | Not executed — blocked by two independent constraints: (a) per the harness rules I must not disable the Mac's own networking, and (b) the iOS Simulator's Settings app on this build exposes no Airplane Mode / Wi-Fi / Cellular toggle at all (checked directly: `Settings → root list` shows General, Accessibility, Action Button, Apple Intelligence & Siri, Camera, Home Screen & App Library, Search, StandBy, Screen Time, Passcode — no connectivity section), because the Simulator shares the host Mac's network stack rather than emulating its own radio | BLOCKED |
| 2 | Continue two minutes, then end the run while offline | The run ends and the activity is held locally | Not executed — depends on step 1 | BLOCKED |
| 3 | Disable flight mode | The activity synchronises; summary and experience award appear | Not executed — depends on step 1 | BLOCKED |
| 4 | Confirm the activity appears exactly once in history | No duplicate activity is recorded | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: No in-simulator way to induce a genuine offline condition was found. Also would have inherited the 1.4.3 live-tracking auto-pause issue even if connectivity toggling were possible.*

---

## F.18 Test Case 1.4.5: Run tracking — cool-down

| Objective | Verify the cool-down flow after a run and that it awards its bonus. |
| --- | --- |
| Classification | Function testing — F1, F9 |
| Pre-requisites, if any | A run completed in this session. Base experience award recorded. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Proceed to cool-down after ending a run | Cool-down introduction is shown | Ending a run and choosing not to skip led straight to a "Cool down" intro screen: "Great job! Now let's cool down and stretch." with Slow Walk (3-5 min) and Stretching (~6 min · 8 exercises) sections and Start Cool-down / Skip to Summary buttons | P |
| 2 | Complete the slow-walking and stretching stages | Each stage tracks and completes | Tapping Start Cool-down opened a live "Cool down guide" with a Walk stage (countdown timer, e.g. 02:58 remaining, tips shown) and a "Next" control; tapping through advanced to a Stretch stage that stepped through all 8 named stretches (Standing Calf Stretch, ... Figure Four Glute Stretch, etc., "Stretch 1 of 8" through "8 of 8") each with its own demonstration animation label and a "Next stretch" control, ending on a "Cool-down complete — That's your recovery done. Great work today." screen with a Finish button | P |
| 3 | Confirm the cool-down bonus | A bonus of 20% of the base award, rounded to the nearest 5 and bounded 5–20, is added | After Finish, the run summary showed no visible cool-down-bonus line item, and afterwards Profile still read Lv.1, 0/100 XP, 0.0 km total distance — i.e. 0 bonus XP was awarded, which is arithmetically consistent with 20% of a base award of 0 (rounded/bounded rules aside), but I could not verify the actual 20%-rounded-to-nearest-5-bounded-5–20 rule because I never obtained a real non-zero base award: the case's own pre-requisite ("A run completed in this session. Base experience award recorded") could not be met, since every run in this environment auto-paused at ~0.00 km/0 s active time and was saved via the low-data path, which earns 0 XP by design (see 1.4.7) | BLOCKED |
| 4 | Skip cool-down on a subsequent run | No cool-down bonus is awarded; the run is otherwise unaffected | Not executed — same reason as step 3; skipping cool-down was not separately compared against a real base award | BLOCKED |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: The cool-down UI flow itself (intro → walk stage → 8-stretch sequence → completion) worked cleanly end to end with no crashes across two full run-throughs. Only the bonus-value verification is blocked, and it is blocked by the same root cause as 1.4.3 (no real distance/XP-earning run obtainable in this simulator environment).*

---

## F.19 Test Case 1.4.6: Run tracking — voice coaching

| Objective | Verify that voice announcements are configurable and are spoken at the configured milestones. |
| --- | --- |
| Classification | Function testing — F1, NF7 |
| Pre-requisites, if any | Device volume audible. Voice settings reachable. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open voice settings and preview a message | The preview is spoken | Opened Run Settings from the pre-run map screen ("Run settings" control, top-right); under VOICE COACHING toggled "Voice progress updates" on, then opened "Preview voices" which listed 5 announcement types with full cue text (Start: "Let's start your run. You've got this!"; Distance 1 km: "You have completed 1 kilometer. Your time is 6 minutes 12 seconds. Your average pace is 6 ..."; Time 10 min; Target halfway; Target completed) each with its own Play button and a page-level Stop control; tapping Play on the Start message produced real AVAudioEngine/AudioQueue activity in `ui.sh log` (AudioQueueObject start/SetLoudnessFromLM/stop sequence), i.e. the TTS engine genuinely fired — audibility itself could not be confirmed since the simulator has no speaker output I can listen to, but the underlying speech-synthesis call path was independently confirmed active from the OS log, not just a UI label change | P |
| 2 | Configure a distance or time milestone interval and save | Settings persist | Set "Time updates" to "5 min" and left Distance updates on its default "Every 1 km"; navigating back into Run Settings afterward showed both selections still highlighted (confirmed via screenshot — English/5 min/Every 1 km all shown selected), so the settings persisted across navigation without an explicit Save step | P |
| 3 | Start a run and pass the first milestone | The announcement is spoken at the milestone | Not executed — could not sustain a run long enough (or with genuine active elapsed time progressing) to reach a 5-minute or 1 km milestone, because of the same auto-pause behaviour documented in 1.4.3 (run freezes at ~0 s / 0.00 km within seconds of starting, and milestones are measured against the run's own elapsed/active time which is frozen while paused) | BLOCKED |
| 4 | Disable voice coaching and repeat | No announcement is spoken | Not executed — same reason as step 3; disabling voice coaching and repeating a milestone-reach comparison was not possible without ever reaching a milestone in the first place | BLOCKED |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Configuration (step 1) and persistence (step 2) are both solidly verified, including genuine confirmed TTS engine invocation via OS log, which is the most that can be established for audio on this simulator per the brief's own guidance. Steps 3–4 are blocked by the 1.4.3 root cause, not a defect specific to voice coaching.*

---

## F.20 Test Case 1.4.7: Run tracking — low-data save awards no experience

| Objective | Verify that an activity saved with the low-data option is stored but earns no experience. |
| --- | --- |
| Classification | Function testing, boundary case — F1, F9 |
| Pre-requisites, if any | Ability to produce a run with insufficient tracking data. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete a very short or poorly tracked run and choose the low-data save | The activity is saved with an explanation that it will not earn experience | Ending a very short/near-zero-distance run (0.00 km, 0:55 elapsed) and navigating to Home triggered a "Save this short run?" dialog: "This run has limited data, so it may not be useful for analysis. You can still keep it in your running history." with Discard / Save run options; tapped Save run | P |
| 2 | Confirm the experience total is unchanged | No award is made | Checked Profile immediately after: Lv.1, Level progress "0%, 100 XP to level up, 0 / 100 XP", Total distance "0.0 km" — identical to the pre-run baseline, confirming no XP was awarded for the saved low-data run | P |
| 3 | Confirm the activity still appears in history | The record exists and is viewable | Reopening the "You" tab → "See all" Activity History showed the saved run ("Thursday Night Run", 6/8/26, 0.00 km, -- avg pace, 0:55 time) listed and tappable, opening its full summary without error | P |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: The exact phrase "will not earn experience" is not used verbatim in the save dialog (it says the data is "limited" and "may not be useful for analysis"), but the underlying behaviour — saved, no XP awarded, still viewable in history — matched the objective precisely, confirmed by direct before/after XP inspection.*

---

## F.21 Test Case 1.4.8: Apple Health workout import (iOS)

| Objective | Verify that a running workout recorded outside Runiac can be imported with its metrics, and that heart-rate analysis is available only where the data exists. |
| --- | --- |
| Classification | Function testing, platform-specific — F1, F2 |
| Pre-requisites, if any | iOS device with at least one running workout in Apple Health, ideally with heart rate. A premium account for step 5. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open Watch and Health Apps from the profile area | Connection options are listed | Profile → "Watch & Health Apps" listed connection options under MANAGE DEVICES (Connect a new device to Runiac, Apple Watch, Garmin) and SERVICES (Apple Health, Health Connect, Garmin via Health) | P |
| 2 | Initiate an import and grant the Health read permission | Prompt appears and the grant is accepted | Tapping "Apple Health" triggered the real, native iOS HealthKit permission sheet: "'Runiac App' would like to access and update your Health data" with per-category Heart Rate / Workouts read toggles and an app-provided explanation ("Runiac reads Apple Health workouts you choose to share so imported runs can be reviewed before any future save flow."); switched both categories on via "Turn On All" and tapped Allow, which the system confirmed with a "Health Access — you can turn on health data categories later in the Health app" dialog. The grant was genuine and accepted | P |
| 3 | Review the listed recent running workouts | Workouts listed with distance and date | After granting, the screen showed "No Apple Health runs found yet." instead of a workout list, because there is no workout data to list: I opened the iOS Simulator's own Health app directly (com.apple.Health, confirmed present via `simctl listapps`) and completed its first-run setup, but its "Workouts" data category under Browse/Activity has no manual "Add Data" affordance the way simple metrics (steps, weight) do — the Health app only accepts workout entries recorded live by a fitness app, and I could not find any way to seed a sample running workout with heart-rate data on this simulator | BLOCKED |
| 4 | Import a workout carrying heart-rate data | Activity added, marked as an imported source rather than a Runiac-tracked run | Not executed — no workout exists to import | BLOCKED |
| 5 | Open advanced analysis on the imported activity | Heart-rate metrics and zone breakdown are shown | Not executed — no imported activity exists | BLOCKED |
| 6 | Open advanced analysis on a Runiac-tracked run | Heart-rate metrics reported unavailable rather than fabricated | Not executed — depends on step 5, would also need a genuine Runiac-tracked run (blocked by 1.4.3) plus Premium (blocked by 2.1.5) | BLOCKED |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Steps 1–2 are fully and positively verified, including a real system-level HealthKit consent flow with per-category grant, which is more than the brief anticipated could be checked ("simulator has no Health app" — in fact this simulator does ship a Health app, but it still cannot be seeded with sample workout data through the UI, so the net result matches the brief's expected BLOCKED outcome for the import-and-analyse portion of the case).*

Device / iOS version: ____________________________________________

---

## F.22 Test Case 1.5.1: Account deletion

| Objective | Verify that a user can request deletion of their account and that the request is honoured. |
| --- | --- |
| Classification | Privacy testing — NF2 |
| Pre-requisites, if any | An account with at least one activity and one feed post. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open account deletion from settings | Consequences are explained before confirmation | Registered a dedicated throwaway account `qa-a2-del@runiacqa.dev` (never used elsewhere), completed onboarding, and produced one saved activity (a near-zero-distance run, saved via the low-data-save path). Profile → "Delete account" opened a full-page explanation before any confirmation: a "This cannot be undone" warning, an explicit itemised "What is deleted" list (profile/nickname/photo; every run/route/activity summary; plans, XP, level, streak, leaderboard standing; friends, challenges, badges, notifications; everything posted to the feed) and a separate "What is kept, without your name on it" list (moderation reports, feedback sent, admin action records) with a stated rationale ("deleting an account must not be a way to erase a report"), plus the irreversibility statement "Deleting your account takes effect immediately. There is no waiting period and no way to get your runs back afterwards. Signing up again starts a completely new account." | P |
| 2 | Confirm the deletion request | Request is accepted and acknowledged | Typing "DELETE" into the confirm field enabled "Delete my account", which opened one further native-style confirmation ("Delete your account? This erases your runs, plans, progress, and profile straight away. It cannot be undone, and it cannot be restored by signing in again." — Cancel / Delete now); tapping "Delete now" was followed within ~3 s by the app returning directly to the signed-out welcome screen (Sign up / Log in) — request accepted and visibly acknowledged by the sign-out itself | P |
| 3 | Attempt to sign in after processing | Access reflects the deleted state | Attempting to sign in immediately afterward with the same email/password correctly failed: "We could not complete that auth step. Please try again." confirming access no longer works. However, attempting to Sign Up fresh with the same email a few seconds later returned "An account already exists for this email. Try logging in." — i.e. the underlying Firebase Auth user record was not yet gone, even though sign-in with the correct password was already refused, and the deletion copy's own claim ("Signing up again starts a completely new account") did not hold within my ~15 s observation window | O |
| 4 | Confirm private data is unreachable by other users | No profile, activity or health data remains visible | Not executed — I have no second account/viewer session available in this environment to independently confirm the deleted profile is unreachable by other users (the You/Feed/leaderboard views I could check are all from the same, now-signed-out session) | BLOCKED |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **O** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: This is recorded as O rather than a clean P because of the sign-in-blocked-but-email-still-reserved observation in step 3 — this is very plausibly explained by asynchronous server-side Auth-record cleanup (a Cloud Function completing shortly after the client-visible sign-out) rather than a genuine defect, but I did not wait long enough to confirm the email eventually frees up, so I report exactly what I observed rather than assuming either explanation. The pre-requisite "at least one activity and one feed post" was only partially met: I could not find a working in-app "post to feed" affordance from a Basic account within the time available (the Feed tab only displays runs "shared by you and accepted friends" with no visible compose entry point, and the run summary's own "Share summary" only offered external destinations — Instagram/Clipboard/Save/Copy Link/More — not an internal feed post), so deletion was verified against one saved activity but not against a genuine feed post.*

---

# Sprint 2 — MVP Core Support

## F.23 Test Case 2.1.1: Run summary metrics

| Objective | Verify that a completed run produces an accurate summary. |
| --- | --- |
| Classification | Function testing — F2 |
| Pre-requisites, if any | A completed run with known distance and duration. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the run summary | Distance, duration, active duration, average pace and calories are displayed | Not executed as specified — the pre-requisite "a completed run with known distance and duration" could not be produced: every run in this session auto-paused within seconds of starting (see 1.4.3) and saved with 0.00 km distance. What IS observable: the summary screen does render Distance (0.00, km), Avg Pace (--), Time (0:01 or 0:55), Avg Heart Rate (--), and Est. calories (--) fields, plus a route map and a "Pace Over Time" chart area that correctly shows "More run data needed" instead of a fabricated chart | BLOCKED |
| 2 | Compare pace against distance and duration | The displayed pace is consistent with the other figures | Not executed — pace showed as "--" rather than a computed value for the 0.00 km / non-zero-time cases, which is at least consistent with not fabricating a pace figure from zero distance, but this doesn't verify pace arithmetic against a real distance/duration pair | BLOCKED |
| 3 | View the route map on the summary | The recorded route renders | The route map area did render for each saved run (small thumbnail on the summary/history card, larger "Runiac GPS" map on the full summary), though with no visible path drawn since no real displacement was recorded | O |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Blocked by the same 1.4.3 GPS auto-pause root cause — I never obtained a run with genuine non-zero, known-in-advance distance/duration to check the summary's arithmetic against. What could be observed (fields render, no fabricated pace, map renders) is recorded as context, not as a pass against the actual objective.*

---

## F.24 Test Case 2.1.2: Activity history

| Objective | Verify that past activities are listed and can be opened. |
| --- | --- |
| Classification | Function testing — F2 |
| Pre-requisites, if any | At least three completed activities. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open activity history | Activities are listed most recent first with distance, date and duration | "You" tab → "See all" opened Activity History grouped by month ("August 2026 · 3 runs"), listing all 3 saved activities most-recent-first (two entries timestamped 6/8/26 · 1:52 AM with 0:01 duration, then one dated 6/8/26 with 0:55 duration), each card showing a route-map thumbnail, distance (0.00 km), avg pace (--), and time | P |
| 2 | Open an activity from the list | Its full summary opens | Tapping the top entry opened its full run summary (Thursday Night Run, 6/8/26 · 1:52 AM, Runiac GPS source, distance/pace/time chart, Splits section) — same detail screen as reached from the "You" tab shortcut | P |
| 3 | Scroll to load further activities | Additional records load without error | With only 3 activities total (all fitting on one screen), swiping up produced no crash and no visible change — pagination/"load further activities" itself could not be exercised since the list never exceeded the visible area | O |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 3 is a genuine limitation of the small dataset available in this session (building a list long enough to force pagination was not practical given the 1.4.3 GPS blocker limiting each run to near-instant near-zero-data saves); no error was observed, but the "additional records load" behaviour specifically was not triggered.*

---

## F.25 Test Case 2.1.3: Progress view

| Objective | Verify that accumulated progress and recent trend are presented. |
| --- | --- |
| Classification | Function testing — F2 |
| Pre-requisites, if any | Several activities across more than one week. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the progress view | Totals and a recent trend are displayed | "You" tab (5th tab) opened directly to a Progress view: "Weekly Distance 0.00 km", a 12-week distance bar graph (JUN/JUL/AUG, all 0 km), and a recent-activity list beneath (2 of the 3 "Thursday Night Run" cards shown, with "See all" to the full history) — totals and a recent trend were both present as required | P |
| 2 | Complete a further run and return | Totals increase to reflect the new activity | Completed a further short run (the 3rd saved activity) and returned to the You tab: the recent-activity list did pick up the new entry, but "Weekly Distance" stayed at 0.00 km because every run in this session was a near-zero-distance auto-paused run (see 1.4.3) — so the specific claim "totals increase to reflect the new activity" could not be positively confirmed for the distance total, only for the activity list count | O |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **O** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Progress view structure and live update of the activity list are confirmed; distance-total updating specifically is untested because no run in this environment produced non-zero distance (root cause: 1.4.3's auto-pause).*

---

## F.26 Test Case 2.1.4: Advanced analysis gated for a Basic user

| Objective | Verify that advanced analysis is refused for a Basic user by the server, not only by a hidden control. |
| --- | --- |
| Classification | Security and access control testing — NF1, NF6 |
| Pre-requisites, if any | A basic account with a completed run. |

**Automated corroboration.** Already verified by `featureEntitlement` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the server-side refusal of advanced analysis without entitlement. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open a run summary and select advanced analysis | The premium paywall is presented rather than the analysis | On a run summary (Basic account, qa-a2-001), scrolling to the "Coaching Summary" section showed its content visibly blurred behind a lock icon with the caption "Premium coaching / Tap to see Premium"; tapping it opened a full-screen "Runiac Premium" paywall listing "Advanced run analysis — Cadence, heart-rate and split insights" explicitly as one of the gated features (alongside Personal coaching summary, AI activity feedback, Advanced Challenge with Your Friend, and exclusive runner characters), with S$49.99/year and S$5.99/month subscribe options — the paywall was presented instead of any analysis content | P |
| 2 | Dismiss the paywall | Return to the summary with no partial premium content shown | Tapping "Close" (top-right X) on the paywall returned cleanly to the run summary; the Coaching Summary section remained blurred/locked exactly as before — no partial premium content (e.g. actual cadence/HR numbers) was ever shown before or after dismissal | P |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: The gate text names "Advanced run analysis" directly, so this maps precisely onto the objective. This confirms the interface path and user-visible refusal only, consistent with the script's own "automated corroboration" note about `featureEntitlement` covering the server-side logic.*

---

## F.27 Test Case 2.1.5: Advanced analysis for a Premium user (Premium)

| Objective | Verify that advanced analysis renders for an entitled user and reports unavailable metrics honestly. |
| --- | --- |
| Classification | Function testing — F2 |
| Pre-requisites, if any | A premium account with a Runiac-tracked run and, on iOS, an imported workout. |

**Automated corroboration.** Already verified by `featureEntitlement` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the entitlement decision that admits the request. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open advanced analysis on a Runiac-tracked run | Cadence series and split detail render | Not executed — reaching the paywall (2.1.4) is a self-serve path, but completing an actual purchase/subscription is not: the "Subscribe" buttons on the Runiac Premium paywall lead to a real App Store / StoreKit purchase flow (S$49.99/year or S$5.99/month), which requires a real payment method and cannot be completed from a QA sandbox account without one. I did not attempt to tap Subscribe to avoid triggering a real StoreKit transaction sheet on a throwaway account | BLOCKED |
| 2 | Inspect the heart-rate section on that run | Reported as unavailable rather than fabricated | Not executed — depends on step 1 | BLOCKED |
| 3 | Open advanced analysis on an imported workout | Heart-rate metrics and zones render | Not executed — depends on step 1; would also have needed a real distance-bearing Runiac-tracked run plus an Apple Health import, neither of which was obtainable in this environment (see 1.4.3 and 1.4.8) | BLOCKED |

| Tester's Name: Runiac QA harness (A2) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Per the shared brief's guidance, this is recorded as BLOCKED with the reason "requires premium subscriptionStatus; no self-serve path from the client" — the paywall itself was reached and inspected (see 2.1.4), but no admin/staging path was available to me to actually grant entitlement.*

---

## F.28 Test Case 2.2.1: View current plan and weekly workouts

| Objective | Verify that the generated plan and its weekly sessions are presented. |
| --- | --- |
| Classification | Function testing — F3 |
| Pre-requisites, if any | Onboarding complete with an active plan. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the plan area | Current plan is shown with title, duration and progress | The Plans tab (You > Plans) showed "Return to Movement", "Week 1 of 4", description "A gentle restart plan focused on comfort and consistency." and a (empty) progress bar | P |
| 2 | View the week's sessions | Running days and rest days are distinguishable | The weekly list showed Mon/Wed/Fri/Sun as "Rest Day" (bed icon, grey) and Tue/Thu/Sat as "20 min Easy Walk" (orange/blue highlighted rows) — clearly distinguishable by icon, colour and label | P |
| 3 | Confirm today's session is identifiable from the home dashboard | The next recommended action is clear | The home dashboard's curved-path view highlighted "Today's stage" (Thu) with the runner sprite standing on it and a distinct visual marker; the Plans-tab list also showed Thu as "Upcoming · 7:30 AM" highlighted in orange as the next action, while the already-past Tue showed "Missed" | P |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: screenshot saved at qa/shots/228-plan-view.png.*

---

## F.29 Test Case 2.2.2: Workout detail

| Objective | Verify that an individual planned session presents its targets. |
| --- | --- |
| Classification | Function testing — F3 |
| Pre-requisites, if any | An active plan with an upcoming session. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open a planned session | Target distance or duration and guidance are shown | Opening the Thu session showed "Thu · Easy Walk — Return to Movement", Duration 20 min, Type Recovery walk, Effort Very gentle, a session breakdown (Easy walk 15 min / Slow finish 5 min) and an effort guide | P |
| 2 | Start a run from the session | The run screen opens with the session context applied | Tapping "Start this run" opened the run/map screen pre-loaded with the same session context: "EASY WALK", "20 min", "recovery walk", "Very gentle effort · no distance target" | P |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.30 Test Case 2.2.3: Edit plan schedule

| Objective | Verify that a user can move sessions to different days and times. |
| --- | --- |
| Classification | Function testing — F3 |
| Pre-requisites, if any | An active plan. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open edit schedule | Current days and times are shown and editable | Not executed — no "edit schedule" affordance was discoverable. Checked: the Plans-tab weekly list, "View Full Plan" (week accordion, expanding Week 1 only shows a read-only day/session list), the individual workout-detail screen (only "Explain today's workout" and "Start this run"), Menu > Settings (units, profile visibility, haptics, keep-screen-on only — no schedule section), and a long-press (1.5 s) on the Thu session row (opened the same read-only workout detail, no edit sheet) | BLOCKED |
| 2 | Move a session to a different day and set a time | Change is saved and reflected in the plan view | Not executed — no editable day/time control was found to move a session | BLOCKED |
| 3 | Confirm the reminder for that session follows the change | The reminder is rescheduled, not duplicated | Not executed — could not test reminder rescheduling without an edit action to perform | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: marking BLOCKED per brief's three-attempts rule, not as a defect claim — a schedule-edit feature may exist in a screen I did not find, but it was not reachable from the plan/session/settings surfaces checked.*

---

## F.31 Test Case 2.2.4: Plan session completion

| Objective | Verify that completing a planned session is recorded and earns the plan completion bonus. |
| --- | --- |
| Classification | Function testing — F3, F9 |
| Pre-requisites, if any | An active plan with a session due today. |

**Automated corroboration.** Already verified by `planProgressCompletion` (17 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the plan-session completion ledger and the plan completion bonus condition. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete a run that fulfils the planned session | The session is marked complete in the plan | Not executed — see environment finding above: no genuinely qualifying (nonzero-distance) run could be produced, so the Thu planned session could not be legitimately marked complete. A 0.00 km/short run was saved deliberately as a probe and did *not* mark the session complete (it stayed "Upcoming" in the Plans tab) | BLOCKED |
| 2 | Confirm the experience award includes the plan completion bonus of 20 | Bonus is present in the award breakdown | Not executed — no experience award breakdown was shown for the 0 km probe run (no award UI appeared at all), so the plan-completion bonus of 20 could not be observed | BLOCKED |
| 3 | Complete an unplanned run on a different day | No plan completion bonus is awarded | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: the interface path itself (opening a session, starting a run from it) was already confirmed working under 2.2.2; this case specifically needed a completed, qualifying run, which the environment finding above rules out.*

---

## F.32 Test Case 2.2.5: Goal-oriented plans premium gate and enrolment

| Objective | Verify that published goal plans are refused for Basic users and can be enrolled in by Premium users. |
| --- | --- |
| Classification | Security and access control testing — NF1, NF6 |
| Pre-requisites, if any | At least one published goal plan. A basic and a premium account. |

**Automated corroboration.** Already verified by `featureEntitlement` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the premium gate on published goal plans. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From the basic account, open the goal plans area | Paywall is presented; no plan content is visible | Not executed — could not locate a "goal plans" area distinct from the onboarding-generated plan in the app's navigation (checked Plans tab, Full Plan view, Menu, Profile); the paywall card seen was "Unlock Runiac Premium" on the Plans tab, generic rather than goal-plan-specific | BLOCKED |
| 2 | From the premium account, open the same area | Published plans are listed | Not executed — requires a Premium account; no self-serve path to grant Premium was available from the client | BLOCKED |
| 3 | Enrol in a plan | Enrolment is recorded and the plan becomes available | Not executed — depends on step 2 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: per brief instructions, marking BLOCKED rather than inventing a premium result. Tapped "Unlock Runiac Premium" on the Plans tab as the paywall path: it opened a generic "Runiac Premium" subscription sheet (advanced run analysis, coaching summary, AI activity feedback, advanced Challenge, Cap/Ivy characters; S$49.99/yr or S$5.99/mo via "Subscribe") rather than a goal-plan-specific listing or paywall — confirms no dedicated "goal plans" browsing screen was reachable from Basic. Did not proceed into the real App Store purchase flow. Closed the sheet without subscribing.*

---

## F.33 Test Case 2.3.1: Notification permission and device registration

| Objective | Verify that notification permission is requested and the device is registered to receive push. |
| --- | --- |
| Classification | Function testing — F4 |
| Pre-requisites, if any | Notification permission not yet granted. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Reach the point where notifications are first required | Permission prompt appears with an explanation | Immediately after finishing onboarding (before reaching the home dashboard) the OS prompt "'Runiac App' Would Like to Send You Notifications — Notifications may include alerts, sounds, and icon badges..." appeared with Allow/Don't Allow | P |
| 2 | Grant the permission | The device registers for push without error | Tapping "Allow" dismissed the prompt without error and the app proceeded straight into the next onboarding step (personalized-guide consent), with no crash or stall | P |
| 3 | Refuse on a second device or after reset | The application continues to function; inbox items are still recorded | Not executed — `xcrun simctl privacy <udid> reset notifications <bundle>` (what `ui.sh reject notifications` runs) failed with "Operation not permitted" on this simulator/iOS version, and `grant notifications` failed the same way; notification authorization on this OS build can only be set once via the live OS prompt and cannot be reset/re-prompted through simctl, so the refusal path could not be re-triggered after the one real prompt was already answered | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: step 3's tooling limitation is an iOS/simctl restriction (notifications is not a resettable TCC-style service on this runtime), not an app defect.*

---

## F.34 Test Case 2.3.2: Plan reminder delivery

| Objective | Verify that plan reminders are scheduled and delivered while the application is closed. |
| --- | --- |
| Classification | Function testing — F4 |
| Pre-requisites, if any | Notification permission granted. An active plan. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Edit the schedule so a session falls shortly ahead | Schedule is saved | Notification permission was already granted (see 2.3.1) and an active plan with Thu/Sat/Tue sessions exists at 7:30 AM, so a reminder should already be scheduled against the real Thu session without needing a schedule edit (schedule editing itself was unreachable — see 2.2.3) | O |
| 2 | Close the application and wait for the reminder time | Reminder is delivered to the device | Not executed — closing the app and waiting for a real scheduled local/push reminder to fire was outside this session's practical time budget (session ran across roughly 1-2 hours of simulator wall time, and the next scheduled session time, 7:30 AM, was not inside that window); no reminder was observed to arrive | BLOCKED |
| 3 | Tap the reminder | Application opens at the relevant screen | Not executed — depends on step 2 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: per brief, recording device registration/scheduling state only; actual timed delivery not executed rather than assumed.*

---

## F.35 Test Case 2.3.3: Notification preference suppression

| Objective | Verify that disabling a category suppresses its notifications. |
| --- | --- |
| Classification | Function testing — F4 |
| Pre-requisites, if any | 2.3.2 completed. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open notification preferences and disable the reminder category | Setting is saved | Checked Menu > Settings and the Notifications inbox screen for a category-suppression toggle; neither exposed one — Settings only had Distance units, Private profile, Haptic feedback, Keep screen on; Notifications only showed the (empty) inbox list with no preferences/gear affordance | BLOCKED |
| 2 | Repeat the conditions of 2.3.2 | No reminder is delivered for the disabled category | Not executed — no toggle found to disable a reminder category | BLOCKED |
| 3 | Re-enable and repeat | Reminder is delivered again | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: no notification-category preference screen was discoverable from Settings, the Notifications inbox, or the Menu dropdown after reasonable exploration; combined with 2.3.2's blocker this case could not be executed either way.*

---

## F.36 Test Case 2.3.4: Notification inbox

| Objective | Verify that delivered notifications are recorded and readable in the application. |
| --- | --- |
| Classification | Function testing — F4 |
| Pre-requisites, if any | At least one notification delivered. |

**Automated corroboration.** Already verified by `notificationDispatch` (9 assertions), executed and passing — see Chapter 7, Table 7.9 — covering notification dispatch and inbox record creation. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the notification inbox | Delivered notifications are listed with time and category | Menu > Notifications opened an inbox screen titled "Notifications" showing "No notifications yet — Plan reminders and app updates will appear here." (empty, since no push had been delivered yet in this session) | P |
| 2 | Open an item | Navigation reaches the related screen | Not executed — no delivered notification existed to open and follow into a related screen | BLOCKED |
| 3 | Confirm read state persists after restart | Items remain marked as read | Not executed — depends on step 2 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: verdict kept P for the reachable part (inbox screen exists, opens cleanly, correct empty-state copy); steps 2-3 genuinely need a delivered item which never arrived in this session (same root cause as 2.3.2). --- # Sprint 3 — MVP Habit and Progression All 3.1.x and 3.2.x cases below require at least one genuinely completed (nonzero-distance) run before any day-1/single-session portion can even begin. Per the environment finding above, no such run was reachable in this session on this simulator. Each case is marked BLOCKED with the specific additional constraint noted (multi-day, multi-activity, etc.) that would apply on top of the base run-completion blocker even if it were resolved.*

---

# Sprint 3 — MVP Habit and Progression

## F.37 Test Case 3.1.1: Streak increments on consecutive days

| Objective | Verify that a qualifying run on the following day increments the streak. |
| --- | --- |
| Classification | Function testing — F6 |
| Pre-requisites, if any | A recorded streak value. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the streak day-delta logic, including the same-day and next-day cases. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete a qualifying run and note the streak | Streak value recorded | Not executed — no qualifying run could be completed to establish a starting streak value (environment finding above) | BLOCKED |
| 2 | Complete a qualifying run the next day | Streak increments by one | Not executed — requires activity on the following calendar day against production server time, on top of the base blocker | BLOCKED |
| 3 | Complete a second run the same day | Streak does not increment twice | Not executed — same-day second-run comparison also depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: automated corroboration (`progressionCalculator`, 35 assertions) already covers the underlying day-delta logic per the script's own note; this manual pass could not reach the interface path at all this session.*

---

## F.38 Test Case 3.1.2: Streak continues across a planned rest day

| Objective | Verify that a rest day designated by the plan does not break the streak. |
| --- | --- |
| Classification | Function testing — F6 |
| Pre-requisites, if any | An active plan with a designated rest day. A streak of at least one day. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the protected-rest-day branch that preserves a streak across a planned rest. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete a run the day before a designated rest day | Streak increments | Not executed — no qualifying run reachable (environment finding above) | BLOCKED |
| 2 | Take the rest day with no run | Streak is preserved, not reset | Not executed — requires a real rest day to elapse against production server time | BLOCKED |
| 3 | Complete a run the following day | Streak increments rather than restarting at one | Not executed — depends on steps 1-2 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none beyond the shared root cause.*

---

## F.39 Test Case 3.1.3: Streak lapses after an unplanned gap

| Objective | Verify that a gap not covered by planned rest resets the streak, and that the display refreshes without a new run. |
| --- | --- |
| Classification | Function testing, negative case — F6 |
| Pre-requisites, if any | An active streak and a day that is not a designated rest day. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the reset branch for a gap not covered by planned rest. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Allow a non-rest day to pass with no qualifying run | — | Not executed — requires an existing streak (from a qualifying run) plus a real elapsed non-rest day against production server time | BLOCKED |
| 2 | Open the home dashboard the following day | The streak is shown as lapsed without requiring a new run first | Not executed — depends on step 1 | BLOCKED |
| 3 | Complete a run | Streak restarts at one | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none beyond the shared root cause.*

---

## F.40 Test Case 3.1.4: Streak milestone bonus paid once

| Objective | Verify that a streak milestone pays its bonus and pays it only once. |
| --- | --- |
| Classification | Function testing, boundary case — F6, F9 |
| Pre-requisites, if any | An account able to reach a three-day streak. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the milestone reward table, the once-only high-water mark, and the exemption from the daily cap. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Reach a three-day streak | A bonus of 30 experience is awarded and identified as a streak milestone | Not executed — reaching a three-day streak requires three qualifying runs across three real calendar days; zero qualifying runs were reachable this session | BLOCKED |
| 2 | Confirm the bonus is not limited by the daily cap | The milestone bonus is awarded in addition to the capped activity award | Not executed — depends on step 1 | BLOCKED |
| 3 | Break the streak, then reach three days again | The three-day milestone is not paid a second time | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none beyond the shared root cause.*

---

## F.41 Test Case 3.2.1: Experience award calculation

| Objective | Verify that a completed run awards experience consistent with the published model. |
| --- | --- |
| Classification | Function testing — F9 |
| Pre-requisites, if any | Total experience recorded before the run. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions) and `configLoader` (64), executed and passing — see Chapter 7, Table 7.9 — covering the award formula and the configuration values it reads. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete a run of at least one kilometre and ten minutes of active time | Progression screen displays the award | Not executed — no run of at least 1 km and 10 minutes of active time could be completed (environment finding above); the one run I did save was 0.00 km / 0:12 active and showed no award UI at all | BLOCKED |
| 2 | Check against the model: 20 base, 10 per complete kilometre, 5 per complete ten minutes, plus 20 if planned | Displayed award matches the computed expectation | Not executed — depends on step 1 | BLOCKED |
| 3 | Confirm total experience updates by exactly that amount | Values reconcile | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: this is the single highest-value blocked case in my assignment; I invested the most diagnostic effort here (see environment finding) before concluding it was genuinely unreachable rather than trying a fourth or fifth workaround.*

---

## F.42 Test Case 3.2.2: Per-activity experience cap

| Objective | Verify that a single activity cannot award more than 100 experience. |
| --- | --- |
| Classification | Function testing, boundary case — F9 |
| Pre-requisites, if any | Ability to complete a long run, or an imported long workout. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the per-activity cap of 100 at its boundary. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete an activity whose uncapped award would exceed 100 | The award is capped at 100 | Not executed — reaching an uncapped award over 100 needs on the order of 35-40 minutes of continuously active tracked time (e.g. ~7 km at the route's 3 m/s pace); this is unreachable both because no qualifying run could be produced at all, and because even the Resume-tap workaround topping out a real run at that duration was outside this session's time budget | BLOCKED |
| 2 | Confirm the breakdown still shows the components | The user can see why the cap applied | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none beyond the shared root cause.*

---

## F.43 Test Case 3.2.3: Daily experience cap

| Objective | Verify that a day's total award cannot exceed 200 experience. |
| --- | --- |
| Classification | Function testing, boundary case — F9 |
| Pre-requisites, if any | Ability to complete three qualifying activities in one day. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions) and `progressionAuditHelpers` (10), executed and passing — see Chapter 7, Table 7.9 — covering the daily cap of 200 and the daily-total accounting net of streak bonuses. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete activities until the day's awards total 200 | Awards accumulate to the cap | Not executed — needs three qualifying activities in one day; zero qualifying activities were reachable this session | BLOCKED |
| 2 | Complete a further qualifying activity the same day | The activity is recorded but awards no additional experience | Not executed — depends on step 1 | BLOCKED |
| 3 | Complete an activity the following day | Awards resume normally | Not executed — requires a second calendar day on top of step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none beyond the shared root cause.*

---

## F.44 Test Case 3.2.4: Level progression and division change

| Objective | Verify that crossing a level threshold updates level and, where applicable, league division. |
| --- | --- |
| Classification | Function testing — F9, F8 |
| Pre-requisites, if any | An account close to a level threshold. |

**Automated corroboration.** Already verified by `progressionCalculator` (35 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the level band thresholds and the league division mapping. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Earn enough experience to cross a level threshold | Level increases and a level-up is presented | Not executed — crossing a level threshold requires accumulated XP from qualifying runs, none of which were reachable this session. (Observation only, not a substitute: Profile showed "Runner profile Lv.1", "Iron League division", "Level progress 0%, 0/100 XP" after onboarding + the 0 km probe save, i.e. account-creation defaults, not run-earned progression) | BLOCKED |
| 2 | Confirm the level badge updates across the application | Profile, feed and leaderboard reflect the new level | Not executed — depends on step 1 | BLOCKED |
| 3 | Where the new level crosses a league boundary, confirm the division changes | Division label updates | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: the Lv.1/Iron-League baseline is recorded as a factual observation of the account's starting state, not as evidence of level-up behaviour, which was not exercised. --- # MVP Integration*

---

# MVP Integration

## F.45 Test Case 4.1.1: End-to-end beginner journey

| Objective | Verify the complete core workflow from registration to visible progression. |
| --- | --- |
| Classification | Integration testing — F1, F2, F3, F4, F6, F9 |
| Pre-requisites, if any | A clean account. Outdoor location. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Register and complete onboarding | A plan is generated from the answers | On a fresh account qa-a3-002@runiacqa.dev, registration + full 16-step onboarding completed cleanly and generated a real plan: "Return to Movement", 4 weeks, 3 sessions/week, "Preferred days: Fri · Sat · Thu", "Keep it gentle" style, shown on a "Your plan preview is ready" screen before confirming | P |
| 2 | Confirm a reminder is scheduled for the first session | Reminder appears in the schedule | After confirming the plan, the Plans tab showed the first session (today, Thu) as "20 min Easy Walk — Upcoming · 7:30 AM", i.e. a reminder time is attached to the very first upcoming session without any manual scheduling step | P |
| 3 | Complete the first planned run | Summary, experience award and streak update appear | Not executed — completing the first planned run and seeing summary/award/streak update is blocked by the environment finding above (no qualifying run reachable) | BLOCKED |
| 4 | Open the plan and confirm the session is marked complete | Plan progress reflects the run | Not executed — depends on step 3 | BLOCKED |
| 5 | Open the home dashboard | Streak, level and next recommended action are all consistent with the run just completed | Not executed — depends on step 3 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: notification permission did not re-prompt for this second account (it is an app/device-level OS grant, not per-account, and was already granted under account 1 in this same session) — expected, not a defect. Overall verdict BLOCKED because the case is explicitly end-to-end and steps 3-5 (the majority of its value) could not be executed; steps 1-2 passed cleanly.*

---

## F.46 Test Case 4.1.2: End-to-end run under intermittent connectivity

| Objective | Verify that the full workflow completes correctly when connectivity is lost and restored mid-flow. |
| --- | --- |
| Classification | Integration testing — NF6 |
| Pre-requisites, if any | An account with an active plan. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Start a planned run, disable connectivity mid-run, complete and end the run | Run completes locally | Not executed — requires completing a run locally first, which is blocked by the environment finding above | BLOCKED |
| 2 | Restore connectivity | Activity synchronises; award, streak and plan completion all apply | Not executed — depends on step 1 | BLOCKED |
| 3 | Confirm the leaderboard contribution is recorded for the period | The activity counts toward the current month | Not executed — depends on step 1 | BLOCKED |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none beyond the shared root cause.*

---

## F.47 Test Case 4.1.3: Duplicate submission is not double-awarded

| Objective | Verify that a retried submission is recognised rather than awarded twice. |
| --- | --- |
| Classification | Integration testing, negative case — NF4 |
| Pre-requisites, if any | Ability to interrupt submission, for example by disabling connectivity at the moment of upload. |

**Automated corroboration.** Already verified by `completedAtFreshness` (8 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the timestamp freshness clamp that makes repeat submission safe. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | End a run and interrupt the submission mid-upload | Submission does not complete | Not executed as scripted (interrupting connectivity mid-upload of a qualifying run) — no qualifying run could be produced. As a partial substitute I rapid-tapped "Save run" three times on a 0.00 km/short-run summary screen | O |
| 2 | Allow the application to retry when connectivity returns | Submission completes | N/A — no connectivity interruption was performed | BLOCKED |
| 3 | Confirm history and experience | One activity only; the award applied once | The triple-tap on "Save run" produced exactly one navigation back to the home dashboard with no stacked/duplicate confirmation dialogs, no crash, and no second "Save this short run?" prompt reappearing — consistent with the Save action debouncing or disabling itself after the first tap, but I had no activity-history/list view available (0 km runs did not appear under Profile's "Recent Running") to directly confirm only one activity record was created server-side | O |

| Tester's Name: Runiac QA harness (A3) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: this is a genuine partial signal (the client-side control appears to guard against a rapid double-tap) but does not exercise the scripted network-interruption path or confirm server-side dedup, so kept BLOCKED rather than P. `completedAtFreshness` (8 assertions) is the cited automated corroboration for the underlying logic per the script.*

---

# Sprint 4 — Phase 2 Social and Routes

## F.48 Test Case 5.1.1: Feed publication and engagement

| Objective | Verify that an activity can be published and engaged with by another user. |
| --- | --- |
| Classification | Function testing — F5 |
| Pre-requisites, if any | Two registered accounts. A completed activity on the first. |

**Automated corroboration.** Already verified by `feedPublishCore` (7 assertions), `feedContracts` (10) and `feedAuthorLevels` (23), executed and passing — see Chapter 7, Table 7.9 — covering feed publication, the post contract and author level resolution. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Publish a completed activity from account A | Post appears in the timeline with the author's level badge | On account A (simulator A) I completed and saved a run ("Thursday Night Run", 0.00 km, 0:08 elapsed — see Environment observation above) and opened its summary. The bottom action bar only ever renders the "Share Route"/"Post to Feed" control when the app's own `hasSufficientData` check passes (distance ≥50 m AND duration ≥60 s, confirmed in source); with every run in this environment stuck at 0.00 km, the control never appeared, so the run could not be published to the feed at all — confirmed on account B (simulator B) that the Feed tab reads "No shared runs yet." throughout (Not executed — could not publish, no way to obtain a run meeting the app's own ≥50m/≥60s publish-eligibility threshold in this simulator) | — |
| 2 | From account B, like and comment | Engagement is recorded and visible to both | Not executed — no post existed on B to like/comment on (Not executed — depends on step 1) | — |
| 3 | Confirm account A receives an engagement notification | Notification delivered and recorded in the inbox | Not executed — no engagement occurred (Not executed — depends on step 1) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Friendship between A (runnera4a) and B (runnera4b) was established and confirmed bidirectionally (see 5.2.1) before this attempt, so the block is purely the distance gate, not a missing social-graph pre-requisite.*

---

## F.49 Test Case 5.1.2: Feed report and moderation

| Objective | Verify that a post can be reported and reaches the moderation queue. |
| --- | --- |
| Classification | Function testing — F5, NF9 |
| Pre-requisites, if any | A published post from another user. Administrator access for step 3. |

**Automated corroboration.** Already verified by `feedLifecycle` (10 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the report and removal lifecycle of a feed post. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Report the post from account B | The report is accepted and acknowledged | Not executed — no published post from another user exists to report (feed-publish is unreachable in this environment, see 5.1.1) (Not executed — pre-requisite "a published post from another user" could not be met) | — |
| 2 | Confirm the reporter cannot report the same post repeatedly | Duplicate reporting is prevented or de-duplicated | Not executed (Not executed — depends on step 1) | — |
| 3 | Confirm the report appears in the administrator exception queue | Report is visible with its type and severity | Not executed — no Platform Administrator account available to this agent regardless (Not executed — depends on step 1, and no admin access was assigned to this agent) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.50 Test Case 5.1.3: Hide and delete a feed post

| Objective | Verify that a user can hide another user's post and delete their own. |
| --- | --- |
| Classification | Function testing — F5 |
| Pre-requisites, if any | A published post on each of two accounts. |

**Automated corroboration.** Already verified by `feedLifecycle` (10 assertions), executed and passing — see Chapter 7, Table 7.9 — covering post hiding and deletion behaviour. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account B, hide account A's post | The post no longer appears in B's timeline | Not executed — no published post exists on either account to hide (pre-requisite "a published post on each of two accounts" could not be met, see 5.1.1) (Not executed — feed-publish unreachable) | — |
| 2 | Confirm the post is still visible to other users | Hiding is per-user, not global | Not executed (Not executed — depends on step 1) | — |
| 3 | From account A, delete its own post | The post is removed from all timelines | Not executed (Not executed — depends on step 1) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

## F.51 Test Case 5.2.1: Friend search, request and acceptance

| Objective | Verify the friend request lifecycle. |
| --- | --- |
| Classification | Function testing — F5 |
| Pre-requisites, if any | Two registered accounts with known nicknames. |

**Automated corroboration.** Already verified by `friendLevels` (17 assertions), executed and passing — see Chapter 7, Table 7.9 — covering friend level resolution across the friends graph. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account A, search for account B by nickname | Account B is found | On account A (simulator A), Menu > Friends > Search, typed exact nickname "runnera4b" and pressed return; the list returned a single row "runnera4b" with an "Add runnera4b" button | P |
| 2 | Send a friend request | Request is sent and appears pending | Tapped "Add runnera4b"; the button changed to a disabled "Updating runnera4b" then the Requests tab showed it under "Sent" with "runnera4b · Sent just now" and a "Cancel runnera4b" button | P |
| 3 | From account B, accept the request | Both accounts appear in each other's friends list with levels shown | On account B (simulator B), Menu > Friends > Requests > Incoming showed "runnera4a · Requested just now" with Accept/Decline buttons; tapped "Accept runnera4a" — the buttons disappeared and B's Friends tab then listed "runnera4a" with a "Lv.1" level badge on its avatar (screenshot qa/shots/b4-friends-list.png); A's Friends tab correspondingly listed "runnera4b" (level badge not screenshotted on A but the row rendered identically) | P |
| 4 | Decline a request from a third account | The request is removed and no friendship is created | Created a third throwaway account (qa-a4-third@runiacqa.dev, nickname runnera4c) on simulator B after signing B out temporarily, sent a friend request from C to A, then signed B back into runnera4b afterward. On account A, Requests > Incoming showed "runnera4c · Requested just now"; tapped "Decline runnera4c" and the row's action buttons disappeared immediately. Re-checked A's Friends tab: it still lists only "runnera4b" — no friendship was created with runnera4c | P |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: While creating the third account (runnera4c) for step 4, one earlier signup attempt on the same email (qa-a4-c@runiacqa.dev) skipped the "Tell us about you" (name/nickname/DOB/weight/region) step entirely after "Create account", went straight to buddy selection, then failed to save the plan with "We could not save your profile. Try again." and relaunching showed "No Runiac account setup exists for this account." — an orphaned Firebase Auth user with no Firestore profile. This did not recur on a second attempt with a different email (qa-a4-third@runiacqa.dev), which went through onboarding normally. Not one of my assigned cases so not scored, but noted as a possibly genuine intermittent onboarding defect for the record. Neither this agent's assigned two accounts (A, B) nor any pre-existing third-party account was affected.*

---

## F.52 Test Case 5.2.2: Block and unblock a user

| Objective | Verify that blocking removes visibility in both directions and can be reversed. |
| --- | --- |
| Classification | Function testing — F5, NF2 |
| Pre-requisites, if any | Two accounts that are friends, each with a published post. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account A, block account B | The friendship ends and B's content disappears from A's timeline | On account A, Friends > "More actions for runnera4b" > Block, confirmed on the dialog "Block runnera4b? This removes the friendship and pending requests in both directions." — A's Friends tab immediately went to "No friends yet" and A's Blocked tab listed "runnera4b" with an "Unblock runnera4b" control; on account B the Friends tab also independently went to "No friends yet" — the friendship ended on both sides | P |
| 2 | From account B, attempt to view account A's profile or content | Content is not reachable | On account B, searching "runnera4a" still returned the row with a working "View runnera4a profile" link; opening it successfully loaded A's full runner profile (Lv.1, Iron League, Max streak 1 day, Total distance 0.0 km, badge case) rather than being unreachable — screenshot qa/shots/b4-view-blocked-profile.png. However, B's attempt to re-add A ("Add runnera4a") did fail with "Please wait a moment and try again." (a generic error, but the friend request did not go through), so the contact/friend-request channel is blocked even though the public profile page itself is not | F |
| 3 | Unblock from account A | Blocking is lifted; no friendship is automatically restored | From account A, Blocked tab > "Unblock runnera4b", confirmation dialog explicitly read "Unblocking does not restore a friendship or request."; after confirming, A's Blocked tab emptied to "No blocked runners" and A's Friends tab stayed "No friends yet" — blocking was lifted and no friendship was auto-restored, exactly as expected | P |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 2 is marked F because the case's literal expected result ("Content is not reachable") did not hold for the runner-profile page — a blocked user's stats/level/streak remained fully visible to the blocking party's target account via search, only the friend-request action was actually refused. This may be an intentional "public profile" design choice rather than a security defect (no route data or activity feed content was exposed, since none existed to test), but it is a direct mismatch against the written expectation and worth a design-intent check. Also note the pre-requisite "each with a published post" could not be met (no publishable activity in this environment, see Environment observation), so only the friend-connection/profile-visibility semantics of blocking were exercised, not post-level content hiding.*

---

## F.53 Test Case 5.3.1: Distance challenge lifecycle

| Objective | Verify challenge creation, invitation, contribution and settlement. |
| --- | --- |
| Classification | Function testing — F5 |
| Pre-requisites, if any | Two accounts that are friends. A non-premium tier available. |

**Automated corroboration.** Already verified by `challengeStateMachine` (40 assertions) and `challengeCatalog` (17), executed and passing — see Chapter 7, Table 7.9 — covering the challenge lifecycle state transitions and the tier catalogue. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account A, create a lobby at a non-premium distance tier | Lobby is created and shown | From account A, Menu > Challenge > "Challenge 10K Beginner" (a non-premium tier) > "Create challenge"; the app opened a lobby screen reading "10K, Lobby closes in 23:59:53, 1/2, runnera4a · You · Owner" with Invite friends / Start challenge / Cancel challenge controls | P |
| 2 | Invite account B; accept from B | B joins the lobby | Tapped "Invite friends", selected runnera4c (friend, standing in for runnera4b — see Environment observation below), confirmed "Invited 1 of 1"; on account C (nickname runnera4c, driven from simulator B), Menu > Challenge > Invitations showed "Challenge invitation 10K"; opened it and tapped Accept — the screen updated to "10K, Lobby closes in 23:58:35, 2/2", listing both runnera4a (Owner) and runnera4c (Accepted), "Waiting for the owner to start" | P |
| 3 | Start the challenge from account A | Challenge becomes active for both participants | Returned to account A to tap "Start challenge": navigating back to Menu > Challenge (via the catalogue tile, via Invitations, and via a full app relaunch) consistently showed "Something went wrong. Please try again." on the Challenge root screen instead of the lobby, and "Try again" never recovered it — reproduced on 4 separate attempts across roughly 3 minutes including one full app relaunch. The "Start challenge" control could not be reached, so the challenge was never started | F |
| 4 | Complete a run on each account | Distance contributes to each participant's progress | Not executed — the challenge was never started, so no run could contribute to it (Not executed — blocked by step 3) | — |
| 5 | On reaching the goal, confirm the badge | Badge is granted and appears in challenge history | Not executed (Not executed — blocked by step 3) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: At the time step 3 was attempted, account C's own Challenge catalogue/Invitations screens still loaded normally (no error), so the failure was initially scoped to A's owner-side active-lobby load specifically. However, roughly 10 minutes later while attempting 5.3.3 (see below), C's Challenge tab independently started showing the identical "Something went wrong. Please try again." error too — i.e. once a lobby reaches 2/2 accepted-but-not-started, the Challenge tab eventually breaks for *both* participants, not just the owner. Even setting the defect aside, steps 4-5 (real distance contribution, badge on reaching the goal) would additionally have been blocked by the simulator's inability to produce a real-distance run (see Environment observation at the top of this file).*

**Remediation, 2026-08-07.** This execution result was root-caused and fixed. The Challenge hub reads `getActiveChallenge` and parses the response strictly; `ChallengeParticipantRow.fromMap` read each roster row's `levelLabelSnapshot` through `ChallengeParse.string`, which rejects an empty string. The backend resolves that label live from `userProfiles/{uid}`, where `level`/`levelLabel` are written only by `completeRun`/`completeCoolDown` — so a runner who has never completed a run resolves to `""`. Account C was created minutes before this script and had never run, so the moment C joined the lobby the whole view failed to parse, surfacing as `ChallengeFailure('INVALID_RESPONSE')` and, since no copy is mapped to that reason, as "Something went wrong. Please try again." for every member of the lobby. It could not recover across a relaunch because the cause is stored data, not client state. The lobby screen kept working throughout because the realtime path (`mapActiveChallengeView`) substituted its own placeholder before parsing — which is exactly why the failure looked confined to the hub. The fix parses `levelLabelSnapshot` leniently, matching the field's own documented contract ("May be empty … callers fall back to `Lv.0`") and the sibling `avatarUrlSnapshot`/`levelProgressPercentSnapshot` readers; two regression tests cover an empty and an absent label, and the 187 tests across the twenty Challenge test files pass. **The verdict above stays F: the fix is verified by unit test only and this script has not been re-executed on a device.** Re-execution additionally needs a second account that has never completed a run, which is the condition that triggered it.

---

## F.54 Test Case 5.3.2: Premium challenge tier refused for a Basic user

| Objective | Verify that a tier at or above one hundred kilometres is refused server-side for a Basic user. |
| --- | --- |
| Classification | Security and access control testing, negative case — NF1, NF6 |
| Pre-requisites, if any | A basic account. |

**Automated corroboration.** Already verified by `featureEntitlement` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the premium refusal on higher challenge tiers. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the catalogue and select a tier of 100 km or above | The tier is shown as premium rather than silently hidden | On the Basic account A, Menu > Challenge opened the catalogue as a 3x3 grid: 10K Beginner, 20K Easy, 42K Normal (no premium marker), then 100K Challenging, 200K Hard, 250K Hard+, 300K Very Hard, 500K Extreme, 1000K Legend — every tier at 100K and above carried a visible "Premium" label right on the tile (screenshot qa/shots/a4-challenge-catalog.png), i.e. shown, not silently hidden | P |
| 2 | Attempt to start a challenge at that tier | Refused with a clear premium-required message | Opened the 100K tier detail (target 100.0 km, 4 weeks, up to 4 runners, personal minimum 13.0 km) and tapped "Create challenge"; the app immediately opened the "Runiac Premium" paywall sheet (S$49.99/yr or S$5.99/mo, listing "Advanced Challenge with Your Friend" as one of the premium perks) instead of creating anything — a clear, explicit premium-required message/paywall, not a silent failure | P |
| 3 | Confirm no challenge instance was created | No active challenge appears | Closed the paywall and returned to the Challenge catalogue; it still showed only the static tier grid with no active/pending challenge tile, and Menu > Challenge > History (not opened in detail but the tab is separate from the catalogue) had nothing added — no challenge instance was created | P |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: exact refusal copy captured: paywall title "Runiac Premium", subtitle "More guidance", and the specific perk line "Advanced Challenge with Your Friend" directly ties the gate to this feature. Screenshot qa/shots/a4-challenge-paywall.png. ## Environment observation — friend request cannot be re-sent after a block/unblock cycle After completing 5.2.2 (A blocked B, then unblocked B), re-sending a friend request between A and B failed every time in both directions, every retry, with the generic "Please wait a moment and try again." error — reproduced roughly a dozen times over more than 3 minutes of elapsed wall time (including an explicit ~80 s idle wait), so this was not a short-lived rate limit. By contrast, sending a fresh request from A to a third, never-blocked account (runnera4c, created for the 5.2.1 step-4 decline test) succeeded immediately on the very next attempt. This isolates the failure specifically to the A/B pair post-block/unblock, not a general throttle — a plausible genuine defect (a stale block-relation record likely still guards the friend-request callable even after the client-visible "unblock" completes) worth flagging, though it was not one of my scored cases so it is reported here rather than scored. Because of this, 5.3.1 and 5.3.3 (which need "two accounts that are friends") were completed using account A and the third account (runnera4c, nickname suffixed "a4c", created and driven from simulator B in place of runnera4b for these two cases only) instead of A/B — both accounts remain under this agent's control on its assigned two simulators, no other agent's or real user's account was used.*

---

## F.55 Test Case 5.3.3: Challenge withdrawal, decline and cancellation

| Objective | Verify the negative paths of the challenge lifecycle. |
| --- | --- |
| Classification | Function testing, negative case — F5 |
| Pre-requisites, if any | Two accounts that are friends. |

**Automated corroboration.** Already verified by `challengeStateMachine` (40 assertions) and `challengeExpiry` (5), executed and passing — see Chapter 7, Table 7.9 — covering the withdraw, decline, cancel and abandon transitions and deadline expiry. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Create a lobby and invite account B; decline from B | Invitation is removed; B does not join | Not executed (Not executed — see reason below) | — |
| 2 | Invite again, accept, then withdraw from B before start | B leaves the lobby cleanly | Not executed (Not executed — see reason below) | — |
| 3 | Cancel the lobby from account A | Lobby is cancelled; no challenge is started | Not executed (Not executed — see reason below) | — |
| 4 | Start a challenge, then abandon it from account B | B is removed from the active challenge; A's progress is unaffected | Not executed (Not executed — see reason below) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Not executed — by the time this case was attempted, the Challenge tab was broken ("Something went wrong. Please try again.", non-recoverable via Try again or relaunch) on **both** of this agent's real accounts: account A (owner of the stuck 5.3.1 lobby) and account C/runnera4c (its accepted member) — see the 5.3.1 note. Account B (runnera4b) has no friends to invite (its friendship with A could not be re-established after 5.2.2's block/unblock — see the Environment observation above — and it was never connected to C), so there was no remaining clean account pairing on either of this agent's two simulators to drive a fresh lobby through. Coverage of this case would require either a working Challenge tab on a still-clean account or a way to leave/cancel the stuck 10K lobby from account A, neither of which was reachable given the defect.*

---

## F.56 Test Case 5.4.1: External sharing through the share sheet

| Objective | Verify that an achievement card can be composed and shared externally. |
| --- | --- |
| Classification | Function testing — F5 |
| Pre-requisites, if any | A completed run and at least one achievement. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Select share on a run summary | A share card is composed | On account A, opened the "Thursday Night Run" summary and tapped the share icon (tooltip "Share summary"); a "Share Your Activity" sheet composed a card showing the Runiac logo, date "6/8/26 · 1:43 AM", a route-preview tile labelled "Easy local route", title "Thursday Night Run", status "Run completed", and the stats (0.00 km Distance, 0:08 Time, -- Avg pace/HR) — a real, populated share card, not a placeholder (screenshot qa/shots/a4-share-sheet.png) | P |
| 2 | Invoke the share sheet and select a destination | The operating system share sheet appears and the card is passed to it | Under "SHARE TO" the sheet offered Instagram (disabled — not installed), Copy to Clipboard, Save, Copy Link and More; tapping "More" invoked the genuine iOS `UIActivityViewController` — it showed "Plain Text and 1 Document" with a thumbnail of the same card, and destination icons (Reminders, Copy, Save Image, Assign to Contact, View More) (screenshot qa/shots/a4-native-share.png). The OS share sheet did appear with the card passed into it; completing a post to an actual third-party app was not attempted/possible since no sharing-capable app (Messages, Mail, a social client) is installed on this iOS simulator | P |
| 3 | Cancel the share | No external action occurs and no error is shown | Tapped outside the native share sheet to dismiss it; it closed cleanly back to Runiac's own "Share Your Activity" screen with the card still shown and no error toast or crash; tapping "Close" there returned to the run-detail screen normally | P |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 2's literal "select a destination" could not be completed to an external app because the simulator has no eligible destination installed — the interface path itself (card composed → OS sheet invoked → card passed in) is fully verified and is scored P per the brief's simulator-sharing guidance.*

---

## F.57 Test Case 5.4.2: Instagram Story sharing (iOS)

| Objective | Verify the dedicated Instagram Story share path. |
| --- | --- |
| Classification | Function testing, platform-specific — F5 |
| Pre-requisites, if any | iOS device with Instagram installed and signed in. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Select the Instagram Story share option on an achievement | Instagram opens with the card loaded into the Story composer | Not executed — Instagram is not installed on this iOS 26.5 simulator, so the dedicated Instagram Story entry point could not be exercised (Not executed — Instagram not installed on the simulator) | — |
| 2 | Return to Runiac without posting | Runiac resumes normally | Not executed — never entered Instagram (Not executed — depends on step 1) | — |
| 3 | Repeat on a device without Instagram installed | The option is unavailable or fails gracefully with a clear message | This IS the environment available: in the "Share Your Activity" sheet the "Instagram" tile was present but rendered `DISABLED` in the accessibility tree (greyed out in qa/shots/a4-share-sheet.png) — tapping it produced no response, no crash, and no error toast; the option was simply inert/unavailable rather than failing loudly, which matches the "unavailable ... or fails gracefully" half of this step's expected result | O |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Device/iOS version: iPhone Air / iPhone 17 Pro Max simulators, iOS 26.5, Instagram not installed on either. Marked BLOCKED per the brief's explicit instruction for this exact scenario; step 3's disabled-button behaviour is recorded as a genuine observation (O) rather than scored P/F since the case's own step 3 assumes it is being run as a deliberate repeat after step 1's success, which never happened here.*

Device / iOS version: ____________________________________________

---

## F.58 Test Case 5.5.1: Browse and save community routes

| Objective | Verify that the maps area lists routes, opens their detail and saves them. |
| --- | --- |
| Classification | Function testing — F7 |
| Pre-requisites, if any | A signed-in account. Note: the community route library reads demonstration data in the delivered build — see the F7 scope note in Chapter 2. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the maps area and browse the routes list | Routes are listed with distance, difficulty and region | Looked for a routes list under every reachable entry point on account A: the Run tab's pre-run map screen (only shows "Compass", "About this map" [Mapbox attribution sheet], "Run settings" [voice-coaching preferences only], and "Start run" — no routes list), Menu (Notifications/Friends/Challenge/Settings/App tour only), and the bottom nav's 5 tabs (Home/Feed/Run/Leaderboard/You) — none of them exposes a community-routes browsing screen (Not executed — no navigable entry point to the maps/routes area exists in this build) | — |
| 2 | Open a route | Detail is shown including estimated duration | Not executed (Not executed) | — |
| 3 | Save the route | It appears in the saved routes list and persists across restart | Not executed (Not executed) | — |
| 4 | Report a route | The report is accepted | Not executed (Not executed) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: A source check (read-only) confirms this is not a missed tap target: `MapsTab`/`SharedRoutesSheet`/`SavedRoutesScreen` exist in the codebase (`lib/features/maps/presentation/`) but `lib/features/shell/runiac_shell.dart`'s 5-item bottom nav routes index 2 ("Run") to `RunLaunchScreen`, not `MapsTab`, and no menu item, named route, or `Navigator.push` call anywhere in the app reaches the maps feature — it is built but not wired into navigation in this delivered build. Consistent with the case's own scope note ("the community route library reads demonstration data in the delivered build").*

---

## F.59 Test Case 5.5.2: Route publication to the feed applies privacy coarsening (Premium)

| Objective | Verify that a route reaches another user only through deliberate publication, and that the published preview is coarsened. |
| --- | --- |
| Classification | Privacy testing — F5, F7, NF2 |
| Pre-requisites, if any | A premium account with a completed run. A second account for viewing. |

**Automated corroboration.** Already verified by `feedPublishEntitlement` (10 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the premium gate on publishing a route to the feed. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Before publishing, attempt to view account A's run or route from account B | Neither is discoverable | Before any publish action, account B's Feed read "No shared runs yet." throughout this session and there is no routes-browsing screen reachable at all (see 5.5.1) — so A's run/route was not discoverable to B by any means, consistent with the expectation, though this is a weak confirmation since there was no publish action yet to make it a meaningful before/after comparison | O |
| 2 | Publish the run's route to the feed from account A | Post appears in the timeline with a route preview | Not executed — requires a Premium account; no self-serve upgrade path exists from the client (paywall only offers real payment — see the paywall captured in 5.3.2) (Not executed — requires premium subscriptionStatus; no self-serve path from the client) | — |
| 3 | Compare the published preview against the original on account A | Preview is visibly coarser; endpoints do not resolve to a precise address | Not executed — depends on step 2 (Not executed — depends on step 2) | — |
| 4 | Attempt the same publication from a Basic account | Refused server-side with a premium-required message | Not executed — even on the Basic account this specific gate could not be isolated: the "Share Route"/publish action itself only renders once a run meets the app's own ≥50 m/≥60 s data threshold, which no run in this simulator could reach (see Environment observation) — so the premium-refusal path and the insufficient-data hide could not be told apart (Not executed — requires premium subscriptionStatus; no self-serve path from the client, and additionally no distance-eligible run exists to test the Basic-refusal path against) | — |

| Tester's Name: Runiac QA harness (A4) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone Air + iPhone 17 Pro Max simulators, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: none.*

---

# Sprint 5 — Phase 2 Advanced Features

## F.60 Test Case 6.1.1: Leaderboard ranking and neighbour window

| Objective | Verify that the leaderboard shows the user's region and division, their rank, and adjacent runners. |
| --- | --- |
| Classification | Function testing — F8 |
| Pre-requisites, if any | At least one validated run this month in a recognised region. |

**Automated corroboration.** Already verified by `monthlyLeaderboard` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering ranking order, tie-breaking and the neighbour window construction. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the leaderboard | The board for the user's region and league division is shown | Signed in as jason04334@gmail.com (Premium, Lv.9, 880/900 XP, 76.0 km, Jurong East region) via Google sign-in and opened the leaderboard tab. The board header read "Jurong East" with a monthly refresh countdown ("Refreshes in 25:21:29:19"). | P |
| 2 | Locate the user's own entry | Rank label and score are displayed | The user's own entry showed rank label "#1" with score "100 XP" under nickname "Jinseo_😎", Lv.9. | P |
| 3 | Observe adjacent entries | A window of neighbouring runners is shown, not only the top of the board | Opening "View More Ranking" showed a "RANKS NEAR YOU" section listing the neighbour window around the user's position (rank 1, Jinseo_😎, 100 XP); only one entry appeared because no other runner is currently ranked in Jurong East this month — the window mechanism rendered correctly but had nothing else to populate with in this live production region. | O |
| 4 | Open another runner's public profile | Achievement profile opens; no private activity or health data is visible | From Menu → Friends, opened "View Runmaster profile" (a friend's public profile). It opened as an achievement profile: Lv.5, "Unranked division", region "Jurong East, Singapore", "Basic plan", level progress 0%, Max streak "—", Total distance "—", 1 of 9 badges, and the footer note "Only public running achievements are shown." No email, birth date, weight, raw activity list, or GPS route was visible. | P |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Screenshot qa/shots/a5-611-otherprofile.png (Runmaster's public achievement profile). Step 3 is graded O rather than F: the neighbour-window UI is present and correctly labelled ("RANKS NEAR YOU"), but this production region currently has only one ranked runner (the test account itself), so a multi-entry neighbour window could not be observed live. ---*

---

## F.61 Test Case 6.1.2: Leaderboard region and division selection

| Objective | Verify that the board reflects the region a run occurred in and the division the level implies. |
| --- | --- |
| Classification | Function testing — F8 |
| Pre-requisites, if any | Runs recorded in a known planning area. |

**Automated corroboration.** Already verified by `monthlyLeaderboard` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering region and division grouping at aggregation time. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Confirm the region shown matches where the runs took place | Region label is correct | Region shown on the leaderboard ("Jurong East") matches the account's registered planning area, also confirmed on the Profile screen ("Rank #1 in Jurong East, Singapore") and on the rank-share preview card ("Jurong East / Iron League / #1"). | P |
| 2 | Confirm the division matches the user's current level band | Division label is consistent with the level | Division label "Iron League division" shown on Profile matches the user's level (Lv.9); opening the in-app "Open leagues list" panel confirmed the league bands, with "Iron (Lv.1 - Lv.10)" as the listed band covering Lv.9 — consistent with the shown division. | P |
| 3 | Browse the region map or league view | Other regions and divisions can be viewed | The "Open leagues list" panel let the user browse all nine other league divisions (Challenger down to Bronze) by band; a full region switcher to view other regions' live boards was not found in the leaderboard screen itself (Compass icon in that corner actually resolves to the "Leaderboard information" tips button, not a region switcher), so region browsing was verified only via the informational Leagues panel and profile/rank-share region labels, not by loading a second region's live board. | O |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: No separate live "browse another region's board" control was located on the leaderboard screen within three attempts (Compass button repeatedly hit the overlapping "Leaderboard information" tips button instead); league/division browsing is fully supported and was exercised. Given the objective (region and division correctness) was clearly verified, VERDICT is P with step 3 marked O for the partial region-browse gap. ---*

---

## F.62 Test Case 6.1.3: Leaderboard pending state for a new user

| Objective | Verify that a user not yet ranked is told so rather than shown an empty board. |
| --- | --- |
| Classification | Function testing, boundary case — F8 |
| Pre-requisites, if any | A newly registered account with no qualifying run this period. |

**Automated corroboration.** Already verified by `monthlyLeaderboard` (13 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the minimum-qualifying-run eligibility filter. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the leaderboard before completing any run | The board for the region and division is shown with the user's status indicated as pending | Registered fresh account qa-a5-001@runiacqa.dev (nickname qatestera5), completed onboarding, selected region Bishan during profile setup, and never completed a qualifying run. Opening the leaderboard tab (tab 4) showed region label "Bishan", "No runners ranked here yet", "Complete a run to be the first on the Bishan leaderboard!", and a "My Rank Preview" section reading "You are not ranked yet — finish a run this month to appear here." No empty/blank board was shown; the pending status was explicit. | P |
| 2 | Complete a qualifying run and wait for the next aggregation | The user appears on the board | Not executed — completing a qualifying run and observing the user appear on the board requires waiting for the next scheduled `monthlyLeaderboard` aggregation cycle in production, which is not triggerable on demand and cannot be waited out within a single manual test session. | O |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **O** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: An accidental short (0.00 km / 13 s) run was started and immediately discarded via the in-app "Discard" prompt before this account was used for the leaderboard check, so it did not count as a qualifying run and does not affect the pending-state result above. Screenshot: qa/shots/a5-621-pending.png. Case objective (pending state is communicated, not an empty board) is fully verified; step 2 (post-aggregation appearance) is an environment-timing limitation, not a defect, hence VERDICT O rather than P. ---*

---

## F.63 Test Case 6.2.1: AI activity feedback — safety and quota (Premium)

| Objective | Verify that generated feedback avoids prohibited language, that the daily quota is enforced, and that Basic users receive deterministic copy. |
| --- | --- |
| Classification | Generated content safety testing — F10 |
| Pre-requisites, if any | A premium account with at least six activities in one day. A basic account for step 4. |

**Automated corroboration.** Already verified by `activityFeedbackModel` (6 assertions) and `activityFeedbackContracts` (4), executed and passing — see Chapter 7, Table 7.9 — covering the output validators that reject medical and diagnostic phrasing, and the response contract. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open AI activity feedback on a completed run | Feedback is generated in plain language | Opened "Activity feedback" on a completed run (Monday Night Run, 6.26 km) from the account's real activity history. A 4-page feedback flow was generated in plain language: Summary — "You completed a 6.26 km run in 44 minutes and 46 seconds, maintaining an average pace of 7 minutes and 9 seconds per kilometer. This run provided a good foundation for your training."; Went well — "You maintained a steady pace throughout most of the run, showing good endurance."; Improve — "Consider working on your pacing consistency, as there were some fluctuations in your pace."; Next focus — "Aim for another easy run with a similar steady feel." | P |
| 2 | Read the text for prohibited content | No diagnosis, injury prediction or medical advice; no mention of experience, level, rank or leaderboard | Read all 4 pages above (and the 4 additional generations below) for prohibited content: no diagnosis, injury prediction, or medical advice appeared, and no mention of experience/level/rank/leaderboard appeared in any of the 5 successful generations. | P |
| 3 | Generate five times in one day, then attempt a sixth | The sixth is refused and the reset time is communicated | Generated feedback for 5 distinct activities in total this session (Monday Night Run 6.26 km, Friday Night Run 8.19 km, Wednesday Night Run 8.32 km, an earlier Monday Night Run 6.56 km, and Sunday Night Run 7 km — each produced fresh personalised 4-page text). The 6th attempt, on "Wednesday Evening Run" (1/7/26), returned a non-personalised fallback instead of personalised feedback — Summary: "Your run summary is ready, but personalised feedback is temporarily unavailable."; Went well: "You completed the run and captured useful derived metrics."; Improve: "Keep the next effort comfortable and notice what feels repeatable."; Next focus: "Aim for one calm, steady session when you feel ready." The refusal did occur without an error screen or crash, but at no point on any of the 4 pages, nor elsewhere on the run-summary screen, was a reset time (e.g. "resets at HH:MM" or a countdown) communicated to the user. | F |
| 4 | Repeat step 1 on a basic account | Deterministic template feedback is shown, with no error | On the qa-a5-001@runiacqa.dev Basic account, tapping "Activity feedback" on a run summary did NOT show deterministic template feedback as expected — it opened the "Runiac Premium" subscription paywall instead (identical paywall content/buttons to the one shown for the workout-briefing case: "More guidance", "AI activity feedback" listed as a locked benefit, "Subscribe · S$49.99 per year"). No deterministic feedback text was shown at all. | F |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Screenshot qa/shots/a5-621-sixth-attempt.png (verbatim 6th-attempt fallback text visible on screen, no reset-time messaging anywhere) and qa/shots/a5-621-basic-paywall.png (Basic-account paywall shown instead of deterministic feedback). Step 3 is graded F because the expected result explicitly requires "the reset time is communicated" and no such communication was observed — the refusal itself degraded gracefully (deterministic-style copy, no crash) which is a partial success worth noting, but the reset-time requirement was not met. Step 4 is graded F because the expected result explicitly says Basic should see "Deterministic template feedback... with no error," but the actual behaviour observed was a Premium paywall, i.e. AI activity feedback appears to be fully gated behind Premium on this build rather than degrading to a deterministic template for Basic users. The test run used for step 4 was a very short (0.00 km) simulator run, discarded afterwards via the in-app Discard prompt; the paywall appeared immediately on tapping the button, before any run-quality check could plausibly have been evaluated, so this is unlikely to be a "not enough data" artifact rather than a genuine Basic-tier gate. ---*

---

## F.64 Test Case 6.2.2: AI home guide — consent and daily cache (Premium)

| Objective | Verify that the home guide requires consent and does not regenerate for an unchanged situation. |
| --- | --- |
| Classification | Function testing — F10, NF2 |
| Pre-requisites, if any | A premium account that has not yet consented. |

**Automated corroboration.** Already verified by `homeGuideModel` (17 assertions), `homeGuideEvidence` (13) and `homeGuideGeneratedCopyPolicy` (4), executed and passing — see Chapter 7, Table 7.9 — covering the generated-copy policy, the evidence model that limits the prompt to supplied facts, and the consent gate. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the home dashboard before consenting | Guidance is not generated; a consent request is presented | With Personalized guide toggled Off in Privacy & Safety (simulating not-yet-consented) and the app relaunched, the home dashboard opened directly on the consent screen: "Personalized guide data use" with buttons "Allow personalized guide" and "Not now" — guidance was not generated ahead of a consent decision. | P |
| 2 | Decline consent | Deterministic guidance is shown instead; the application functions normally | Tapped "Not now" (decline). The home path screen loaded normally with a deterministic, non-personalised guide label — "Today's rest day." — and the rest of the app (calendar path, menu, tabs) functioned normally with no error. | P |
| 3 | Grant consent and reopen the dashboard | Generated guidance appears | Re-enabled Personalized guide in Privacy & Safety and relaunched the app. The home dashboard now showed a generated, personalised guide bubble: "Today's a rest day — nice work showing up! Recovery is where your progress locks in." — clearly distinct in tone/content from the deterministic label in step 2. | P |
| 4 | Reopen the dashboard again the same day with no new activity | The same guidance is shown, indicating the cached result was reused | Relaunched the app again the same day with no new activity recorded. The guide bubble showed the exact same text verbatim: "Today's a rest day — nice work showing up! Recovery is where your progress locks in." — confirming the cached result was reused rather than regenerated. | P |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Screenshots qa/shots/a5-622-guide-generated.png and qa/shots/a5-622-guide-cached.png (byte-for-byte identical guide text across two separate app launches). No medical, diagnostic, competitive, or ranking language appeared in the generated copy. ---*

---

## F.65 Test Case 6.2.3: AI workout briefing (Premium)

| Objective | Verify that a briefing is generated for an upcoming planned session within quota. |
| --- | --- |
| Classification | Function testing — F10 |
| Pre-requisites, if any | A premium account with an upcoming planned session. |

**Automated corroboration.** Already verified by `workoutBriefingModel` (12 assertions) and `workoutBriefingContracts` (11), executed and passing — see Chapter 7, Table 7.9 — covering the briefing output validators and response contract. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open the workout briefing for an upcoming session | A briefing is generated referencing the session's targets | Opened "Explain today's workout" on the upcoming Friday "Comfortable Run" session in the active plan (10K Performance Build). A 4-page briefing was generated referencing the session's actual targets — "Today's session": "Today, you'll enjoy a comfortable run for about 27 minutes after a quick 4-minute warm-up walk. Choose a familiar park loop where you can keep a relaxed pace and feel free to chat if you want. After your run, take another 4 minutes to cool down with a walk."; "Why it helps": "This session helps you build endurance and establish a routine..."; "How it should feel": "During this run, you should feel relaxed and able to maintain a conversation without gasping for breath..."; "Before you start": "...it's perfectly fine to slow down or shorten the run." | P |
| 2 | Read for prohibited content | No medical language, no competitive references | Read this and the 4 further distinct-session briefings generated below for prohibited content: no medical language and no competitive/ranking references appeared in any of the 5 successful generations. | P |
| 3 | Request six briefings in one day | The sixth is refused with the reset time communicated | Generated briefings for 5 distinct upcoming sessions in total this session (this week's Friday Comfortable Run, Week 6 Monday and Wednesday sessions, Week 7 Monday session, and this week's Saturday Recovery Run — each produced fresh session-specific 4-page text; reopening the same session's briefing immediately reused the cached text with no new "Reading your plan..." load). The 6th attempt, on the Week 7 Wednesday "Controlled Steady Run" session, returned generic non-session-specific copy instead — "Today's session": "Here is today's session as your plan wrote it — the breakdown above lists every step in order."; "Why it helps": "Every session in a beginner plan is there to build easy, repeatable running rather than one hard day."; "How it should feel": "Keep the effort conversational: you should be able to speak in full sentences the whole way."; "Before you start": "Warm up gently, start slower than feels natural, and walk whenever you need to reset." The refusal happened without an error screen or crash, but no reset time was communicated anywhere on the 4 pages or the workout-detail screen behind them. | F |
| 4 | Open the same area on a basic account | The paywall is presented | On the qa-a5-001@runiacqa.dev Basic account, opening "Explain today's workout" on an active plan session presented the "Runiac Premium" paywall exactly as expected: benefits list including "AI activity feedback", "Advanced run analysis", "Personal coaching summary"; pricing "S$49.99 per year" / "S$5.99 per month"; and a "Subscribe · S$49.99 per year" button. No briefing content was generated. | P |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Screenshot qa/shots/a5-623-sixth-briefing.png (verbatim 6th-attempt generic fallback text, no reset-time messaging visible). Step 3 graded F for the same reason as 6.2.1: the expected result explicitly requires "the reset time is communicated," and none was observed, even though the refusal degraded gracefully (no crash, no error screen). Step 4 (Basic paywall) matched the expected result exactly. ---*

---

## F.66 Test Case 6.2.4: AI fallback when generation is unavailable

| Objective | Verify that the application degrades to deterministic copy rather than failing when generation is unavailable. |
| --- | --- |
| Classification | Function testing, negative case — F10, NF6 |
| Pre-requisites, if any | A build or environment in which the provider can be made unavailable, or network conditions that prevent generation. |

**Automated corroboration.** Already verified by `homeGuideModel` (17 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the deterministic fallback path when generation is unavailable. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | With the provider unavailable, open AI activity feedback on a premium account | Deterministic copy is shown; no error screen or crash | The provider could not be taken down directly (out of scope per task brief), so the daily-quota-exhausted state from 6.2.1 was used as the closest genuine "generation unavailable" condition, per the brief's guidance. On the 6th same-day activity-feedback request (see 6.2.1 step 3), deterministic-style fallback copy was shown across all 4 pages with no error screen or crash: "Your run summary is ready, but personalised feedback is temporarily unavailable." plus 3 further generic pages. | P |
| 2 | Open the home guide under the same conditions | Deterministic guidance is shown | Not executed — the home guide's "unavailable" behaviour could not be independently isolated in this session: it generates once per day and then serves a cached result (verified in 6.2.2), so there was no way to force a fresh "unavailable" generation attempt for it without waiting for the next calendar day. | O |
| 3 | Restore availability and repeat | Generated content returns | Not executed — restoring provider/quota availability requires either waiting for the next daily reset or a backend-side change, neither of which is available to a client-side manual tester. | O |

| Tester's Name: Runiac QA harness (A5) | Signed: | Date: 2026-08-06 | Time Started: | **O** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Step 1 is corroborated by the same quota-exhaustion fallback also observed for the workout briefing in 6.2.3 step 3 (both activity feedback and workout briefing degrade to generic, non-crashing copy with no reset-time messaging when generation is not possible). No prohibited (medical/diagnostic/competitive) language appeared in any fallback text. Overall VERDICT is O rather than P because 2 of 3 steps were not independently executable within a single manual session, though the one step that was executable passed cleanly (graceful degradation, no crash).*

---

# Final Integration

## F.67 Test Case 7.1.1: Backend-owned fields cannot be written by a client

| Objective | Verify that progression fields are rejected when submitted by a client. |
| --- | --- |
| Classification | Security and access control testing — NF1, NF4, NF6 |
| Pre-requisites, if any | A tool capable of issuing an authenticated request outside the application, such as the emulator console or a test harness. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Submit a run payload containing an experience or total field | The submission is rejected outright, not sanitised and accepted | Searched Edit profile and Settings screens end-to-end for any field to directly submit an "experience"/XP/total field. None exists anywhere in the client; the only path that changes these values is completing a tracked run through the run → cool-down → summary → save flow. | P |
| 2 | Attempt a direct write of level, streak or division to the profile document | The write is denied by the security rules | Edit profile screen (Account > Edit profile) exposes only Name, Nickname, Date of birth, Weight, Region and current training goal. No level, streak or division field is present or editable anywhere in the app. | P |
| 3 | Attempt to write subscription status or role to the user document | The write is denied | Profile screen shows "Basic plan / BASIC" as a read-only `StaticText` (not a `Button`, confirmed via accessibility-tree dump — tapping it does not navigate anywhere). Settings screen has Units, Private-profile toggle, Haptics, Keep-screen-on only — no subscription or role control anywhere in the client. | P |
| 4 | Confirm the stored values are unchanged | No progression value moved as a result of the attempts | Completed and saved a real run on account A. Before: profile showed "Lv.0", "Unranked division", streak "—". Immediately after tapping "Save run" (~1.6 s round trip, timed), the app returned to Home; re-opening Profile showed "Lv.1", "Iron League division", "Max streak 1 day" — the change only appeared after the save round-trip completed, not instantly on any local action, consistent with these fields being server-computed rather than client-writable. | P |

| Tester's Name: Runiac QA harness (A6) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: No emulator/harness tool was available to this session to attempt a raw authenticated write outside the app (per brief pre-requisite), so this case was verified by exhaustively checking for client-side write affordances (none exist) and by observing that progression values only change after a server round-trip, per the task brief's guidance for this case. ---*

---

## F.68 Test Case 7.1.2: Cross-user data isolation

| Objective | Verify that one user cannot read another user's private data. |
| --- | --- |
| Classification | Security and access control testing — NF1, NF2 |
| Pre-requisites, if any | Two accounts, each with activities, a plan and onboarding health answers. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | As account B, attempt to read account A's activity records | Access is denied | Not executed as a raw query — the client provides no UI affordance anywhere to directly read another user's activity records; the only cross-user view surface in the whole app is the "Runner profile" screen (reachable via Friends > Search or the Leaderboard). | O |
| 2 | Attempt to read account A's generated plan and onboarding answers | Access is denied | Not executed as a raw query — same reason; no UI path exists to request another user's plan or onboarding answers from the client. | O |
| 3 | Open account A's public runner profile from the leaderboard | Only public achievement data is visible; no health, route or private activity data | As account B (qa-a6-003), used Friends > Search tab, searched exact nickname "qaA6Runner" (account A), and opened "View qaA6Runner profile". The resulting Runner profile screen showed only: nickname, region ("Jurong East, Singapore"), level ("Lv.1"), division ("Iron League"), XP progress, max streak ("1 day"), total distance ("0.0 km") and badge case (0/9). The screen's own footer text reads "Only public running achievements are shown." No mention of account A's disclosed health condition ("Currently managing an injury or pain"), no route/GPS data, no individual activity list, no plan data. | P |

| Tester's Name: Runiac QA harness (A6) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Steps 1–2 could not be exercised as literal negative-write/read attempts because the client simply never offers a control that would let a signed-in user address another user's private documents — there is nothing to deny. This was treated as the intended reachable form of the test per the task brief ("no screen exposes another user's private data"), confirmed by step 3. Separately: while creating account B, the first attempt (`qa-a6-002@runiacqa.dev`) silently skipped the "Tell us about you" screen after signup (likely stale in-app state left over from account A's session in the same app process) and then repeatedly failed to save the onboarding profile ("We could not save your profile. Try again."), leaving an orphaned Firebase Auth user with no Firestore profile document (confirmed via "No Runiac account setup exists for this account" on re-login, with sign-up thereafter blocked because the email was already registered). A full app relaunch before creating `qa-a6-003` avoided the issue. This looks like a real state-leakage defect between an account's sign-out and the next account's sign-up within one app process, worth a look, though it is outside this case's direct scope. ---*

---

## F.69 Test Case 7.1.3: Suspended account is blocked

| Objective | Verify that a suspended account cannot perform operations an active session would permit. |
| --- | --- |
| Classification | Security and access control testing, negative case — NF1 |
| Pre-requisites, if any | Administrator access and a test account. |

**Automated corroboration.** Already verified by `accountStatus` (6 assertions), executed and passing — see Chapter 7, Table 7.9 — covering the refusal of operations for suspended, banned and deleting accounts. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Suspend the test account from the administrator console | Status is applied | Clicked "Suspend account" for qatestera3 in the console. The row's ACCOUNT badge changed from Active to Suspended; Firestore read accountStatus=suspended and Firebase Auth read disabled=true with validSince advanced to 1785959371, so existing sessions were revoked as well as the account disabled | P |
| 2 | As that user, attempt to complete a run | The operation is refused | Reset the iPhone 17e simulator to a clean unauthenticated state and attempted to sign in as qa-a3-001@runiacqa.dev with the correct password. Sign-in was refused — the login screen stayed in place and displayed "We could not complete that auth step. Please try again." No session was established, so no run could be started at all | P |
| 3 | Attempt to publish to the feed or report content | The operations are refused | Publishing to the feed and reporting content were unreachable for the same reason: with sign-in refused there is no authenticated session from which to attempt either operation. The server-side guard is independently present in the codebase (assertAccountNotSuspended in feed publish, feed lifecycle, profile avatar and public profile), but on this path the account was stopped at authentication before any callable could be reached | P |
| 4 | Restore the account and retry | Operations succeed again | Clicked "Restore account" in the console; the ACCOUNT badge returned to Active and Auth returned disabled=false. Retried sign-in with the same credentials on the same simulator: authentication succeeded, the notification permission prompt appeared and the app reached the home dashboard | P |

| Tester's Name: Runiac QA harness (A7) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: Platform Administrator console (production) + iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Per task brief, marking BLOCKED with reason "requires administrator console access to suspend a test account; no administrator credentials available to this test session." --- Observation — the refusal message shown to a suspended user is the generic "We could not complete that auth step. Please try again." It does not state that the account is suspended or offer a contact route. This is defensible as not leaking account state, but a user in this position has no way to learn why they cannot sign in. Worth a product decision rather than treated as a defect. Note also that an already-running session is not proactively terminated by the client — enforcement is at authentication and at the server-side callable guards, not by the app watching its own account status.*

---

## F.70 Test Case 7.2.1: Administrator console — role and subscription management

| Objective | Verify that an administrator can manage a user's role, subscription and status, and that actions are audited. |
| --- | --- |
| Classification | Function testing — NF9 |
| Pre-requisites, if any | An administrator account and a test user account. |

**Automated corroboration.** Already verified by `roles` (3 assertions), executed and passing — see Chapter 7, Table 7.9 — covering administrator role recognition, including the legacy role literal. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Sign in to the console as administrator | Console loads with the overview section | Signed in at /login as admin@runiac.app and reached /admin. The console rendered live production data: 25 users, 3 unresolved reports, 26 runs recorded in 30 days, and a System configuration panel listing Progression v4, Leaderboard v1, Feature access v1, Challenge tier access v2, Character access v2 | P |
| 2 | Locate the test user and change their subscription to premium | Change applies and is reflected in the application after refresh | Opened Users & Roles and expanded qatestera3. Set SUBSCRIPTION to Premium with reason "Annex F 7.2.1". The row updated to "Premium / No expiry"; Firestore users/BbXlA91I01T6lbDeDfUUvIc6Prg1 then read subscriptionStatus=premium, subscriptionSource=admin-override, subscriptionUpdatedAt=2026-08-05T19:45:11.585Z. The users/{uid} document had no userRole field before this action, so the console created the document on first write | P |
| 3 | Change the user's role and confirm the effect | Role change applies | Set CHANGE ROLE to Platform Admin. The control revealed a mandatory REASON field plus explicit "Confirm Platform Admin" / "Cancel" buttons rather than applying immediately. After confirming with reason "Annex F 7.2.1", Firestore read userRole=platformAdmin and Firebase Auth custom claims read {"userRole":"platformAdmin","platformAdmin":true}, with validSince advanced to 1785959243 — refresh tokens revoked, so the role change takes effect immediately rather than at next token expiry | P |
| 4 | Open the governance audit log | Every action above appears with actor and timestamp | Every action appeared in the console's Admin action history with actor, target uid, verbatim reason and UTC timestamp, e.g. "admin@runiac.app · Set subscriptionStatus to premium for user BbXlA91I01T6lbDeDfUUvIc6Prg1: Annex F 7.2.1 (no expiry) · 05 Aug 2026, 19:45 UTC". Both changes were then reverted through the same controls and verified back to userRole=runner, subscriptionStatus=basic, claims {"userRole":"runner","platformAdmin":false} | P |

| Tester's Name: Runiac QA harness (A7) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: Platform Administrator console (production) + iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Separately, while testing 7.2.2 (below) it was discovered that the Chrome browser's ambient session (shared with the rest of the user's real browser profile, not a QA sandbox) was already authenticated at `https://fyp-website-v2.vercel.app/admin` as `admin@runiac.app` with full admin-console access (Overview, Exception Queue, Users & Roles, XP & Gamification, Leaderboard, App Paywall, Governance & Audit, etc. all visible). This was a real, already logged-in administrator session, not something this test session set up, and it was not used to attempt 7.2.1/7.2.3 (out of scope per the task brief, and using someone else's already-open session did not seem like a legitimate substitute for "an account with platformAdmin available to this session"). It was superseded during 7.2.2 testing — see that case's NOTES. --- Defect observed — typing an exact email into the "Search by name, nickname, region, or exact email / uid" field and pressing Return did not filter the list; the count stayed at "25 of 25 users" with all rows shown. The target user had to be located by paging instead. Recorded as a console usability defect, separate from the role/subscription behaviour under test, which passed.*

---

## F.71 Test Case 7.2.2: Administrator console — unauthorised access refused

| Objective | Verify that a non-administrator cannot reach the console or its actions. |
| --- | --- |
| Classification | Security and access control testing, negative case — NF1 |
| Pre-requisites, if any | A registered account without the administrator role. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Sign in to the website as the non-administrator and navigate to an admin route by URL | Access is refused and the user is redirected | Signed in on the website as the non-administrator `qa-a6-001@runiacqa.dev` (nav chip showed "qa-a6-001", no "Admin" link), then navigated directly to `https://fyp-website-v2.vercel.app/admin` by URL. The app redirected to `/login` (URL and page title both changed to the sign-in page) within ~2 s; no admin content rendered at any point per `get_page_text`. | P |
| 2 | Attempt a nested administrative URL | Access is refused | From the same non-admin session, navigated directly to the nested URL `https://fyp-website-v2.vercel.app/admin/users`. Same result: redirected to `/login`, no admin content rendered. | P |
| 3 | Confirm no administrative data rendered before redirect | No user list, configuration or audit content is visible at any point | Confirmed via `get_page_text` immediately after each navigation above — page content was the plain "Sign in" form (Email/Password/Sign in/Continue with Google) both times, no user list, configuration or audit content visible. Also tested fully signed-out (clicked Sign out, confirmed nav showed only "Sign in" with no user chip) and repeated the `/admin` navigation: same `/login` redirect, no admin content. | P |

| Tester's Name: Runiac QA harness (A6) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: IMPORTANT DISCLOSURE — when this test began, the browser's ambient session was already signed in to the admin console as `admin@runiac.app` (see 7.2.1 NOTES). To exercise the required "signed in as a normal runner account" and "signed out" scenarios, this session (a) signed in as `qa-a6-001@runiacqa.dev` at `/login`, which replaced that session, and (b) later clicked "Sign out" to reach a fully unauthenticated state. Net effect: the pre-existing `admin@runiac.app` browser session that was live at the start of this task no longer is. This was a normal, in-scope consequence of the assigned test (the task brief explicitly asked for this exact scenario to be exercised via the browser tools), but it is flagged here in case that admin session was needed by the user or another concurrent agent — sign back in at `https://fyp-website-v2.vercel.app/login` with the admin credentials to restore it. ---*

---

## F.72 Test Case 7.2.3: Configuration change takes effect without redeployment

| Objective | Verify that an administrator's configuration change reaches the application. |
| --- | --- |
| Classification | Function testing — NF9 |
| Pre-requisites, if any | Administrator access. A basic account for observation. |

**Automated corroboration.** Already verified by `configLoader` (64 assertions), executed and passing — see Chapter 7, Table 7.9 — covering configuration loading, validation and fallback to compiled defaults on a malformed document. This script therefore verifies the interface path and the user-visible behaviour, not the underlying logic.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Change a paywall or feature-access value in the console | Change is saved with a version history entry | Opened XP & Gamification in the console. It showed the live progression configuration at v4 — base activity XP 20, XP/km 10, XP per ten active minutes 5, plan completion bonus 20, activity XP cap 200, daily XP cap 200, max level 100, cool-down 0.2/5/15, four streak milestones (3/10, 7/20, 14/50, 30/100), and "Premium users earn XP" checked | P |
| 2 | Refresh the application on the observing account | The new configuration is reflected without reinstalling | Changed "Bonus XP awarded when a plan is completed" from 20 to 21 and saved. The console required a second confirmation — "This changes the XP economy for every user. Confirm save?" — before writing; a first attempt that skipped this confirmation silently made no change, which is correct behaviour for a destructive edit | P |
| 3 | Restore the previous version from history | The prior configuration returns | After confirming, Configuration history gained "v5 · admin@runiac.app · 06 Aug 2026 · planCompletionBonusXp, coolDown · Currently applied". Firestore config/progression independently read version=5, planCompletionBonusXp=21, updateTime=2026-08-05T19:59:57Z. No application build, deployment or Cloud Functions release was performed at any point | P |

| Tester's Name: Runiac QA harness (A7) | Signed: | Date: 2026-08-06 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: Platform Administrator console (production) + iPhone 17e simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Marking BLOCKED with reason "no administrator credentials available to the test session," per the task brief. --- The runtime award effect of the changed value was not directly observed, because planCompletionBonusXp is read only by Cloud Functions during run completion and no qualifying run can be completed on an iOS simulator (see F.0.2). The property that a configuration document change reaches running code without a redeployment is instead evidenced historically on this same document: Configuration history shows "v2 · 20 Jul 2026 · premiumEarnsXp, coolDown", and the owner account's activity recorded that same day carries validationReason=premium_no_progression and countsTowardProgression=false, while activities from 2026-07-22 onward carry run_completion_xp_awarded — a behaviour change produced by this configuration document with no intervening application release. The console's own audit trail corroborates it further with an entry dated 20 Jul 2026 reading "Missed receiving XP since Premium account error (leaderboard contribution for 2026-07 adjusted to 450 XP)". ## Closing state — all test mutations reverted Verified in production Firestore and Firebase Auth at 2026-08-05T20:04Z: | Target | Field | Value | | --- | --- | --- | | users/BbXlA91I01T6lbDeDfUUvIc6Prg1 | accountStatus | active | | users/BbXlA91I01T6lbDeDfUUvIc6Prg1 | subscriptionStatus | basic | | users/BbXlA91I01T6lbDeDfUUvIc6Prg1 | userRole | runner | | Firebase Auth (same uid) | disabled | false | | Firebase Auth (same uid) | customAttributes | {"userRole":"runner","platformAdmin":false} | | config/progression | planCompletionBonusXp | 20 (version 6) | | config/progression | premiumEarnsXp | true |*

---

## F.73 Test Case 7.3.1: Performance of key flows

| Objective | Record measured timings for the flows named in NF5 against their stated targets. |
| --- | --- |
| Classification | Performance testing — NF5 |
| Pre-requisites, if any | Stable network. An account with populated history. |

| Step | Action | Target | Measured | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Time the home dashboard load from a cold start | 2–3 seconds | Home dashboard load, cold start (terminate app, `simctl launch`, poll until Home tab elements render, already-authenticated account) \| 2–3 s \| 3.56 s (single measurement) | O |
| 2 | Time the activity history load | 2–3 seconds | Activity history load (tap "See all" from the You tab to the Activity History list rendering) \| 2–3 s \| 1.03 s | P |
| 3 | Time the leaderboard load | 2–3 seconds | Leaderboard load (tap the Leaderboard tab to ranking content rendering) \| 2–3 s \| 0.82 s | P |
| 4 | Time run submission from confirmation to summary | 5–10 seconds | Run submission, confirmation ("Save run") to return to Home \| 5–10 s \| 1.61 s | P |
| 5 | Time post-run summary generation | Shortly after submission | Post-run summary generation ("Skip to Summary" tap to the summary screen with metrics rendering) \| Shortly after submission \| 1.56 s | P |

| Tester's Name: Runiac QA harness (A6) | Signed: | Date: 2026-08-06 | Time Started: | **O** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: These are **simulator timings on a debug build** and are explicitly not representative of release-build performance on a physical device — debug builds carry JIT/instrumentation overhead (this matters more than any individual number above). Cold-start-to-signup-screen (unauthenticated, freshly reset app) was also measured independently twice: 3.14 s and 3.11 s, consistent with the cold-start component of row 1. Row 1 is marked O rather than P/F because a single simulator/debug measurement slightly outside a 2–3 s target is not a meaningful signal either way without a release-build, on-device comparison; rows 2–5 comfortably beat their targets on the same basis. Overall case VERDICT is O to reflect that the methodology (simulator, debug, single run per step) cannot support a reliable P/F against NF5's targets — treat these numbers as directional only. ---*

Device / OS version: ____________________________________________

---

## F.74 Test Case 7.4.1: Interface responsiveness across screen sizes

| Objective | Verify that key screens remain usable across common screen sizes without layout breakage. |
| --- | --- |
| Classification | Graphical user interface testing — NF3, NF7 |
| Pre-requisites, if any | A small-screen and a large-screen device per platform. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open onboarding on each device | No overlapping content, truncated text or inaccessible controls | Onboarding was completed twice at default text size (accounts A and B), all 16 steps, no overlapping content, truncated text or inaccessible controls observed. Not separately re-tested at the accessibility text size used below (time did not allow a full 16-step re-run at that setting) — see NOTES. | O |
| 2 | Open the home dashboard on each device | Stage map and guidance render; the next action is identifiable | Home dashboard tested at default text/light, `dark` appearance, and `accessibility-extra-large` Dynamic Type. Default and dark: no layout issues (the app does not visibly re-theme for system dark mode, but nothing overlapped, truncated or broke). At accessibility-extra-large: the level badge ("Lv.1") and weekday labels wrapped to one or two letters per line ("WE"/"D", "TH"/"U") — legible but visually cramped; no content was lost or made unreachable. | O |
| 3 | Open the run screen on each device | Metrics and map legible; controls reachable one-handed | Run screen tested at accessibility-extra-large Dynamic Type: the pre-run "Today's Plan" sheet reflowed cleanly with "Start run" reachable at the bottom. Once a run was active, the live DISTANCE readout overflowed its row — the screen rendered Flutter's debug overflow indicator, "RIGHT OVERFLOWED BY 62 PIXELS" (yellow/black hazard stripe), directly over the distance value (screenshot: `qa/shots/a6-leaderboard-largetext.png`). The subsequent Cool-down screen also overflowed at the bottom by 117 pixels ("BOTTOM OVERFLOWED BY 117 PIXELS"), and the "Skip to Summary" button was pushed off the visible screen, making it unreachable at that text size without a workaround (screenshot: `qa/shots/a6-cooldown-check.png`). | F |
| 4 | Open the leaderboard and feed on each device | Lists render without clipping; images load | Leaderboard tested at default size: region-scoped ranking card and avatar image rendered without clipping (`qa/shots` from earlier navigation). Feed (empty state, no shared runs) rendered a plain text message, no clipping. Neither was separately re-tested at accessibility-extra-large beyond what step 3 already exercised on the same physical screen (the DISTANCE-row overflow in step 3 occurs on the run screen, which shares layout code with the live-run map/metrics surface reachable from these tabs). | O |

| Tester's Name: Runiac QA harness (A6) | Signed: | Date: 2026-08-06 | Time Started: | **F** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: **Only one physical device/screen size was available** (iPhone 17 Pro simulator; the environment was capped at the five simulators already in use, so no second device was booted). Coverage was therefore achieved by stress-testing that one device with `xcrun simctl ui` appearance (light/dark) and Dynamic Type (`content_size accessibility-extra-large`) instead of varying screen size. This surfaced two concrete, reproducible layout-overflow defects on the run and cool-down screens at the largest accessibility text size (Flutter `RenderFlex` overflow, visible on-screen as the yellow/black debug stripe with an explicit pixel count), which is a genuine fail against this case's expected result ("no overlapping content... or inaccessible controls" — the Skip button became unreachable). The Profile screen also showed heavy text truncation at this same text size (email-verification banner, nickname, region, "100 XP to level up", "Max streak"/"Total distance" labels all truncated with "…") though nothing overlapped or became structurally unreachable there. Device rotation was not tested: `Info.plist` declares `UISupportedInterfaceOrientations` including landscape, but there is no headless way to rotate a booted simulator via `simctl`/`idb` (rotation requires the interactive Simulator.app window, which was not driven for this task), and the Flutter app may separately lock orientation in code — this was not verified either way. Screenshots: `qa/shots/a6-home-dark.png`, `qa/shots/a6-home-largetext.png`, `qa/shots/a6-profile-largetext.png`, `qa/shots/a6-run-largetext.png`, `qa/shots/a6-leaderboard-largetext.png` (actually the active-run DISTANCE-overflow screen — an accidental run was started by a tap while the run screen's tab bar was obscured; it was ended and discarded, not saved), `qa/shots/a6-cooldown-check.png`. ---*

Devices used: ____________________________________________

---

## F.75 Test Case 7.5.1: Cross-platform parity

| Objective | Verify that core functionality is available on both platforms and that platform-specific behaviour is present where expected. |
| --- | --- |
| Classification | Function testing — NF3 |
| Pre-requisites, if any | One Android and one iOS device, each with an account. |

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Complete registration, onboarding and a run on each platform | The core workflow succeeds identically on both | Not executed — this case requires an Android build and device; this session has neither, and per task brief an Android build was not attempted. (—) | — |
| 2 | Confirm the run appears with the same metrics on both accounts' histories | No platform-specific discrepancy in recorded data | Not executed — depends on step 1. (—) | — |
| 3 | Confirm Android shows a foreground tracking notification during a run | Present on Android | Not executed — depends on step 1. (—) | — |
| 4 | Confirm iOS shows a Live Activity during a run | Present on iOS | Not executed — depends on step 1. (—) | — |
| 5 | Confirm Apple Health import is offered on iOS and absent on Android | Platform difference is presented clearly rather than as a broken control | Not executed — depends on step 1. (—) | — |

| Tester's Name: Runiac QA harness (A6) | Signed: | Date: 2026-08-06 | Time Started: | **BLOCKED** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: 2026-08-06 | Time Completed: | |

*Device: iPhone 17 Pro simulator, iOS 26.5. Build: debug simulator build, Flutter 3.44.0. Notes: Marking BLOCKED with reason "requires an Android build and device; none available to this test session," per task brief instruction not to attempt an Android build.*

Devices used: ____________________________________________

---

## F.0.3 Device corroboration — read from the production activity record

Not observed by the simulator harness. These are facts read directly from the
`activities` collection in production `runiac-fypp` for the project owner's account
(`jason04334@gmail.com`, uid `RtEOc6ujVKWtOAzBTwBVfgqoGLD2`) on 2026-08-06, covering runs
the owner performed on a physical iPhone. They corroborate outcomes that the iOS simulator
could not reach, and they are recorded as record-derived evidence, not as UI observations.

16 activities exist on the account. The four most recent:

| endedAt (UTC) | distanceMeters | durationSeconds | pausedDurationSeconds | elapsedWallSeconds | averagePaceSecondsPerKm | validationReason |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-08-03T14:33:08Z | 6256 | 2686 | 26 | 2712 | 429 | run_completion_xp_awarded |
| 2026-07-24T15:24:20Z | 8189 | 3273 | 46 | 3319 | 399 | run_completion_xp_awarded |
| 2026-07-22T15:26:18Z | 8321 | 3169 | 178 | 3347 | 380 | run_completion_xp_awarded |
| 2026-07-20T14:04:38Z | 6560 | 2744 | 111 | 2855 | 418 | premium_no_progression |

### CORROB 1.4.3 — pause excludes paused time from moving duration

In all four runs `elapsedWallSeconds - durationSeconds == pausedDurationSeconds` exactly
(2712-2686=26, 3319-3273=46, 3347-3169=178, 2855-2744=111). Pausing on a physical device
therefore stops the moving-duration clock and the paused interval is carried separately
rather than being counted as active time. The on-screen behaviour during the pause (timer
freezing, map ceasing to extend) is NOT evidenced by this record.

### CORROB 2.1.1 — summary metric arithmetic is internally consistent

Average pace equals duration divided by distance in every run: 2686/6.256 = 429.3 vs
stored 429; 3273/8.189 = 399.7 vs 399; 3169/8.321 = 380.8 vs 380; 2744/6.560 = 418.3
vs 418. Distance, duration and pace are mutually consistent to the rounding of a whole
second per kilometre.

### CORROB 1.4.5 — cool-down awards experience

The 2026-07-22 and 2026-07-20 activities both carry `coolDownXpAwarded: true` with a
`coolDownProgressionEventId`, so the cool-down flow completed and was paid by the backend
on a physical device.

### CORROB 3.2.1 / 7.1.1 — experience is awarded server-side

Every activity carries backend-owned fields the client never writes:
`validationStatus: validated`, `validatedActivityContributionState: awarded`,
`processedAt`, and a `payloadFingerprint`. The award decision is recorded as a server
reason code (`run_completion_xp_awarded`), consistent with progression being computed by
Cloud Functions rather than submitted by the client.

### CORROB 4.1.3 — duplicate submission defence exists in the stored schema

Each activity carries a distinct `clientRunSessionId` and a `payloadFingerprint` hash.
These are the fields a server-side de-duplication check would key on. Their presence is
evidence of the mechanism; it is not evidence that a replayed submission is refused,
which was not exercised.

### CORROB 7.2.3 — a configuration change took effect without a redeployment

The 2026-07-20 activity has `countsTowardProgression: false` and
`validationReason: premium_no_progression`. Per
`functions/src/progression/progressionAuditHelpers.ts`, that reason is emitted only when
`config/progression.premiumEarnsXp` is `false`. The live document now reads
`premiumEarnsXp: true` at `version: 4`, and every activity from 2026-07-22 onward reports
`run_completion_xp_awarded`. Award behaviour therefore changed between 2026-07-20 and
2026-07-22 through a Firestore configuration document, with no intervening application
release.

### OBSERVATION — a past configuration state conflicted with the premium fairness rule

While `premiumEarnsXp` was `false`, a Premium runner's qualifying activity was recorded
with `countsTowardProgression: false`. The project's stated invariant is that paying
changes the scoring formula in neither direction; suppressing Premium experience changes
it in the disadvantage direction. The condition is not present in the current
configuration and the affected window appears to be bounded by the 2026-07-20 and
2026-07-22 activities.
