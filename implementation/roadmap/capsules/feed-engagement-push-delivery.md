# Capsule: Feed Engagement Push Delivery (Android)

Status: implemented and locally validated. Not committed, not deployed.
Routed: 2026-07-31 Asia/Singapore (explicit user request).
Lane: Backend Guarded Lane (ADR-002 emulator-first, ADR-003). Adds an FCM send
to an existing trigger's emitter; no new Cloud Function export, no new
collection, no new index, no dependency.

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Goal

Make a feed like or comment actually ring the recipient's phone.
`feed-engagement-notifications` deliberately shipped inbox-only, so today a like
writes `notificationInbox/{ownerUid}/items/{deliveryKey}` and nothing else — the
runner only learns about it by opening the app. This capsule adds an FCM push
for the same event, on Android only.

**This capsule supersedes the "Any FCM push send" line in the Forbidden Scope of
`feed-engagement-notifications.md`, for feed engagement events only.** Nothing
here authorizes iOS push or native push wiring.

## Why Android only

Verified against the repository and the live project on 2026-07-30/31:

| | Android | iOS |
|---|---|---|
| Firebase config | `android/app/google-services.json` present | `ios/Runner/GoogleService-Info.plist` **absent** |
| Permission / entitlement | `POST_NOTIFICATIONS` in the manifest | `aps-environment` **absent** (`Runner.entitlements` carries only HealthKit) |
| Background mode | n/a | `remote-notification` **absent** (`UIBackgroundModes` is `location` only) |
| Client gate | none — `registerCurrentDevice()` proceeds | blocked by `applePushRegistrationEnabled == false` |
| External dependency | none | Apple Developer Program + APNs `.p8` upload |

`notificationDevices/{uid}/tokens/*` already holds **four enabled Android
tokens** in production, registered between 2026-07-24 and 2026-07-30, including
the author who received the first real feed-engagement notification. So device
registration already works end to end and the only missing piece is the send.

iOS remains out of scope and would need its own Tier 1 capsule.

## Allowed Scope

- Send an FCM message to the recipient's enabled devices immediately after the
  inbox item is created, inside the existing `emitFeedLikeNotification` /
  `emitFeedCommentNotification` emitters.
- **Send only when the inbox writer returns `"written"`.** The writer's
  transactional create on the deterministic delivery key is already the
  exactly-once guard; a `"duplicate"` means this event was already delivered, so
  reusing that result keeps push dedup identical to inbox dedup and needs no new
  `notificationDeliveries` ledger.
- Reuse, do not reimplement: `enabledDevices()` in
  `functions/src/notifications/scheduledPushReaders.ts` for token lookup, and
  the invalid-token handling already proven in
  `functions/src/notifications/scheduledPushMessagingAdapter.ts` — on
  `messaging/invalid-registration-token` or
  `registration-token-not-registered`, set `enabled: false` on that token
  document rather than letting the error escape.
- Send to every enabled token for the recipient (a runner may have more than
  one device). Platform is not filtered: an iOS token cannot currently be
  registered at all, and when iOS is enabled later this path should already work.
- `data` payload stays the existing allowlist — `kind`, `route`, `postId` — so
  the tap-through resolves exactly as the inbox row does.

## Forbidden Scope

- Any iOS push work: `aps-environment`, `remote-notification`,
  `GoogleService-Info.plist`, `RUNIAC_ENABLE_IOS_PUSH`, APNs keys, or a
  `FirebaseMessaging.onBackgroundMessage` handler.
- Any change to the inbox write, the delivery key, the payload allowlist, or the
  suppression rules. Push rides the existing decision; it does not get its own.
- Letting a send failure affect the trigger. The emitters are already wrapped so
  they cannot throw, and the count recompute has already committed by then —
  that must stay true.
- Any new exported Cloud Function, collection, `firestore.rules` change,
  dependency, or secret.
- Any `firestore.indexes.json` change **except** the single
  `tokens.tokenFingerprint` `COLLECTION_GROUP` field override this capsule's
  review follow-up added — see below for why that exception is load-bearing
  rather than convenient.
- Any `notificationDeliveries` ledger row for this path (the inbox create is the
  guard; a second ledger would double the write cost for no added guarantee).
- Any production deploy, commit, push, or PR without separate explicit user
  authorization (ADR-001 Tier 1).
- Repo-wide `dart format`; edits inside the isolated
  `adaptive-character-guidance` worktree.

## Exact Target Files

- `functions/src/feed/engagement/engagementPush.ts` (new — device lookup, send,
  invalid-token disable)
- `functions/src/feed/engagement/engagementNotifications.ts` (call the sender
  after a `"written"` persist)
- `functions/test/feedEngagementPush.test.ts` (new)
- `functions/test/feedEngagementNotifications.test.ts` (assert the send is not
  attempted on `"duplicate"` and that a send failure cannot escape)
- `functions/src/notifications/deviceRegistry.ts` (added by Codex review: on
  register, release the same FCM token from any other uid before claiming it)
- `functions/test/notificationDevices.test.ts` (ownership-transfer coverage)
- `functions/package.json` (the new suite joins `test:feed`)
- this capsule document, its `CURRENT.md` routing line, and the governance-CI
  predicates registering the new files

## Required Tests

- A `"written"` persist sends to every enabled token for the recipient; a
  `"duplicate"` persist sends nothing.
- A recipient with no enabled tokens is a clean no-op.
- An invalid-token error disables exactly that token document and does not
  abort the remaining sends.
- Any other send error is swallowed — the emitter still resolves, so the
  trigger and its already-committed count recompute are unaffected.
- The `data` map carries exactly `kind`, `route`, `postId`, and the
  notification title/body match the inbox item's.
- Suppression still short-circuits before any device read (self-engagement,
  `socialActivityEnabled: false`, unpublished parent).

## Required Validation

- `cd functions && npm run build && npm run test:feed`
- `./tools/governance-ci/run-all-checks.sh` from the canonical Desktop root
- `git diff --check`
- A11_FIREBASE_IMPL primary, then A6_REVIEW, A12_QA_TEST, A8_OUTPUT_CHECKER.

## Required Evidence

- Functions build and `test:feed` output with the new suite's case count.
- Governance CI PASS.
- Post-deploy: a real like from a second account producing both the inbox item
  and an observed banner on an Android device, with the Cloud Run log for the
  trigger showing no `emit failed` line.

## Codex review follow-up (2026-07-31, PR #51)

Three findings, all verified real against the code.

**P1 — a stale token row leaked identity to another account's device.**
`unregisterCurrentDevice()` deliberately leaves the previous owner's token row
enabled, and its own comment argues that is recoverable because "the local
teardown above already stops their pushes reaching this inbox". That reasoning
held only while every push was anonymous: local teardown stops the *app* writing
to the wrong inbox, but the server row stays enabled, so FCM still delivers to
the device and the OS still draws the banner. Plan reminders say "Comfortable
Run starts in 10 min" and leak nothing; this capsule's banner says
"Runnest liked your run". So this change converted an accepted trade-off into a
real disclosure of a previous user's social activity on a lock screen now used
by someone else. Fixed at registration rather than at send time: when a device
registers a token, any row holding the same `tokenFingerprint` under a different
uid is disabled first, so ownership transfers with the device. Registration runs
on every sign-in, so this also repairs already-shipped clients without an app
update.

**P2 — a failed disable write could drop the other devices' pushes.** The
invalid-token disable write was awaited inside the per-device catch but had no
guard of its own, so a transient Firestore failure rejected that device's
promise, rejected the surrounding `Promise.all`, and returned from the outer
function while the remaining sends were still in flight — which Cloud Functions
may then freeze. Now the disable write has its own catch and the fan-out uses
settled semantics, so per-device isolation is real rather than intended.

**P2 — duplicate inbox rows, NOT fixed here.** `_saveReceivedPushNotification`
in `lib/app.dart` writes an inbox document keyed by the FCM `messageId` whenever
a push arrives, so a server-persisted notification lands twice and can
re-increment the badge after a tap. The payload cannot carry the fix: the client
keys off `message.id`, which is FCM-assigned, so no backend value can make the
two ids agree. This needs a client change (ignore server-persisted messages, or
key off a supplied `deliveryKey`) and therefore a mobile release. It is recorded
in Rollback Conditions and must be resolved before or with the push deploy, or
every runner sees each like twice.

## Index exception (added 2026-07-31, overriding this capsule's own Forbidden Scope)

The P1 fix runs
`collectionGroup("tokens").where("tokenFingerprint", "==", fingerprint)`. That
needs no *composite* index, and it passes in the emulator — but Firestore's
automatic single-field indexes default to `COLLECTION` query scope, so a
collection-group query needs `COLLECTION_GROUP` scope enabled explicitly, and
**the emulator does not enforce that while production does**. This repository
already carries exactly that precedent: `firestore.indexes.json` has
`fieldOverrides` enabling `COLLECTION_GROUP` for `friends.uid`,
`friendRequests.uid`, and `blockedUsers.uid`, because
`friendsNicknameFanout.ts` runs the identical query shape.

Without the override the query would fail in production, the best-effort catch
around it would swallow the failure, the stale token row would never be
released, and **the privacy leak this fix exists to close would stay open — with
every test green**. So the override is not a convenience; omitting it would make
the P1 fix a no-op exactly where it matters. One `fieldOverrides` entry for
`tokens.tokenFingerprint` was added, mirroring the three existing ones, and it
must be deployed with the functions.

`enabledDevices()` was reused as intended, but the invalid-token error-code
check and the `enabled: false` disable write ended up **duplicated** as small
private helpers in `engagementPush.ts` rather than shared with
`scheduledPushMessagingAdapter.ts`. That was the right call under this capsule —
the adapter is not in Exact Target Files, so extracting a shared helper would
have meant editing a file this routing does not cover — but it leaves two copies
of the same FCM contract. If Firebase ever changes
`messaging/invalid-registration-token` or
`messaging/registration-token-not-registered`, both copies must move together.
Extracting the shared helper is a clean follow-up whenever a capsule
legitimately owns both files.

## Rollback Conditions

- A send failure is observed affecting `likeCount`/`commentCount` or the
  trigger's success.
- Duplicate banners for one event, or a banner for a suppressed event.
- Token documents being disabled for errors that are not invalid-token.

## Evidence recorded (2026-07-31)

- `functions`: `npm run build` clean; `npm run test:feed` **133 tests / 133 pass
  / 0 fail** across 20 suites (116 before this capsule). New/changed suites:
  `sendFeedEngagementPush (emulator)` 6/6, `emitFeedLikeNotification (emulator)`
  11/11, `emitFeedCommentNotification (emulator)` 8/8.
- `./tools/governance-ci/run-all-checks.sh`: all 12 checks PASS, with the two
  new `functions/**` paths admitted only while this capsule's routing line is
  present in `CURRENT.md`.
- `git diff --check` clean.

Not done and not claimed: no production deploy, and **no real-device banner has
been observed**. The end-to-end proof required by Required Evidence — a second
account's like producing both the inbox item and a visible Android banner — can
only happen after deploy and remains outstanding.

## Exit Criteria

- [x] Target files completed.
- [x] Required tests or validation completed.
- [x] Required evidence recorded (automated; real-device banner outstanding).
- [ ] Snapshot updated if state changed.
- [ ] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
