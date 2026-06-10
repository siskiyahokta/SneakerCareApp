import 'package:flutter/material.dart';
import 'package:sneaker_care_app/models/notification_model.dart';
import 'package:sneaker_care_app/services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  Future<void> fetchNotifications(String customerEmail) async {
    if (customerEmail.trim().isEmpty) return;

    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.getNotifications(customerEmail: customerEmail);

    if (result['success'] == true) {
      final data = result['data'];
      if (data is List) {
        _notifications = data
            .whereType<Map>()
            .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _notifications = [];
      }
    } else {
      _errorMessage = result['message']?.toString() ?? 'Gagal mengambil notifikasi.';
    }

    _setLoading(false);
  }

  Future<bool> markAsRead({
    required String id,
    required String customerEmail,
  }) async {
    final result = await ApiService.markNotificationRead(
      id: id,
      customerEmail: customerEmail,
    );

    final success = result['success'] == true;
    if (success) {
      _notifications = _notifications
          .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
          .toList();
      notifyListeners();
    } else {
      _errorMessage = result['message']?.toString() ?? 'Gagal menandai notifikasi.';
      notifyListeners();
    }

    return success;
  }

  Future<bool> markAllAsRead(String customerEmail) async {
    final result = await ApiService.markNotificationRead(
      customerEmail: customerEmail,
      markAll: true,
    );

    final success = result['success'] == true;
    if (success) {
      _notifications = _notifications.map((item) => item.copyWith(isRead: true)).toList();
      notifyListeners();
    } else {
      _errorMessage = result['message']?.toString() ?? 'Gagal menandai semua notifikasi.';
      notifyListeners();
    }

    return success;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
