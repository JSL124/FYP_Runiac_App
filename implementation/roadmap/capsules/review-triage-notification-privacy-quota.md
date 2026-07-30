# Capsule: Review-Triage — Notification Delivery, Owner Isolation, Redaction, and Model-Spend Cap

Status: implemented locally. Not committed, not deployed.
Routed: 2026-07-30 Asia/Singapore (explicit user request).
Lane: Backend Guarded Lane (ADR-002 emulator-first, ADR-003). Backend changes
are behaviour fixes to existing functions plus one operator-CLI safety guard;
no new function, collection, index, `firestore.rules`, or dependency.

An external Codex code review produced 26 findings across the backend, the
Flutter client, the admin website, and the rules test wiring. Every finding was
re-verified against the code before anything was changed. This capsule carries
only the findings that were **confirmed to be real, contained, and testable**.
Findings that were refuted, that restate a deliberate recorded decision, or
that need a product decision are listed at the bottom and are deliberately
**not** implemented here.

## Confirmed defects fixed

1. **User-set reminder times mostly never fired.**
   `functions/src/notifications/dispatchPlanner.ts` matched a reminder on its
   exact minute (`offset === reminder.minutes`), but
   `dispatchScheduledPushNotifications` runs on an `every 10 minutes` schedule
   and every reminder offset is a multiple of ten. A workout whose start minute
   was not on that same ten-minute grid therefore produced offsets of -119,
   -109, … and never the -120/-60/-10 the planner asks for — it received **no
   reminder at all, ever**. Stored plans really do carry such times
   (`'7:01 PM'`, `'6:15 PM'`). Each reminder is now due for a window starting at
   its target offset; the `today_plan_midnight` and streak-risk `minute === 0`
   conditions are widened for the same reason. The window size and the dedup
   that makes it safe were both corrected in the follow-up round below — this
   first round used a bare sweep interval and asserted a duplicate-send
   guarantee that did not hold.

2. **Mock-data cleanup could regress the live leaderboard.**
   `functions/src/leaderboard/leaderboardSeedMutation.ts` passed the seed run's
   own `periodKey` to `refreshMonthlyLeaderboardSnapshots`, which is not
   period-scoped in its side effects: it repoints
   `leaderboardPeriods/monthly_current` at whatever key it is handed and prunes
   every projection outside `retainedPeriodKeys(thatKey)`. `assertProductionDatasetScope`
   deliberately **exempts** cleanup, so a cleanup may legitimately name a past
   `--period` — which would have pointed the app at a finished month and
   deleted the live month's snapshots and ranks. This is the same defect
   already closed in `leaderboardAdminCommand.ts`. The cleanup path now
   refreshes `currentSingaporeMonthKey(new Date())`. The seed run's own
   projections are removed by the id-scoped bulk delete, so nothing depends on
   re-aggregating the historical period.

3. **GPS coordinates survived error-report sanitisation.**
   `functions/src/errors/sanitize.ts` redacts digit runs of 5+, but a decimal
   point splits a coordinate into runs of 1–4, so a pair such as
   `1.3521, 103.8198` was stored verbatim in a report flagged `sanitized: true`.
   A coordinate-pair pattern now runs before the digit/token patterns (which
   would otherwise chew the pair into unrecognisable pieces). The labelled form
   (`latitude=1.3521`) was missed here and is added in the follow-up round
   below.

4. **A failed sign-out let the previous account's pushes reach the next
   account's inbox.**
   `notification_registration_service.dart` performed the remote
   `unregisterDevice` **before** local teardown. A sign-out while offline
   throws there, leaving `_started` true and the previous owner's FCM
   subscriptions live; the next sign-in re-attached the app's listener to that
   same stream while `start()` no-oped, and the inbox repository resolves the
   owner uid at write time — so a push addressed to the signed-out account was
   written into the new account's inbox. Local isolation now happens first and
   unconditionally; the remote call follows.

5. **Account switch mid-pass wrote one runner's notifications into another's
   inbox.** `plan_notification_delivery_materializer.dart` captured the owner
   once and then awaited the ledger and the platform delivery reader before
   writing, while each write re-resolved the owner inside the repository. The
   pass now re-checks the owner before every write and stops on a change.
   Entries already written are still dropped from the ledger (they genuinely
   reached the previous owner); the rest are retried on a later pass.

6. **Uncapped model spend on Activity Feedback.**
   `functions/src/agent/activityFeedbackQuota.ts` defaulted to
   `"unlimited-development"`, and the callable never passes a policy — so the
   development value was the only one production ever used and an entitled
   runner could drive an unbounded number of paid model calls. The default is
   now `"enforced"` (`DEFAULT_ACTIVITY_FEEDBACK_QUOTA_POLICY`), giving the
   already-implemented five-per-Singapore-day cap real effect. The user
   explicitly authorized this cap for Premium users on 2026-07-30.
   `"unlimited-development"` survives as a value but must be injected by name.
   Note the reservation is taken **before** the provider call, so a failed
   generation spends an attempt — an attempt that reached the provider is
   exactly what the cap counts.

7. **`javascript:` URLs accepted for the public APK download link.**
   `website/src/lib/site-download.ts` validated `apkUrl` only as a non-empty
   string, and the value becomes the public download page's `href`. It is now
   restricted to an `https:` URL or a site-relative path (protocol-relative
   `//host` and `/\host` rejected), enforced both at render-time merge and at
   admin save time so the administrator sees why a value was refused.

8. **Friends rules tests never ran in CI.**
   `tests/firebase-rules/package.json` enumerates its suites explicitly and
   `friends.firestore.rules.test.mjs` was missing from the list. Added.

9. **`completedAt` had no bound against server time.**
   `dailyCapDate` and `monthlyPeriod` are both derived from the client's
   `completedAt`, so a caller could choose which day's 200 XP cap and which
   month's leaderboard period their run landed in. The user's decision on
   2026-07-30 was to close the future half only, with a six-hour allowance:
   a run cannot finish after now, so future-dating is never legitimate, and
   rejecting it removes "bank XP into next month's board" and "spend a day's
   cap that has not happened yet". The allowance is not clock jitter — it is
   wide enough to absorb a device whose timezone is misconfigured by hours,
   because a rejected run is a run the runner loses (the pending-run store
   retries the same payload and would fail forever). Backdating stays
   accepted: bounding it needs a policy that cannot strand legitimate offline
   re-uploads, and remains open work below. The rule lives once in
   `functions/src/run/completedAtFreshness.ts` and is applied by both
   `parseRunCompletionPayload` and `parseCoolDownCompletionPayload`, since
   `completeCoolDown` derives its own cap date and period from the same field
   and leaving it open would half-close the vector. `startedAt` needs no
   separate bound — it is already required to be strictly before `completedAt`.

## Follow-up round (same day, second review pass)

A second review pass over the uncommitted diff found real defects **introduced
by this capsule's own first round**, plus gaps in fixes it had made. All are
closed here.

- **Regression: the sign-out unregister could disable the NEXT runner's
  device.** Moving the remote call after local teardown widened a window that
  already existed: `unregisterNotificationDevice` sends only the token and the
  server resolves the owner from `request.auth.uid`, so a call that lands after
  the next runner has signed in disables *their* row — and an FCM token is
  per-device, so the two runners share it. The owner is now captured from
  `_currentUid` (what the service is actually registered under) rather than the
  live provider, and the remote call is skipped entirely once a different owner
  is signed in. Leaving the previous owner's row enabled is recoverable; killing
  the new owner's is not.
- **`start()` and `unregisterCurrentDevice()` were not serialised.** A sign-out
  landing inside `start()`'s awaits was undone by the slower call completing
  afterwards and re-arming `_started` plus the previous owner's subscriptions.
  A generation counter, bumped by every teardown, makes the stale `start()`
  bail out.
- **Regression: the seed-cleanup refresh could abort after the deletes had
  committed.** Retargeting the refresh at the live period made it contend with
  the hourly aggregation schedule, which the old past-period target never did.
  A lost lease returned `skipped_locked`, which the code treated as fatal —
  stranding the manifest at `cleanup_pending` for a run whose documents were
  already gone. `skipped_locked` is now a success: the lease holder is
  aggregating the same period.
- **The dispatch window did not tolerate scheduler delay.** A ten-minute window
  assumed Cloud Scheduler fires on an exact grid; a sweep due at 05:40 that ran
  at 05:42 stepped over it and dropped the reminder — the original defect in a
  narrower form. The window is now the sweep interval plus tolerance (15 min),
  still far inside the 50-minute minimum gap between offsets. Widening it also
  made the midnight window overlap an offset window, which the third round
  below had to fix.
- **The dedup that made the wider window safe did not actually hold.** The
  first round's comment claimed duplicate sends were impossible. Only `"sent"`
  suppressed a resend, so an attempt whose FCM response was lost sat at
  `"pending"` and was sent again — and a window wider than the sweep interval
  means consecutive sweeps really do reconsider the same reminder. A pending row
  now suppresses a resend inside an attempt lease, and is retried after it so a
  crash between the write and the send still recovers. (The lease length chosen
  here was wrong — 30 minutes outlived the due window and made recovery
  unreachable. Corrected in the third round below.)
- **The six-hour future allowance let the client pick the accounting period.**
  Accepting a future `completedAt` is the right call for a misconfigured device
  clock, but it must not also choose which day's cap and which month's board the
  run lands in — a run near midnight or a month boundary could bank XP forward.
  `progressionInstantFor` clamps the instant used for `dailyCapDate` and
  `monthlyPeriod` to server time in both callables. The activity's own
  `completedAt` is untouched, and a past instant passes through unchanged.
- **The coordinate redaction missed the labelled form.** `latitude=1.3521`
  survived, and a lone labelled value carries a position just as much as a pair.
  Added, and the over-redaction bias of the pair heuristic is now stated
  explicitly rather than implied.
- **The APK URL check was bypassable with control characters.**
  `"/\t/evil.test/a.apk"` passed the prefix checks and normalises to a
  protocol-relative URL. Control characters are rejected outright and the
  relative case is now decided by resolving against a throwaway origin.
- **`firebase.json` had no `functions.ignore` or `predeploy`** — outside this
  capsule's original path scope, included because `functions/.secret.local`
  (which holds `OPENAI_API_KEY`) exists on disk and, with no `ignore` list, was
  uploaded in every function deploy bundle. It is now excluded along with
  `.env*`. `predeploy` was added in the same edit because the entrypoint is the
  git-ignored generated `lib/src/index.js` with nothing forcing a rebuild, so a
  stale local `lib/` could ship.

  Scope of that exposure, verified rather than assumed: the file is untracked
  and has never appeared in git history (`git log --all` on the path is empty;
  `.gitignore:17` matches it), and the three agent callables consume the key
  through `defineSecret("OPENAI_API_KEY")`, so the deployed functions read
  Secret Manager and never the bundled file — `.secret.local` is the local
  emulator override Firebase designed it to be. The bundled copy was therefore
  redundant, not a new disclosure: reading a deploy bundle already requires
  project access that can read Secret Manager directly. **The key does not need
  rotating**, and the local file must stay in place or the emulator loses its
  secret. An earlier draft of this record said the opposite; it was written
  before the `defineSecret` usage and the git history were checked.
- **Capsule accuracy:** this document claimed the website half was "committed
  and deployed separately". It is uncommitted in that repository. Corrected.

## Third round (PR #47 Codex review)

The PR review raised three P2s, all against the follow-up round's own fixes.
All three were verified real and are closed.

- **The pending-delivery lease outlived the planning window, so recovery was
  unreachable.** A 30-minute lease against a 15-minute due window meant that by
  the time the lease expired the planner had stopped emitting the dispatch — an
  attempt lost to a crash was stranded permanently, not retried. Worse, the test
  that claimed to cover recovery used an hour-old pending row, which is not a
  path any sweep can reach, so it asserted a guarantee that did not exist. The
  lease is now five minutes (under the ten-minute sweep interval) and the test
  drives the real recovery: a crash at 21:00Z is retried by the in-window 21:10Z
  sweep. The residual limit — an attempt dying late in the window has no
  in-window sweep left — is documented at the constant rather than papered over.
- **The widened midnight window masked overlapping offset windows.**
  `planWorkoutDispatches` chained the kinds with `??` and returned only the
  first, so for a 02:05 start the 00:10 sweep emitted `today_plan_midnight`
  alone and the -120 window had closed by 00:20 — that reminder was never sent.
  Widening the midnight window to a full sweep interval is what made the overlap
  reachable. All independently due kinds are now emitted; they carry different
  delivery keys, so this is deduplicated per reminder rather than doubled.
- **Regression: treating a contended refresh lease as success could report
  `cleaned` with mock rows still live.** When the seed covers the live period,
  the hourly aggregation holding the lease may already have read the synthetic
  contributions before the deletes committed, and can republish exactly the rows
  the cleanup removed — it does not reconcile the deletion, which is what the
  follow-up round's comment assumed. `skipped_locked` is fatal again. The
  premise behind that change was also wrong: throwing after the deletes commit
  is not a stranded state, because `cleanup_pending` is an explicitly resumable
  status (`cleanupIssues` and `hasSafeCleanupCandidateIds` both accept it) and
  the deletes are id-scoped and idempotent, so re-running finishes the refresh.

## Path scope

- `functions/src/notifications/dispatchPlanner.ts`
- `functions/src/leaderboard/leaderboardSeedMutation.ts`
- `functions/src/errors/sanitize.ts`
- `functions/src/agent/activityFeedbackQuota.ts`
- `functions/src/run/completedAtFreshness.ts` (new)
- `functions/src/run/validateRunPayload.ts`
- `functions/src/run/validateCoolDownPayload.ts`
- `functions/package.json` (one line: the new test file joins `npm test`)
- `functions/src/notifications/scheduledPushMessagingAdapter.ts`
- `functions/src/run/completeRun.ts`
- `functions/src/run/completeCoolDown.ts`
- `functions/test/notificationScheduledDispatch.test.ts`
- `firebase.json` (secret exclusion + predeploy; see the follow-up round above)
- `functions/test/completedAtFreshness.test.ts` (new)
- `functions/test/notificationDispatch.test.ts`
- `functions/test/reportAppError.test.ts`
- `functions/test/activityFeedbackAgentCallableSurface.test.ts`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/notification_registration_service.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/plan_notification_delivery_materializer.dart`
- `implementation/mobile/runiac_app/test/notification_registration_service_test.dart`
- `implementation/mobile/runiac_app/test/plan_notification_delivery_materializer_test.dart`
- `implementation/mobile/runiac_app/test/support/fake_notification_services.dart`
- `tests/firebase-rules/package.json`
- this capsule document, its `CURRENT.md` routing line, and the governance-CI
  predicates registering them

The `website/` half lives in a separate git-ignored repository and never appears
in this repository's diff. It is currently **uncommitted** there and needs its
own review, commit, and deploy — nothing about it has shipped.

## Reported and deliberately NOT changed here

Refuted on inspection — the code does not do what the review claimed:

- **Challenge leavers keep reading participant records.** False.
  `challengeLobbyCore.ts:657` removes the uid from `rosterUids` on withdraw,
  which is exactly what `isSnapshottedChallengeMember` reads.
- **GPS keeps tracking when the run screen is left mid-completion.** False.
  `dispose()` calls `stopForegroundTicker()`, and when the screen owns the
  coordinator `controller.dispose()` stops the location provider, the motion
  provider, and the foreground service. The "ticker" is a UI clock, not GPS.

Restates a decision already recorded in `CURRENT.md`, so changing it would
reverse that decision rather than fix a defect:

- **`premiumEarnsXp: false` / `excludePremium: true` should be rejected by the
  validator.** The `premium-parity-progression` routing records that both
  suppression and exclusion remain supported configurations and that only the
  defaults changed.
- **The admin website should not write progression state directly.** The
  `admin-config-control-plane` capsule records that the Admin-SDK console
  cannot call callables, so audited Admin-SDK Firestore writes are the intended
  mechanism. The write race is real but is a known trade-off, not an oversight.

Raised by the second review pass, verified real, but outside this capsule's
scope — each belongs to the subsystem that owns it, not to a review-triage
capsule, and none is a regression this work introduced:

- **`main.dart` uses the App Check debug provider in release builds whenever a
  debug token is supplied**, and the published APK is built with exactly that
  define. The token is extractable from the public APK and is registered
  project-wide, so App Check is currently not an effective control on any
  endpoint — including the eight that do enforce it. This was reported to the
  user separately; the correct fix is a distribution decision (Play-signed
  testing track vs. accepting that App Check is not active), not a code edit
  here.
- **Firebase initialisation failure leaves a blank screen** — no error reporter
  exists yet at that point and no widget is mounted, so the runner has no
  recovery path.
- **iOS `RuniacLiveActivityManager` keeps the current activity in memory only**,
  so a stop/update after a process restart cannot find it and may duplicate.
- **iOS `RuniacPlanNotificationChannel` returns success before
  `UNUserNotificationCenter.add` completes** and never records single-shot
  notification ids, so those cannot be cancelled.
- **iOS treats `.whileInUse` as sufficient** while the provider enables
  background updates; locked-screen tracking needs Always authorisation.
- **Android** does not persist single-shot notification ids for cancellation,
  the Activity and the BroadcastReceiver hold separate scheduler instances so
  the live-delivery callback never reaches Dart, and there is no
  `BOOT_COMPLETED` receiver, so AlarmManager alarms are lost on reboot.
- **`friends_realtime_emulator_test.dart`** uses fixed nicknames and does not
  clean up, so a re-run against the same emulator can fail.
- **`.gitignore`** does not cover `*.db`/`*.sqlite` or `firebase-export-*`
  directories.

Confirmed but needing a product or deployment decision, so left open:

- **Backdating `completedAt` can still walk around the daily XP cap.** The
  future half is closed above; the past half is not. A caller can still name
  a past day and spend that day's untouched 200 XP cap. A naive freshness
  bound would permanently fail legitimate offline re-uploads from
  `local_pending_run_activity_store`, so the recommended shape is to keep
  accepting the activity but **clamp** `dailyCapDate`/`monthlyPeriod` to
  server receipt time once the run is older than a generous window — the
  runner never loses a run, and the cap cannot be re-spent. That changes XP
  accounting and is deliberately deferred to its own capsule.
- **App Check is not enforced on the run/challenge/friends/feed callables.**
  Real, but enabling it changes deployed behaviour and a debug build without a
  registered App Check debug token fails every enforced callable.
- **`isPremiumUser()` in `firestore.rules` ignores `subscriptionExpiresAt`,**
  so an expired subscriber keeps expert-plan access until the daily
  `expireSubscriptions` sweep. The functions layer already treats a past
  expiry as not-premium (`progressionAuditHelpers.ts:81`), so the rules lag the
  server contract by up to a day. Needs a rules deploy.
- **`completeRun` reads the owner's entire activity history on every call,**
  and the challenge expiry sweep uses an unordered `limit(50)` over
  `RECRUITING` lobbies (the code comments acknowledge the missing composite
  index), so expired lobbies can be starved behind 50 active ones. Both are
  scalability debt, harmless at current volume.

## Forbidden under this routing

Any production `runiac-fypp` deploy without separate authorization; any
`firestore.rules`, `storage.rules`, or index change; any new Cloud Function,
collection, dependency, or secret; any XP/level/rank/streak/leaderboard formula
change; any client-side computation or writing of a backend-owned value;
repo-wide `dart format`; and any edit or staging inside the isolated
`adaptive-character-guidance` worktree. This append-only routing does not
supersede other active capsules.

## Evidence (2026-07-30)

- Functions `npm run build` and `tsc --noEmit` clean.
- Functions `npm test` (main + feed + moderation + challenge + friends) —
  **1019/1019**, 0 fail: main 708, feed 75, moderation 25, challenge 177,
  friends 34. Baseline before this capsule was 1006; the +13 are the new
  `completedAtFreshness.test.ts` (8), the two pending-resend cases in
  `notificationScheduledDispatch.test.ts`, and three new planner cases.
- Flake observed and dismissed: one full-suite run failed
  `reportAutomation.test.ts` ("report automation handler"). It passed on a
  standalone `npm run test:moderation` run and on a clean re-run of the full
  suite. Nothing in this capsule touches reports or moderation. That file has a
  recorded history of emulator re-delivery nondeterminism
  (`test-suite-regression-hardening`), so this is the same class, not a
  regression — but it is not fully closed.
- Emulator, focused re-run after the follow-up round:
  `notificationScheduledDispatch`, `seedLeaderboardCleanup`, `completeRun`,
  `completeCoolDown` — **118/118**.
- Emulator (`runiac-functions-test`): `seedLeaderboardCleanup`,
  `seedLeaderboardMockData`, `seedLeaderboardSafety`,
  `notificationScheduledDispatch`, `monthlyLeaderboardWriter` — **30/30**.
- Emulator: `activityFeedbackAgentCallableSurface`,
  `activityFeedbackContracts`, `activityFeedbackModel` — **21/21**.
- The one failing `reportAppError` subtest seen when running that file without
  an emulator ("firebaseReportAppErrorPort rate limit ledger (real Firestore)")
  needs the emulator and **fails identically on unmodified `main`** — verified
  by stashing. It passes inside `npm test`.
- Firestore rules suite — **141/141** (was 117 before the friends suite was
  wired in).
- Flutter `analyze --no-pub` clean; `flutter test --no-pub` — **2548/2548**
  (the +2 are the two new owner-race cases in
  `notification_registration_service_test.dart`).
- `website/` vitest `site-download` — **7/7**.
- Governance CI `run-all-checks.sh` — all checks PASS.
