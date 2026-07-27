import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/domain/models/notification_inbox_item.dart';
import 'package:runiac_app/features/notifications/domain/models/plan_notification_schedule.dart';
import 'package:runiac_app/features/notifications/domain/repositories/notification_inbox_repository.dart';
import 'package:runiac_app/features/notifications/domain/repositories/plan_notification_ledger.dart';
import 'package:runiac_app/features/notifications/domain/repositories/plan_notification_scheduler.dart';
import 'package:runiac_app/features/notifications/domain/services/plan_notification_delivery_materializer.dart';

void main() {
  group('PlanNotificationDeliveryMaterializer', () {
    test('writes a reported delivery using the real delivery time', () async {
      // Given: the platform reported that a scheduled reminder was presented.
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(id: 'fired', scheduledAt: DateTime(2026, 7, 8, 7, 30)),
        ],
      );
      final inbox = InMemoryNotificationInboxRepository();
      final materializer = _materializer(
        ledger: ledger,
        inbox: inbox,
        deliveries: [
          PlanNotificationDelivery(
            id: 'fired',
            deliveredAt: DateTime(2026, 7, 8, 7, 31),
          ),
        ],
        now: DateTime(2026, 7, 8, 9),
      );

      // When
      await materializer.materializeDeliveries();

      // Then: the platform's instant wins over the scheduled one, and the
      // ledger entry is spent so a second pass cannot duplicate it.
      final items = await inbox.listInboxItems();
      expect(items.single.id, 'fired');
      expect(items.single.createdAt, DateTime(2026, 7, 8, 7, 31));
      expect(items.single.data, containsPair('kind', 'missedRunNudge'));
      expect(items.single.data, containsPair('planId', 'plan-1'));
      expect(items.single.clientManaged, isTrue);
      expect(await ledger.loadEntries(), isEmpty);
    });

    test(
      'falls back to the scheduled time when nothing was reported',
      () async {
        // Given: iOS reports nothing for a background notification the runner
        // never tapped, so a passed schedule is the only remaining evidence.
        final ledger = InMemoryPlanNotificationLedger(
          entries: [
            _notification(
              id: 'silent',
              scheduledAt: DateTime(2026, 7, 8, 7, 30),
            ),
          ],
        );
        final inbox = InMemoryNotificationInboxRepository();
        final materializer = _materializer(
          ledger: ledger,
          inbox: inbox,
          deliveries: const <PlanNotificationDelivery>[],
          now: DateTime(2026, 7, 8, 9),
        );

        // When
        await materializer.materializeDeliveries();

        // Then
        final items = await inbox.listInboxItems();
        expect(items.single.id, 'silent');
        expect(items.single.createdAt, DateTime(2026, 7, 8, 7, 30));
        expect(await ledger.loadEntries(), isEmpty);
      },
    );

    test('leaves a notification that has not fired out of the inbox', () async {
      // Given
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(
            id: 'upcoming',
            scheduledAt: DateTime(2026, 7, 9, 7, 30),
          ),
        ],
      );
      final inbox = InMemoryNotificationInboxRepository();
      final materializer = _materializer(
        ledger: ledger,
        inbox: inbox,
        deliveries: const <PlanNotificationDelivery>[],
        now: DateTime(2026, 7, 8, 9),
      );

      // When
      await materializer.materializeDeliveries();

      // Then: the inbox holds missed notifications only, so the bell badge
      // still reads zero and the entry waits for its moment.
      expect(await inbox.listInboxItems(), isEmpty);
      expect((await ledger.loadEntries()).single.id, 'upcoming');
    });

    test('ignores a delivery that is not in this runner ledger', () async {
      // Given: a push notification's identifier, which the app writes to the
      // inbox on receipt through its own path.
      final ledger = InMemoryPlanNotificationLedger();
      final inbox = InMemoryNotificationInboxRepository();
      final materializer = _materializer(
        ledger: ledger,
        inbox: inbox,
        deliveries: [
          PlanNotificationDelivery(
            id: 'challenge_result_ready_abc',
            deliveredAt: DateTime(2026, 7, 8, 7, 31),
          ),
        ],
        now: DateTime(2026, 7, 8, 9),
      );

      // When
      await materializer.materializeDeliveries();

      // Then
      expect(await inbox.listInboxItems(), isEmpty);
    });

    test('is idempotent across repeated passes', () async {
      // Given
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(id: 'fired', scheduledAt: DateTime(2026, 7, 8, 7, 30)),
        ],
      );
      final inbox = InMemoryNotificationInboxRepository();
      final reader = _FakeDeliveryReader([
        PlanNotificationDelivery(
          id: 'fired',
          deliveredAt: DateTime(2026, 7, 8, 7, 31),
        ),
      ]);
      final materializer = PlanNotificationDeliveryMaterializer(
        ledger: ledger,
        deliveryReader: reader,
        inboxRepository: inbox,
        ownerUidProvider: () => 'runner-1',
        clock: () => DateTime(2026, 7, 8, 9),
      );

      // When: resume fires the pass again, and the platform re-reports the
      // notification still sitting in the notification centre.
      await materializer.materializeDeliveries();
      reader.queue.add(
        PlanNotificationDelivery(
          id: 'fired',
          deliveredAt: DateTime(2026, 7, 8, 7, 31),
        ),
      );
      await materializer.materializeDeliveries();

      // Then
      expect(await inbox.listInboxItems(), hasLength(1));
    });

    test('does not drain deliveries while signed out', () async {
      // Given: an inbox write needs an owner, and draining is destructive.
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(id: 'fired', scheduledAt: DateTime(2026, 7, 8, 7, 30)),
        ],
      );
      final inbox = InMemoryNotificationInboxRepository();
      final reader = _FakeDeliveryReader([
        PlanNotificationDelivery(
          id: 'fired',
          deliveredAt: DateTime(2026, 7, 8, 7, 31),
        ),
      ]);
      final materializer = PlanNotificationDeliveryMaterializer(
        ledger: ledger,
        deliveryReader: reader,
        inboxRepository: inbox,
        ownerUidProvider: () => null,
        clock: () => DateTime(2026, 7, 8, 9),
      );

      // When
      await materializer.materializeDeliveries();

      // Then: the report survives until someone can claim it.
      expect(await inbox.listInboxItems(), isEmpty);
      expect(reader.consumeCallCount, 0);
      expect((await ledger.loadEntries()).single.id, 'fired');
    });

    test('keeps the ledger entry when the inbox write fails', () async {
      // Given
      final ledger = InMemoryPlanNotificationLedger(
        entries: [
          _notification(id: 'fired', scheduledAt: DateTime(2026, 7, 8, 7, 30)),
        ],
      );
      final materializer = PlanNotificationDeliveryMaterializer(
        ledger: ledger,
        deliveryReader: _FakeDeliveryReader(const <PlanNotificationDelivery>[]),
        inboxRepository: const _ThrowingNotificationInboxRepository(),
        ownerUidProvider: () => 'runner-1',
        clock: () => DateTime(2026, 7, 8, 9),
      );

      // When
      await materializer.materializeDeliveries();

      // Then: the next pass retries rather than losing the notification.
      expect((await ledger.loadEntries()).single.id, 'fired');
    });
  });
}

PlanNotificationDeliveryMaterializer _materializer({
  required InMemoryPlanNotificationLedger ledger,
  required NotificationInboxRepository inbox,
  required List<PlanNotificationDelivery> deliveries,
  required DateTime now,
}) {
  return PlanNotificationDeliveryMaterializer(
    ledger: ledger,
    deliveryReader: _FakeDeliveryReader(deliveries),
    inboxRepository: inbox,
    ownerUidProvider: () => 'runner-1',
    clock: () => now,
  );
}

ScheduledPlanNotification _notification({
  required String id,
  required DateTime scheduledAt,
}) {
  return ScheduledPlanNotification(
    id: id,
    kind: PlanNotificationKind.missedRunNudge,
    scheduledAt: scheduledAt,
    title: 'Still planning to run?',
    body: 'Easy Run was scheduled 1 hour ago.',
    payload: const <String, String>{'planId': 'plan-1'},
  );
}

class _FakeDeliveryReader implements PlanNotificationDeliveryReader {
  _FakeDeliveryReader(List<PlanNotificationDelivery> deliveries)
    : queue = List<PlanNotificationDelivery>.of(deliveries);

  final List<PlanNotificationDelivery> queue;
  var consumeCallCount = 0;

  @override
  Future<List<PlanNotificationDelivery>> consumeDeliveredNotifications() async {
    consumeCallCount += 1;
    final drained = List<PlanNotificationDelivery>.of(queue);
    queue.clear();
    return drained;
  }

  @override
  set onDelivered(void Function()? listener) {}
}

class _ThrowingNotificationInboxRepository extends NotificationInboxRepository {
  const _ThrowingNotificationInboxRepository();

  @override
  Stream<List<NotificationInboxItem>> watchInboxItems() =>
      const Stream<List<NotificationInboxItem>>.empty();

  @override
  Future<List<NotificationInboxItem>> listInboxItems() async =>
      const <NotificationInboxItem>[];

  @override
  Stream<int> watchUnreadCount() => Stream<int>.value(0);

  @override
  Future<void> saveInboxItem(NotificationInboxItem item) async {
    throw StateError('offline');
  }

  @override
  Future<void> markRead(String itemId) async {}

  @override
  Future<void> softDelete(String itemId) async {}
}
