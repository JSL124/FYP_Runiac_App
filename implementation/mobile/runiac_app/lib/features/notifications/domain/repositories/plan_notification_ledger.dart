import '../models/plan_notification_schedule.dart';

/// A local record of the plan notifications actually handed to the OS.
///
/// The inbox is a catch-up surface for notifications the runner missed, so an
/// item may only be written once a notification has genuinely fired. That
/// leaves a gap: at delivery time the OS tells us an identifier and nothing
/// else. This ledger keeps the title, body, kind, and payload alongside that
/// identifier so a delivery can be turned back into an inbox item, and so a
/// notification cancelled before it ever fired can be recognised and dropped.
abstract class PlanNotificationLedger {
  Future<List<ScheduledPlanNotification>> loadEntries();

  /// Records the set just handed to the OS, per [mergePlanNotificationLedger].
  Future<void> replaceScheduled(
    List<ScheduledPlanNotification> scheduled, {
    required DateTime now,
  });

  /// Records one notification scheduled outside the plan sync, without
  /// disturbing the rest of the ledger.
  Future<void> addScheduled(ScheduledPlanNotification notification);

  Future<void> removeEntries(Iterable<String> ids);

  Future<void> clear();
}

/// Merges a freshly scheduled set into the existing ledger.
///
/// Entries already due (`scheduledAt <= now`) survive even when the new set
/// omits them, because they may have fired while the app was closed and not
/// been materialized yet. Without that carry-over, a notification that fired
/// five minutes before launch would be dropped by the sync that runs on the
/// shell's first build and would never reach the inbox.
///
/// Entries still in the future that the new set omits are dropped — that is
/// exactly a cancelled notification (a completed workout's missed-run nudge,
/// say), and it must never become an inbox row.
List<ScheduledPlanNotification> mergePlanNotificationLedger(
  List<ScheduledPlanNotification> existing,
  List<ScheduledPlanNotification> scheduled, {
  required DateTime now,
}) {
  final merged = <String, ScheduledPlanNotification>{
    for (final entry in existing)
      if (!entry.scheduledAt.isAfter(now)) entry.id: entry,
  };
  for (final entry in scheduled) {
    merged[entry.id] = entry;
  }
  final entries = merged.values.toList()
    ..sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));
  return List<ScheduledPlanNotification>.unmodifiable(entries);
}

/// Test double and the no-op used wherever local plan notifications are off.
class InMemoryPlanNotificationLedger implements PlanNotificationLedger {
  InMemoryPlanNotificationLedger({
    List<ScheduledPlanNotification> entries =
        const <ScheduledPlanNotification>[],
  }) : _entries = List<ScheduledPlanNotification>.of(entries);

  List<ScheduledPlanNotification> _entries;

  @override
  Future<List<ScheduledPlanNotification>> loadEntries() async {
    return List<ScheduledPlanNotification>.unmodifiable(_entries);
  }

  @override
  Future<void> replaceScheduled(
    List<ScheduledPlanNotification> scheduled, {
    required DateTime now,
  }) async {
    _entries = mergePlanNotificationLedger(_entries, scheduled, now: now);
  }

  @override
  Future<void> addScheduled(ScheduledPlanNotification notification) async {
    _entries = [
      ..._entries.where((entry) => entry.id != notification.id),
      notification,
    ]..sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));
  }

  @override
  Future<void> removeEntries(Iterable<String> ids) async {
    final removed = ids.toSet();
    _entries = _entries
        .where((entry) => !removed.contains(entry.id))
        .toList(growable: false);
  }

  @override
  Future<void> clear() async {
    _entries = const <ScheduledPlanNotification>[];
  }
}
