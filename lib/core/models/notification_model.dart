class NotificationModel {
  final int notificationId;
  final String message;
  final String type;
  final int? alertUser;
  final bool isRead;
  final String? createdAt;

  NotificationModel({
    required this.notificationId,
    required this.message,
    required this.type,
    this.alertUser,
    required this.isRead,
    this.createdAt,
  });

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: _toNullableInt(
        json['notification_id'] ?? json['id'],
      ) ??
          0,
      message: json['message']?.toString() ?? 'No notification message.',
      type: json['type']?.toString() ?? 'general',
      alertUser: _toNullableInt(
        json['alert_user'] ??
            json['alertUser'] ??
            json['user_id'] ??
            json['userId'],
      ),
      isRead: json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read'] == '1' ||
          json['isRead'] == true ||
          json['isRead'] == 1 ||
          json['isRead'] == '1',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      message: message,
      type: type,
      alertUser: alertUser,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}