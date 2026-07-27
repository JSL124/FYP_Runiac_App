# Notification Inbox Delivery Semantics

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Goal

Make the in-app notification inbox record notifications at the moment they actually fire, not at the moment they are scheduled, so the Home bell badge means "notifications you missed and have not checked yet" instead of being permanently pinned at `99+`.

## Problem

QA reported the Home bell badge is always `99+` and cannot be cleared. Three defects compound:

1. `PlanNotificationSyncService.syncGeneratedPlan` writes every scheduled local plan notification into the inbox at sync time, stamping `createdAt` with the future `scheduledAt`. Because `FixedTimePlanNotificationPolicy` only emits notifications whose `scheduledAt.isAfter(now)`, every plan item written into the inbox is by construction one that has not fired.
2. Nothing ever removes inbox items. Each sync writes the nearest 48 notifications; as the plan advances the window slides and new deterministic ids accumulate while old documents remain forever.
3. `CloudFirestoreNotificationInboxDocumentStore.saveInboxItem` merges but writes `FieldValue.delete()` for `readAt`/`deletedAt` when they are null, so any item still inside the scheduling window is un-read and un-deleted on the next sync. The user has no way to clear the badge.

The server-side paths already follow the correct contract — `scheduledPushMessagingAdapter.ts` and `challengeNotifications.ts` write the inbox inside the send transaction, and `app.dart` writes received FCM messages with `createdAt: DateTime.now()`. Only the local plan-notification path is inverted.

## Allowed Scope

- Add a local, uid-scoped ledger of notifications actually handed to the OS (`shared_preferences`), replacing the schedule-time inbox write.
- Add native delivery reporting on both platforms: Android records the delivery inside `showNotification`; iOS records it from the existing `willPresent`/`didReceive` delegates and merges `UNUserNotificationCenter.getDeliveredNotifications()`.
- Add a `consumeDeliveredNotifications` pull method plus an `onPlanNotificationDelivered` push callback on the existing `runiac/plan_notifications` method channel.
- Add `PlanNotificationDeliveryMaterializer`, which writes inbox items from drained native delivery events (`createdAt` = real delivery time) and from a time-based backstop for ledger entries whose `scheduledAt` has passed (`createdAt` = `scheduledAt`).
- Stop `readAt`/`deletedAt` from being cleared on merge save, by omitting the keys when null.
- Expose the existing `clientManaged` field on the inbox document and read model.
- Add a one-time, uid-flagged cleanup that soft-deletes every `clientManaged` inbox item, clearing the accumulated backlog.
- Wire cleanup and materialization into `RuniacShell` (start, resume, native callback, uid change) and inject the new dependencies in `runiac_firebase_bootstrap.dart`.
- Clamp negative durations in the inbox relative-time formatter.

## Forbidden Scope

- Any Cloud Functions change and any `runiac-fypp` deploy. This capsule is client and native only.
- Any `firestore.rules`, `firestore.indexes.json`, or `storage.rules` change. The existing `notificationInbox` rules already permit omitted `readAt`/`deletedAt` keys, so no rules change is required.
- Any change to notification policy — count, copy, or timing. `FixedTimePlanNotificationPolicy` keeps emitting six notifications per runnable workout.
- Any UI surface exposing the list of scheduled-but-unfired notifications.
- Any change to the server-delivered notification path, challenge notification routing, or `NotificationRegistrationService`.
- Client-side computation or writing of any backend-owned value.
- New dependencies or secrets.

## Exact Target Files

New:

- `implementation/mobile/runiac_app/lib/features/notifications/domain/repositories/plan_notification_ledger.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/data/shared_preferences_plan_notification_ledger.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/plan_notification_delivery_materializer.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/notification_inbox_legacy_cleanup.dart`

Modified:

- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/plan_notification_sync_service.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/repositories/plan_notification_scheduler.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/data/method_channel_plan_notification_scheduler.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/data/cloud_firestore_notification_inbox_document_store.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/data/firestore_notification_inbox_repository.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/models/notification_inbox_item.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/presentation/notification_inbox_page.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/ios/Runner/AppDelegate.swift`
- `implementation/mobile/runiac_app/ios/Runner/RuniacPlanNotificationChannel.swift`
- `implementation/mobile/runiac_app/android/app/src/main/kotlin/com/runiac/runiac_app/RuniacPlanNotificationScheduler.kt`
- `implementation/mobile/runiac_app/android/app/src/main/kotlin/com/runiac/runiac_app/MainActivity.kt`

## Required Tests

- `test/plan_notification_sync_service_test.dart` — inverted: sync writes the ledger and must not write the inbox.
- `test/plan_notification_ledger_test.dart` — the merge rule preserves fired-but-unmaterialized entries and drops cancelled future entries.
- `test/plan_notification_delivery_materializer_test.dart` — native event path, time-backstop path, cancelled entries never materialize, idempotent re-run, signed-out no-op.
- `test/notification_inbox_document_payload_test.dart` — `readAt`/`deletedAt` keys absent when null.
- `test/notification_inbox_legacy_cleanup_test.dart` — clears only `clientManaged` items, runs once per uid.
- `test/method_channel_plan_notification_scheduler_test.dart` — the new channel method.
- Existing `test/notification_inbox_page_test.dart` and `test/home_notification_inbox_test.dart` regressions.

## Required Validation

- `flutter analyze` clean.
- Targeted notification test files pass, then the full `flutter test --no-pub` suite with only the known baseline failures recorded in the active capsule.
- `dart format` scoped to changed files only.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- A6_REVIEW for the data-model and access-boundary surface; A12_QA_TEST for the delivery paths.

## Required Evidence

- Test and analyze output for the targeted and full runs.
- Simulator QA using the existing `RUNIAC_LOCAL_NOTIFICATION_SMOKE_TEST` affordance showing: badge falls to 0 on first launch, an unfired scheduled notification does not appear, a fired notification appears exactly once with a correct relative time, reading it clears the badge, and neither a read nor a swiped-away item returns after a restart or a later sync.
- Governance CI output.

## Rollback Conditions

- A delivered notification fails to appear in the inbox on either platform.
- The one-time cleanup removes server-delivered items, or runs more than once per uid.
- Materialization writes duplicates or resets read state.
- Governance CI or `flutter analyze` cannot be brought back to clean.

## Exit Criteria

- [ ] Target files completed.
- [ ] Required tests or validation completed.
- [ ] Required evidence recorded.
- [ ] Snapshot updated if state changed.
- [ ] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
