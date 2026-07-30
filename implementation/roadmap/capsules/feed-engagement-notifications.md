# Capsule: Feed Engagement Notifications (like / comment)

Status: merged to `main` as `0217df1a` (PR #49) and DEPLOYED to `runiac-fypp` on
2026-07-30 — `firestore.rules` released and `feedLikeCreated` /
`feedCommentCreated` updated. The backend half is live; the mobile release that
makes the tap-through and the Social activity toggle reachable has NOT shipped,
and simulator QA has still never been performed.
Routed: 2026-07-30 Asia/Singapore (explicit user request).
Lane: Backend Guarded Lane (ADR-002 emulator-first, ADR-003). Extends two
existing Firestore triggers and adds one new backend module; no new Cloud
Function export, no new collection, no new index, no dependency.

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Goal

Tell a runner when a mutual friend likes or comments on their shared run.
`feedPosts/{postId}/likes/{uid}` and `feedPosts/{postId}/comments/{commentId}`
are client writes whose only server reaction today is the count recompute in
`functions/src/feed/engagement/engagement.ts`, so engagement is invisible unless
the owner reopens the Feed tab. This capsule turns each first like and each
first comment from a given actor into one in-app inbox notification, delivered
by the server, surfaced by the existing Home bell badge, and tappable through to
the post's comment sheet.

## Design decisions (user-confirmed 2026-07-30)

- **In-app inbox only.** Writes to `notificationInbox/{ownerUid}/items/{deliveryKey}`,
  the same collection and envelope the Challenge notifications already use. No
  FCM push: iOS push is non-functional end to end (no `aps-environment`
  entitlement, no `remote-notification` background mode, no
  `GoogleService-Info.plist`, and `NotificationRegistrationService`'s Apple
  registration is off behind `RUNIAC_ENABLE_IOS_PUSH`). Attaching push is a
  separate, Tier 1 capsule.
- **The actor is named** in both kinds ("Minsu liked your run"). The feed is
  mutual-friends-only, so the actor is always someone the recipient already
  knows. This is a deliberate departure from the identity-free style of
  `challengeNotifications.ts`, and it is one-way: the title is baked at write
  time, so a later unfriend or block cannot scrub the name from the inbox.
- **The comment body is echoed**, truncated to 80 code points. The post owner can
  already read the comment, so this discloses nothing new.
- **One item per `(postId, kind, actorUid)`, forever.** The delivery key is
  deterministic and the writer creates without overwriting, so unlike-then-relike
  never re-notifies and a recipient's `readAt` is never resurrected. Trade-off:
  a second comment from the same actor neither notifies again nor updates the
  frozen body. Folding `commentId` into the key is the one-line change if
  per-comment notifications are ever wanted.
- **Post owner only.** Self-engagement is suppressed. Other commenters on the
  same post are not notified — that would require reading the whole comments
  subcollection per event and would cross-expose commenter identities between
  users who may not be mutual friends.
- **Tap-through opens the Feed tab and the post's comment sheet**, with a
  fallback when the post is no longer in the loaded timeline.
- **A "Social activity" toggle** joins the Notification Center and genuinely
  gates delivery, which means the server has to be able to read it.

## Allowed Scope

- New backend module `functions/src/feed/engagement/engagementNotifications.ts`:
  pure planner, copy builders, a payload key allowlist, a deterministic delivery
  key, a transactional create-once inbox writer, and two emitters each wrapped so
  they can never throw. Structural clone of
  `functions/src/challenge/challengeNotifications.ts`.
- Additive `FeedEngagementNotificationKind` union in
  `functions/src/notifications/types.ts`, kept separate from
  `NotificationDispatchKind` and `ChallengeNotificationKind` for the same reason
  the challenge union is separate: these are server-event-driven inbox writes,
  not scheduled-push dispatches, and must not enter the dispatch planner's kind
  space.
- Hook the two emitters into the existing `feedLikeCreated` and
  `feedCommentCreated` triggers, after the count recompute has committed and
  gated on its `updated` result so the existing `status == 'published'` check is
  reused at zero extra reads.
- A sibling `socialActivityEnabled` reader in
  `functions/src/notifications/scheduledPushReaders.ts`, defaulting to `true`
  when absent so existing users are opted in before their first mirror write.
- One `firestore.rules` change: `socialActivityEnabled` joins the
  `notificationPreferences/{uid}` create and update key allowlists.
- Flutter: a `socialActivity` preference in the Notification Center, a
  best-effort mirror of one derived boolean to `notificationPreferences/{uid}`,
  a pure notification-routing mapper, a pending-comment-intent controller, and
  the controller/widget/shell wiring that opens the comment sheet.
- One visible screen-level improvement is inherent to the capsule (the SOCIAL
  group in the Notification Center and the tap-through), so the Safe Visible
  Product Acceleration Rule needs no separate allowance.

## Forbidden Scope

- Any production `runiac-fypp` deploy, commit, push, or PR without separate
  explicit user authorization. Deploy is Tier 1 under ADR-001.
- Any FCM push send, `firebase_messaging` change, APNs entitlement, background
  message handler, `GoogleService-Info.plist`, or other native push wiring.
- Any new exported Cloud Function. `functions/test/feedEngagement.test.ts`
  asserts exactly five feed engagement triggers with five document patterns, and
  `functions/test/feedCallableSurface.test.ts` guards the production entrypoint
  export list; neither may gain an entry under this capsule.
- Any emitter on `feedCommentUpdated`, `feedLikeDeleted`, or
  `feedCommentDeleted`. An edit is not new engagement and a withdrawn like does
  not retract a delivered notification.
- Any widening of the existing `notificationPreferences()` reader's return shape
  (`dispatchPlanner.ts` and `notificationDispatch.test.ts` construct it
  literally).
- Any `firestore.indexes.json`, `storage.rules`, or `notificationInbox` rule
  change. The inbox stream is already unindexed-friendly, and the client
  `create` requirement of `clientManaged == true` must stay so a client cannot
  forge an engagement notification.
- Any change to XP, level, rank, streak, leaderboard score, weekly/monthly XP,
  subscription privilege state, or expert plan publication state, and any
  client-side computation or writing of a backend-owned value.
- Any new dependency, secret, `pubspec.yaml` change, `firebase init`, or
  `flutterfire configure`.
- Migrating the other four Notification Center toggles to Firestore.
- Repo-wide `dart format`. The local formatter is newer than the repo's and
  rewrites any file it touches.
- Edits inside the isolated `adaptive-character-guidance` worktree.

## Exact Target Files

Backend:

- `functions/src/feed/engagement/engagementNotifications.ts` (new)
- `functions/test/feedEngagementNotifications.test.ts` (new)
- `functions/src/feed/engagement/engagement.ts`
- `functions/src/notifications/types.ts`
- `functions/src/notifications/scheduledPushReaders.ts`
- `functions/test/feedEngagement.test.ts`
- `functions/package.json` (one line: the new suite joins `test:feed`)

Rules:

- `firestore.rules`
- `tests/firebase-rules/support/firestore_rules_test_support.mjs`
- `tests/firebase-rules/firestore.rules.test.mjs`

Flutter (new):

- `implementation/mobile/runiac_app/lib/features/notifications/domain/repositories/notification_preference_mirror.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/data/firestore_notification_preference_mirror.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/notification_preference_mirror_service.dart`
- `implementation/mobile/runiac_app/lib/features/feed/domain/feed_engagement_notification_routing.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/feed_comment_intent_controller.dart`

Flutter (edited):

- `implementation/mobile/runiac_app/lib/features/notifications/domain/models/notification_center_settings.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/data/shared_preferences_notification_center_settings_repository.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/notification_center_screen.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/feed_timeline_screen_controller.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/app.dart` (pass-through fields only)
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/lib/main.dart`

Flutter (added by the Codex review follow-up — direct resolution of a notified
post, replacing the bounded paging ladder):

- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_post_mapper.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_test_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_author_level_resolver.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_timeline_page_loader.dart`
- `implementation/mobile/runiac_app/lib/features/feed/domain/repositories/feed_repository.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_repository.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed_timeline.dart`

Flutter tests:

- `implementation/mobile/runiac_app/test/notification_preference_mirror_service_test.dart` (new)
- `implementation/mobile/runiac_app/test/feed_engagement_notification_routing_test.dart` (new)
- `implementation/mobile/runiac_app/test/feed_comment_notification_tap_through_test.dart` (new)
- `implementation/mobile/runiac_app/test/notification_center_settings_repository_test.dart`
- `implementation/mobile/runiac_app/test/home_notification_inbox_test.dart`
- `implementation/mobile/runiac_app/test/notification_inbox_page_test.dart`

Governance:

- this capsule document, its `CURRENT.md` routing line, the governance-CI
  predicates registering the two new `functions/**` files, and
  `implementation/roadmap/snapshots/latest.md`

## Required Tests

- `functions/test/feedEngagementNotifications.test.ts`: delivery-key format;
  both exact title and body strings; 80-code-point truncation including an emoji
  case; whitespace collapse; empty-body fallback; the `"Someone"` display-name
  fallback; suppression for a self-actor, for `socialActivityEnabled: false`,
  for empty ids, and for a parent post whose `status` is not `published`; one
  emulator-written document at the expected key with `createdAt` an actual
  `Timestamp` and `readAt` null; a second call yielding `duplicate` with one
  document and a preserved `readAt`; a deleted like document yielding nothing;
  an injected throwing writer leaving the emitter resolved; and the `data` and
  envelope key allowlists.
- `functions/test/feedEngagement.test.ts`: the five-trigger assertion stays
  green, and new cases prove `feedCommentUpdated` / `feedLikeDeleted` /
  `feedCommentDeleted` never notify, that `parent_not_published` short-circuits
  before the emitter, and that the count still updates when the notifier throws.
- `tests/firebase-rules/firestore.rules.test.mjs`: owner create and update of
  `socialActivityEnabled`, non-owner denial, unknown-key denial, a merge-set of
  only the three mirrored keys onto an existing preferences document, and the
  server-shaped inbox item being owner-readable and `readAt`-updatable but not
  client-creatable.
- Flutter: preference round-trip and default; mirror-service effective value,
  master-off forcing false, no write when unchanged, no-op on empty uid, and a
  swallowed write failure; routing mapper for both kinds and for
  unknown/missing/non-string input; tap-through opening the sheet for a loaded
  post, the refresh-then-loadMore-then-SnackBar path for an unknown post, and a
  pending intent cleared on owner change; and the inbox handler routing feed
  items to the new callback while challenge items still reach the challenge
  router.

## Required Validation

- `cd functions && npm run build && npm run test:feed`
- `cd tests/firebase-rules && npm test` (Firestore emulator; ADR-002
  emulator-first, project `demo-runiac-feed` with explicit host guards before
  any fixture mutation)
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub && flutter test`
- `./tools/governance-ci/run-all-checks.sh` from the canonical Desktop root
- `git diff --check`, and `git diff --stat` reviewed for formatter churn before
  any staging
- Agent lenses: A11_FIREBASE_IMPL and A13_SECURITY_RULES as primaries, then
  A6_REVIEW, A12_QA_TEST, A8_OUTPUT_CHECKER (ADR-003 Backend Guarded Lane).

## Required Evidence

- Functions build and `test:feed` output, including the new suite's case count.
- Firestore rules suite output.
- `flutter analyze` and `flutter test` counts.
- Governance CI PASS output.
- Emulator end-to-end note: two mutual friends, a published post by A, a like
  and a comment by B, the two resulting inbox documents named by key, the
  dedup re-run, the self-suppression case, and the
  `socialActivityEnabled: false` case.
- Simulator QA note on the iPhone 17 simulator (never the physical iPhone 16
  Pro, where `flutter run` hangs attaching): the SOCIAL toggle, the bell badge
  incrementing, the tap-through landing on the Feed tab with the sheet open, and
  the SnackBar for a post that is gone. No precise route or location data in any
  evidence artifact.

## Rollback Conditions

- The count recompute regresses, or a notification failure is observed
  affecting `likeCount` / `commentCount` or a trigger's success.
- Duplicate or cross-account inbox delivery appears in emulator or simulator
  evidence.
- The mirror write is observed clobbering other `notificationPreferences/{uid}`
  keys, or the scheduled push dispatch regresses.
- Any new exported Cloud Function, index, `storage.rules`, or dependency turns
  out to be required — stop and re-route rather than widening scope.
- Any governance-CI allowlist would have to be weakened to pass.

## Codex review follow-up (2026-07-30, PR #49)

One P2 finding, verified real and fixed. `openCommentsForPostId` resolved a
notified post by searching the loaded timeline, then `refresh()`, then at most
two `loadMore()` calls — about 60 entries. But the feed is ordered by **post
creation time** while an engagement notification arrives for engagement that
happened *now*, so a comment on a run shared months ago produced a false "That
post is no longer in your feed." The bound was a design error in this capsule's
own plan, not an implementation slip.

Paging until exhausted was rejected as the fix: the timeline fans out one query
per friend per page, so a single notification tap could cost hundreds or
thousands of reads. Instead the post is now resolved with **one direct
`feedPosts/{postId}` document read** — O(1), needing no index, and permitted by
`firestore.rules` because a feed-engagement notification is only ever delivered
to the post's own owner, making `canReadFeedAuthor` trivially true. That is
strictly cheaper than the `refresh()` it replaced, so `maxAdditionalPages` and
the paging loop were deleted outright.

Supporting changes kept the mapping honest rather than duplicating it:
`firebase_feed_post_mapper.dart` grew a shared `mapReference()` carrying the
per-viewer like/comment probe, and `feed_author_level_resolver.dart` grew a
shared `overlay()` that the paging loader now also calls. `readPost` propagates
a read failure instead of swallowing it, so the controller can distinguish
"resolved to nothing" (→ `notFound`) from "the read failed, e.g. offline"
(→ `unavailable`); the controller catches and converts.

Regression guard: the tap-through suite now asserts **call counts** — an
already-loaded post triggers zero `readPost`/`refresh`/`loadMore`, and an
absent post triggers exactly one `readPost` and zero `refresh`/`loadMore`. The
one pre-existing case that asserted the old refresh-then-page ladder was
replaced, since it encoded the removed behaviour.

## Out-of-capsule commit carried by this branch

`f995513a feat(feed): confirm like and comment taps with haptics` was committed
onto `feat/feed-engagement-notifications` by a concurrent session and is
therefore inside PR #49, but it is **not** part of this capsule. It routes feed
like/comment taps through the existing `RuniacHaptics` seam and touches
`feed_post_section.dart`, `feed_comment_sheet.dart`, and
`haptics_moments_test.dart` — none of which appear in this capsule's Exact
Target Files.

It was kept rather than rebased out, on the user's explicit decision on
2026-07-30, because removing it would mean force-pushing another session's
in-flight work; the same session had already switched this repository's branch
mid-task once. It is covered by the same green hosted CI run and the same local
`flutter test` pass recorded below. Recorded here so this capsule's routing
history does not silently omit a commit its own branch shipped.

## Evidence recorded (2026-07-30)

Automated, all run from the canonical Desktop root:

- `functions`: `npm run build` clean; `npm run test:feed` **116 tests / 116 pass
  / 0 fail** across all 12 files in the script, including the new
  `feedEngagementNotifications` suite. The only `[feedEngagementNotifications]
  emit failed` log lines are the two intentional injected-failure tests that
  prove terminal independence.
- Firestore rules: `tests/firebase-rules` **147 tests / 147 pass / 0 fail**
  (141 before this capsule; +5 preference-toggle and inbox-split tests, +1 for
  the merge-set-onto-a-never-existing-document path, which is the shape the
  real first mirror write takes and which lands as a rules `create`).
- Flutter: `flutter analyze --no-pub` clean; `flutter test` **2578 / 2578**
  (2556 before this capsule).
- `./tools/governance-ci/run-all-checks.sh`: all 12 checks PASS, with the two
  new `functions/**` paths admitted only while this capsule's routing line is
  present in `CURRENT.md`.
- `git diff --check` clean. 888 insertions / 12 deletions — no formatter churn;
  `dart format` was never invoked.

Not yet done, and deliberately not claimed:

- **Simulator QA has not been performed.** The bell badge, the SOCIAL toggle,
  the tap-through landing on the Feed tab with the sheet open, and the
  SnackBar for a deleted post are covered by widget tests only. Real-screen
  acceptance is user-owned and remains unclaimed.
- **The emulator end-to-end walkthrough** (two mutual friends, a published
  post by A, a like and a comment by B, the two resulting inbox documents
  named by key, the dedup re-run, self-suppression, and the
  `socialActivityEnabled: false` gate) has not been run as a manual scripted
  pass. Every one of those behaviours is covered by an automated test in the
  new suite, but not by a single narrative walkthrough.
- No production `runiac-fypp` deploy. The feature is inert in production until
  the Functions deploy and a mobile release ship, both requiring separate
  explicit authorization.

## Exit Criteria

- [x] Target files completed.
- [x] Required tests or validation completed.
- [x] Required evidence recorded (automated; simulator QA outstanding, above).
- [ ] Snapshot updated if state changed.
- [x] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
