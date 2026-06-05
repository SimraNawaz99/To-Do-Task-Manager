import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/notification.dart';

class NotificationData extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService.getNotifications();

      // ✅ Handle both { notifications: [...] } and direct list response
      List<dynamic> rawList = [];

      if (data['notifications'] != null && data['notifications'] is List) {
        rawList = data['notifications'] as List;
      } else if (data['data'] != null && data['data'] is List) {
        rawList = data['data'] as List;
      }

      _notifications = rawList
          .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // ✅ Sort newest first
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (_notifications.isEmpty) {
        _errorMessage = null; // No error, just empty
      }
    } catch (e) {
      _errorMessage = 'Failed to load notifications.';
      debugPrint('Notification fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    try {
      await ApiService.markAllNotificationsRead();
    } catch (e) {
      debugPrint('Mark all read error: $e');
    }
  }

  Future<void> markOneRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      try {
        await ApiService.markNotificationRead(id);
      } catch (e) {
        debugPrint('Mark read error: $e');
      }
    }
  }
}