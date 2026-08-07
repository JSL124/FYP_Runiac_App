# Annex F2: Re-test of the failed manual test scripts

## F2.1 Purpose and scope

Annex F records the manual execution of 65 test scripts. Five were scored **F**. This annex
re-executes those five, and only those five: every other script's verdict in Annex F stands
unchanged and is not repeated here.

| Annex F | Test case | Verdict in Annex F | Failing step |
| --- | --- | --- | --- |
| F.17 | 1.4.6 Run tracking, voice coaching | F | 3 — milestone reached, no announcement spoken |
| F.45 | 5.2.2 Block and unblock a user | F | 2 — a blocked account could still open the blocker's runner profile |
| F.46 | 5.3.1 Distance challenge lifecycle | F | 3 — the Challenge tab failed to load and the challenge could not be started |
| F.54 | 6.2.1 AI activity feedback, safety and quota | F | 3 and 4 — no reset time on refusal; Basic account met the paywall |
| F.56 | 6.2.3 AI workout briefing | F | 3 — no reset time on refusal |

*Table F2.1: The five scripts carried into this annex*

Each case below states what was found to be the cause, what changed in response, and the
re-executed script. A step that was not re-executed keeps its Annex F verdict and says so.

## F2.2 Build and environment under test

| Item | Value |
| --- | --- |
| Repository commit | `47946e71` plus the quota-notice change described in F2.4 |
| Build | Debug build against production Firebase (`runiac-fypp`) |
| Flutter | 3.44.0 (framework revision 559ffa3f75) |
| Device (pre-verification) | iPhone 17 simulator, iOS 26.5 |
| Device (confirmation run) | _To be completed by the tester_ |
| Date | 2026-08-08 |

Two-stage execution. The **pre-verification** stage was run on the simulator to establish that
each fix behaves as intended; it is recorded separately and is not a substitute for the
tester's run. The **confirmation** stage repeats every step on a physical device and carries the
signature. Any step verified only in pre-verification is labelled as such in its Actual Result.

**Accounts.** Fresh accounts are used rather than the accounts from the original run. The
friend-graph carries deliberate cooldowns — a declined friend request locks that sender for
seven days, a cancelled request or a removed friendship for twenty-four hours — so the original
accounts would fail to pair for reasons unrelated to any of these five scripts.

**Production state.** Pre-verification ran against production rather than an emulator, so that
the deployed callables and rules are the ones under test. Every change it made was undone: the
challenge lobby created for F.46 was cancelled, the two documents seeded for F.56 were deleted
and re-verified absent, and the account created for F.45 was removed through the application's
own account-deletion flow once the script was complete. That deletion is recorded in F2.7.

## F2.3 Summary of outcomes

None of the five failures reproduced. Two were closed by a code fix, one by correcting a script
expectation that Chapter 2 had already superseded, and two did not reproduce at all. Three
carry a verdict now — 1.4.6 and 6.2.1 from the tester's own runs, 6.2.3 from a refusal observed
in the running app. The remaining two (5.2.2 and 5.3.1) did not reproduce in pre-verification but
keep an unsigned verdict until the tester repeats them on a device; the signature blocks below
say which is which.

| Annex F | Test case | Annex F | What changed | Re-test |
| --- | --- | --- | --- | --- |
| F.17 | 1.4.6 Voice coaching | F | No code change — pipeline unchanged | Re-tested by the tester and reported passing; per-step record outstanding |
| F.45 | 5.2.2 Block and unblock | F | No code change — the block was already enforced server-side | Defect did not reproduce in pre-verification; confirmation run pending |
| F.46 | 5.3.1 Distance challenge lifecycle | F | Client fix, commit `47946e71` | Defect did not reproduce in pre-verification; confirmation run pending |
| F.54 | 6.2.1 AI activity feedback | F | Step 3: client fix. Step 4: expected result corrected | **P** — step 3 re-tested by the tester, step 4 passes against the corrected expectation |
| F.56 | 6.2.3 AI workout briefing | F | Client fix (same change as F.54 step 3) | **P** — step 3 confirmed in the running app: the refusal now names the reset day |

*Table F2.2: Re-test outcomes*

---

## F2.4 What changed before re-testing

### F2.4.1 Challenge tab load failure (F.46 step 3)

The Challenge hub reads the `getActiveChallenge` callable and parses its response strictly.
The participant row parser required a non-empty `levelLabelSnapshot`. The backend resolves that
label live from the runner's profile, where the level is written only once a run has awarded
experience, so a runner who has never completed a run resolves to an empty label. One such
member on the roster therefore failed the entire response, and the hub reported
"Something went wrong. Please try again." to **every** member of the lobby. A relaunch could not
clear it because the cause was stored data rather than client state. The lobby screen itself kept
working because its live-update path substitutes a placeholder before parsing — which is why the
failure appeared to be confined to the hub.

The parser now reads the label leniently, matching the field's own documented contract and the
sibling fields beside it. Fixed in commit `47946e71`, with regression tests for an empty and an
absent label.

### F2.4.2 Quota refusal did not state a reset time (F.54 step 3, F.56 step 3)

The backend already returned the reset day: a refused generation answers with `retryAfterDate`,
the next Singapore calendar day, and both client models already carried it. No screen rendered
it — the refusal served the same generic copy as a provider outage, so the runner could tell
neither why the copy was generic nor when they could generate again.

Both surfaces now lead the first page with a notice naming the reset day, for example
"Daily limit reached — personalised feedback unlocks again on 9 August 2026." The day is always
the server's; the client never derives one, and the notice deliberately never states the limit,
which is server-owned and configurable. A refusal that arrives without a date still says the
surface resets, without naming a day. Covered by unit and widget tests on both surfaces.

### F2.4.3 Corrected expected result (F.54 step 4)

No code changed. Chapter 2 states that all three generated surfaces are Premium and that a Basic
user meets the paywall at each of them. Script 6.2.1 step 4 still carried the pre-correction
expectation, "Deterministic template feedback is shown", and script 6.2.3 step 4 — the same
behaviour on the briefing surface — already expects the paywall and passed. The application
behaved as Chapter 2 describes; the script's expected result was stale. It is corrected below to
"The Premium paywall is presented and no generation occurs", and the step is re-scored against
the corrected expectation. This is recorded as a correction to the script, not as a defect fixed.

### F2.4.4 Voice coaching (F.17 step 3)

_To be completed: investigation outcome._

### F2.4.5 Block visibility (F.45 step 2)

The server refuses a blocked viewer on both paths that can reach another runner's profile: the
friend search returns no result when a block document exists in either direction, and the public
profile callable denies with a not-found response under the same condition. Both checks predate
the original test run. The re-test therefore first establishes which account is signed in and
that the block is in place, then repeats the step; the evidence records the signed-in account so
the result cannot be ambiguous.

Worth stating for the record, because it affects how the step is read: with **no** block in
place, any signed-in runner may open any discoverable runner's public profile. That is the
designed behaviour — the profile carries achievements only, never routes, activities, health or
contact data — so the step only demonstrates anything while the block is visibly active.

---

## F2.5 Re-executed scripts

_Each script below is re-executed in full. Completed after execution._

### F.17R Test Case 1.4.6: Run tracking, voice coaching

**Re-tested by the tester and reported as passing** on 2026-08-08. Step 3 — the announcement at
the first milestone — is reported to have been spoken, which is the step Annex F scored F.

The device, build and per-step results are for the tester to record here; they are deliberately
left blank rather than filled in on their behalf, since this agent did not observe the run. No
code change was made to the voice-coaching path, so the difference is environmental rather than a
fix: the announcement pipeline is unchanged and was already covered by around twenty automated
test files. Worth noting for the record, because it explains why the original run could not
diagnose itself: the coordinator deliberately swallows text-to-speech failures so a failed
utterance cannot interrupt a run, which means a silent milestone leaves no user-visible trace.

| Step | Action | Expected Result | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | Open voice settings and preview a message | The preview is spoken | _tester to complete_ | |
| 2 | Configure a distance or time milestone interval and save | Settings persist | _tester to complete_ | |
| 3 | Start a run and pass the first milestone | The announcement is spoken at the milestone | _tester to complete — reported as spoken_ | |
| 4 | Disable voice coaching and repeat | No announcement is spoken | _tester to complete_ | |

| Tester's Name: | Signed: | Date: 2026-08-08 | Time Started: | **P (reported)** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: | Time Completed: | |

### F.45R Test Case 5.2.2: Block and unblock a user

**Pre-verification, two simulators, 2026-08-08.** Executed against production Firebase with two
accounts on two devices rather than one device switching sessions — the original run signed
accounts in and out on a shared device, and a mis-identified session is one of the two candidate
explanations for the original result. Account A is `qatestera5` (iPhone 17 simulator) and account
B is `qaretestb` (iPhone 17e simulator), freshly created for this re-test so no friend-graph
cooldown applies. Both were made friends first, satisfying the script's pre-requisite.

**Control, before blocking.** From B, searching the exact nickname `qatestera5` returned the row
with a working profile link, and opening it loaded A's runner profile
(`5.2.2-control-search-before-block.png`, `5.2.2-control-profile-reachable-before-block.png`).
This reproduces the original observation and confirms the mechanism it depends on: a runner's
public profile is reachable by any signed-in runner **while no block exists**, by design.

| Step | Action | Expected Result | Actual Result (pre-verification) | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account A, block account B | The friendship ends and B's content disappears from A's timeline | Friends > "More actions for qaretestb" > Block, confirmed on the dialog "Block qaretestb? This removes the friendship and pending requests in both directions. You will no longer appear to each other in Friends, Search, or Feed." A's Friends tab went to "No friends yet" and the Blocked tab listed qaretestb with an Unblock control (`5.2.2-step1-block-confirmation.png`, `5.2.2-step1-blocked-tab.png`) | P |
| 2 | From account B, attempt to view account A's profile or content | Content is not reachable | On B — confirmed signed in as `qaretestb` from its own Profile screen (`5.2.2-signed-in-account-b.png`) — searching the exact nickname `qatestera5` returned "No runners found. No runner matched that nickname." The row is gone, so the profile link the original run followed no longer exists and A's profile is unreachable from B (`5.2.2-step2-search-returns-nothing.png`). The original failure did not reproduce | P |
| 3 | Unblock from account A | Blocking is lifted; no friendship is automatically restored | From A, Blocked > "Unblock qaretestb" and confirmed. The Blocked tab emptied to "No blocked runners" and the Friends tab stayed "No friends yet" — lifted, with no friendship restored (`5.2.2-step3-unblocked.png`) | P |

*Control after step 3.* Repeating B's search with the identical, verified query immediately
returned the row again. The empty result in step 2 is therefore attributable to the block and to
nothing else — the search text was screenshotted in the field on both runs so the query cannot be
in doubt.

*Why the original run is likely to have differed.* The two candidate explanations were a
mis-identified session and a stale deployment. The deployment is ruled out: `searchFriends`,
`getRunnerPublicProfile` and `blockUser` are all live in `asia-southeast1` and enforce the block
in both directions, and this run exercised exactly those deployed functions. The re-test also
notes that the original run recorded the "Please wait a moment and try again." message for the
refused friend request, which the client maps to a rate-limit/cooldown code — a blocked sender
receives "That friend state changed. Refresh and try again." instead. That is consistent with the
step having been performed from an account that was not the blocked one.

| Tester's Name: _confirmation run pending_ | Signed: | Date: | Time Started: | **pending** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: | Time Completed: | |

### F.46R Test Case 5.3.1: Distance challenge lifecycle

**Pre-verification, iPhone 17 simulator, 2026-08-08.** Executed against production Firebase on a
build carrying the fix. The condition that caused the original failure was reproduced
deliberately: the signed-in account (`qatestera5`) has never completed a run, so it carries no
backend-resolved level — the lobby roster renders it as `Lv.0`, the display-only placeholder for
an unresolved level (`5.3.1-lobby-owner-unresolved-level.png`).

| Step | Action | Expected Result | Actual Result (pre-verification) | P/F/O |
| --- | --- | --- | --- | --- |
| 1 | From account A, create a lobby at a non-premium distance tier | Lobby is created and shown | Menu > Challenge > 10K Beginner > "Create challenge" opened the lobby: "10K, Lobby closes in 23:59:59, 1/2, qatestera5 · You · Owner" | P |
| 2 | Invite account B; accept from B | B joins the lobby | Not re-executed on the simulator — needs a second account; carried to the confirmation run. Annex F scored this step P | — |
| 3 | Start the challenge from account A | Challenge becomes active for both participants | Returning to the Challenge hub with the lobby active — the exact navigation that previously failed — loaded normally, showing "You already have a challenge in progress" and the 10K tile marked "In progress" (`5.3.1-step3-hub-loads-with-active-lobby.png`). Reopening the lobby showed both "Start challenge" and "Cancel challenge" as reachable controls. The original failure did not reproduce. Starting with a second participant is carried to the confirmation run | P (partial — see note) |
| 4 | Complete a run on each account | Distance contributes to each participant's progress | Not re-executed: needs real distance, and Annex F already scored this step P | — |
| 5 | On reaching the goal, confirm the badge | Badge is granted and appears in challenge history | Not re-executed: Annex F already scored this step P | — |

*Note on step 3.* The pre-verification proves the defect is gone: the hub renders a roster
carrying a member with no resolved level, which is what previously failed the whole response and
left the tab unusable for every member of the lobby. It does not by itself re-prove
"active for both participants", which needs the second account and is carried to the confirmation
run. The lobby was cancelled afterwards, and the hub returned to a clean catalogue, so the test
account carries no leftover challenge.

| Tester's Name: _confirmation run pending_ | Signed: | Date: | Time Started: | **pending** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: | Time Completed: | |

### F.54R Test Case 6.2.1: AI activity feedback, safety and quota

**Step 3 (no reset time).** The change described in F2.4.2 is in the build and is covered by
tests on both surfaces: a quota response now leads the first page with "Daily limit reached —
personalised feedback unlocks again on 9 August 2026.", a refusal that arrives without a date
still states that the surface resets, and a provider outage — a different fact — is left without
the notice. The identical mechanism was **observed in the running app on the briefing surface**
(see F.56R step 3), which shares the notice, the date formatting and the server field.

The activity-feedback surface itself opens only from a completed activity, which neither
pre-verification account had. **The tester re-ran this step on their own account and reported it
passing** on 2026-08-08: the refused generation communicated its reset time.

**Step 4 (Basic account).** Re-scored against the corrected expected result, per F2.4.3.

| Step | Action | Expected Result (step 4 corrected, per F2.4.3) | Actual Result | P/F/O |
| --- | --- | --- | --- | --- |
| 3 | Generate five times in one day, then attempt a sixth | The sixth is refused and the reset time is communicated | Re-tested by the tester and reported passing — the refusal now states when the quota resets. The same mechanism, notice and server field were observed directly on the briefing surface in pre-verification (see F.56R step 3, `6.2.3-step3-quota-reset-notice.png`) | P |
| 4 | Repeat step 1 on a basic account | The Premium paywall is presented and no generation occurs | The generated surfaces are Premium and a Basic account meets the paywall: on account `qaretestb` (Basic), opening the guidance action listed "AI activity feedback" among the Premium features and presented the subscribe sheet without generating anything (`6.2.3-step4-basic-paywall.png`) | P |

Steps 1 and 2 are not re-executed: Annex F scored both P, and neither the code change nor the
script correction touches generation quality or prohibited-content screening.

Step 3's Actual Result is the tester's report; this agent observed the identical notice on the
sibling surface, not on activity feedback itself. The device and time for step 3 are left for the
tester to record.

| Tester's Name: | Signed: | Date: 2026-08-08 | Time Started: | **P** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: | Time Completed: | |

### F.56R Test Case 6.2.3: AI workout briefing

**Step 3 (no reset time) — confirmed in the running app.**

| Step | Action | Expected Result | Actual Result (pre-verification) | P/F/O |
| --- | --- | --- | --- | --- |
| 3 | Request six briefings in one day | The sixth is refused with the reset time communicated | With the day's quota already spent, opening "Explain today's workout" on account `qatestera5` returned the refusal and the first page read "Daily limit reached — your workout briefing unlocks again on 9 August 2026.", followed by the deterministic session copy (`6.2.3-step3-quota-reset-notice.png`). The reset day is the server's own value, relayed by the deployed callable | P |

*How the refusal was reached, and what was changed to reach it.* Driving the sixth request
naturally would have spent five paid model generations and still needed a Premium account. Two
production documents were therefore written directly, with the user's approval, and reverted
immediately afterwards: `users/{uid}.subscriptionStatus` was set to `premium` (the document did
not previously exist), and the day's usage counter
`agentUsage/{uid}/workoutBriefingDaily/20260808` was seeded at the daily limit (also previously
absent). This exercises the real callable, the real entitlement check and the real quota
transaction — the refusal path is reached before any model call, so no generation was purchased
and no generated content was affected. Both documents were deleted after the screenshot and
re-verified absent, returning the account to exactly its prior state.

Steps 1, 2 and 4 are not re-executed: Annex F scored all three P. Step 4's behaviour was
nonetheless observed again in passing — a Basic account meets the paywall and no briefing is
generated (`6.2.3-step4-basic-paywall.png`).

| Tester's Name: pre-verification run | Signed: | Date: 2026-08-08 | Time Started: | **P (pre-verification)** |
| --- | --- | --- | --- | --- |
| Witness: | Signed: | Date: | Time Completed: | |

---

## F2.6 Evidence index

Screenshots are stored under `docs/final-report/testing/retest/`.

| File | Shows |
| --- | --- |
| `5.2.2-control-search-before-block.png` | Before blocking: B's search returns A's row with a profile link |
| `5.2.2-control-profile-reachable-before-block.png` | Before blocking: A's runner profile opens from that row — the designed behaviour with no block in place |
| `5.2.2-step1-block-confirmation.png` | The block confirmation A accepted, stating the effect on Friends, Search and Feed |
| `5.2.2-step1-blocked-tab.png` | A's Blocked tab listing qaretestb after the block |
| `5.2.2-signed-in-account-b.png` | B's own Profile screen, establishing which account performed step 2 |
| `5.2.2-step2-search-returns-nothing.png` | Step 2: the exact nickname in the search field and "No runners found" — no row, no profile link |
| `5.2.2-step3-unblocked.png` | A's Blocked tab empty after the unblock, with no friendship restored |
| `5.3.1-lobby-owner-unresolved-level.png` | The created lobby with its only roster member carrying no resolved level — the condition that triggered the original failure |
| `5.3.1-step3-hub-loads-with-active-lobby.png` | The Challenge hub loading normally with that lobby active, where it previously reported "Something went wrong. Please try again." |
| `6.2.3-step3-quota-reset-notice.png` | The refused briefing naming its reset day on the first page of the guidance overlay |
| `6.2.3-step4-basic-paywall.png` | A Basic account meeting the Premium paywall on the guidance surface, with no generation |

_Remaining evidence is added as each script is executed._

## F2.7 Incidental observation: account deletion did not complete

Not one of the five scripts, and recorded here only because the re-test exercised it. The test
account created for F.45 was deleted afterwards through the application's own flow: the
confirmation was typed, the account signed out immediately, `users/{uid}` was reduced to
`accountStatus: deleting` with a deletion timestamp, and the runner's `socialDiscoveryStatus`
flipped to `inactive` — so the account is locked and no longer discoverable. However, roughly
two minutes later the Firebase Authentication record and the `userProfiles/{uid}` document were
both still present.

This matches the observation Annex F already records against script 1.5.1, where sign-in was
refused after deletion but sign-up still reported that an account existed for the email. It is
consistent with the deletion sweep's collection-group indexes not yet being deployed, which is a
known outstanding deployment item rather than a new defect. It is flagged for follow-up; script
1.5.1 keeps its Annex F verdict and is not re-scored here.
