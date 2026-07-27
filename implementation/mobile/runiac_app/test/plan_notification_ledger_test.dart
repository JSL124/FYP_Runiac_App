import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/domain/models/plan_notification_schedule.dart';
import 'package:runiac_app/features/notifications/domain/repositories/plan_notification_ledger.dart';

void main() {
  group('mergePlanNotificationLedger', () {
    test('keeps a due entry the new schedule no longer lists', () {
      // Given: a reminder that fired shortly before the app was opened. The
      // policy only emits future notifications, so the next sync cannot list
      // it — but it may not have been materialized yet.
      final fired = _notification(
        id: 'fired',
        scheduledAt: DateTime(2026, 7, 8, 7, 30),
      );
      final upcoming = _notification(
        id: 'upcoming',
        scheduledAt: DateTime(2026, 7, 9, 7, 30),
      );

      // When
      final merged = mergePlanNotificationLedger(
        [fired],
        [upcoming],
        now: DateTime(2026, 7, 8, 7, 35),
      );

      // Then: dropping it here would lose the delivery for good.
      expect(merged.map((entry) => entry.id), ['fired', 'upcoming']);
    });

    test('drops a future entry the new schedule no longer lists', () {
      // Given: a missed-run nudge for a workout the runner has since completed.
      final cancelled = _notification(
        id: 'cancelled',
        scheduledAt: DateTime(2026, 7, 9, 8, 30),
      );

      // When
      final merged = mergePlanNotificationLedger(
        [cancelled],
        const <ScheduledPlanNotification>[],
        now: DateTime(2026, 7, 8, 7, 35),
      );

      // Then: a cancelled notification must never become an inbox row.
      expect(merged, isEmpty);
    });

    test('lets the new schedule replace an entry with the same id', () {
      // Given
      final original = _notification(
        id: 'shared',
        scheduledAt: DateTime(2026, 7, 9, 7, 30),
        title: 'Original',
      );
      final rescheduled = _notification(
        id: 'shared',
        scheduledAt: DateTime(2026, 7, 9, 9),
        title: 'Rescheduled',
      );

      // When
      final merged = mergePlanNotificationLedger(
        [original],
        [rescheduled],
        now: DateTime(2026, 7, 8),
      );

      // Then
      expect(merged.single.title, 'Rescheduled');
      expect(merged.single.scheduledAt, DateTime(2026, 7, 9, 9));
    });
  });

  group('InMemoryPlanNotificationLedger', () {
    test('adds one notification without disturbing the rest', () async {
      // Given
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(id: 'existing', scheduledAt: DateTime(2026, 7, 9)),
        ],
      );

      // When
      await ledger.addScheduled(
        _notification(id: 'smoke-test', scheduledAt: DateTime(2026, 7, 8, 12)),
      );

      // Then
      expect((await ledger.loadEntries()).map((entry) => entry.id), [
        'smoke-test',
        'existing',
      ]);
    });

    test('removes only the requested entries', () async {
      // Given
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(id: 'a', scheduledAt: DateTime(2026, 7, 8)),
          _notification(id: 'b', scheduledAt: DateTime(2026, 7, 9)),
        ],
      );

      // When
      await ledger.removeEntries(['a']);

      // Then
      expect((await ledger.loadEntries()).single.id, 'b');
    });
  });

  group('ScheduledPlanNotification ledger serialization', () {
    test('round-trips every field the inbox item needs', () {
      // Given
      final notification = _notification(
        id: 'plan-1-week-1-wed-easy-run-missed-60',
        scheduledAt: DateTime(2026, 7, 8, 8, 30),
        title: 'Still planning to run?',
      );

      // When
      final restored = ScheduledPlanNotification.fromLedgerJson(
        notification.toLedgerJson(),
      );

      // Then
      expect(restored, isNotNull);
      expect(restored!.id, notification.id);
      expect(restored.kind, notification.kind);
      expect(restored.scheduledAt, notification.scheduledAt);
      expect(restored.title, notification.title);
      expect(restored.body, notification.body);
      expect(restored.payload, notification.payload);
    });

    test('rejects a malformed record instead of throwing', () {
      expect(
        ScheduledPlanNotification.fromLedgerJson({'id': 'missing-the-rest'}),
        isNull,
      );
      expect(ScheduledPlanNotification.fromLedgerJson('not a map'), isNull);
    });
  });
}

ScheduledPlanNotification _notification({
  required String id,
  required DateTime scheduledAt,
  String title = 'Reminder',
}) {
  return ScheduledPlanNotification(
    id: id,
    kind: PlanNotificationKind.missedRunNudge,
    scheduledAt: scheduledAt,
    title: title,
    body: 'Body',
    payload: const <String, String>{
      'planId': 'plan-1',
      'scheduledWorkoutId': 'week-1-wed-easy-run',
    },
  );
}
