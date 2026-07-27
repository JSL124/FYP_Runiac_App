class NotificationInboxItem {
  const NotificationInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.deletedAt,
    this.data = const <String, Object?>{},
    this.clientManaged = false,
  });

  final String id;
  final String title;
  final String body;

  /// When the notification actually reached the runner. Never a future instant:
  /// the inbox records deliveries, not schedules.
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? deletedAt;
  final Map<String, Object?> data;

  /// True for items this app wrote itself (local plan notifications), false for
  /// items a Cloud Function delivered. Only the client-written ones are in
  /// scope for the one-time legacy cleanup.
  final bool clientManaged;

  bool get isRead => readAt != null;

  bool get isDeleted => deletedAt != null;

  NotificationInboxItem copyWith({DateTime? readAt, DateTime? deletedAt}) {
    return NotificationInboxItem(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      deletedAt: deletedAt ?? this.deletedAt,
      data: data,
      clientManaged: clientManaged,
    );
  }
}
