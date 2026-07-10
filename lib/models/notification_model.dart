class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? reportId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'info',
    this.reportId,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'reportId': reportId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        userId: map['userId'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        type: map['type'] as String? ?? 'info',
        reportId: map['reportId'] as String?,
        isRead: map['isRead'] as bool? ?? false,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
      );
}
