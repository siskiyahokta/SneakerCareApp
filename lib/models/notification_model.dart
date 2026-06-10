class NotificationModel {
  final String id;
  final String customerEmail;
  final String orderId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.customerEmail,
    required this.orderId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _readString(json, ['id']),
      customerEmail: _readString(json, ['customer_email', 'customerEmail']),
      orderId: _readString(json, ['order_id', 'orderId']),
      title: _readString(json, ['title'], defaultValue: 'Notifikasi'),
      body: _readString(json, ['body', 'message']),
      type: _readString(json, ['type'], defaultValue: 'order_status'),
      isRead: _readBool(json, ['is_read', 'isRead']),
      createdAt: _readString(json, ['created_at', 'createdAt']),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? customerEmail,
    String? orderId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      customerEmail: customerEmail ?? this.customerEmail,
      orderId: orderId ?? this.orderId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String defaultValue = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value.toString();
    }
    return defaultValue;
  }

  static bool _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is bool) return value;
      if (value is int) return value == 1;
      return value.toString() == '1' || value.toString().toLowerCase() == 'true';
    }
    return false;
  }
}
