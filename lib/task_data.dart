// lib/task_data.dart

import 'models/task.dart';
import 'models/notification.dart';
import 'services/api_service.dart';

export 'models/task.dart';

class TaskData {
  static List<Task> tasks = [];
  static List<NotificationItem> notifications = [];

  static List<String> categories = [
    'General',
    'Study',
    'Work',
    'Personal',
  ];

  // ================= TASKS =================

  static void setTasks(List<Task> newTasks) {
    tasks = newTasks;
  }

  static void clearTasks() {
    tasks.clear();
  }

  static void addTask(Task task) {
    tasks.insert(0, task);
    _createNotification(
      title: 'New Task Added',
      message: '"${task.title}" has been added to your tasks.',
    );
  }

  static void updateTask(Task updatedTask) {
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      _createNotification(
        title: 'Task Updated',
        message: '"${updatedTask.title}" has been updated.',
      );
    }
  }

  static void deleteTask(int taskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    final taskTitle = index != -1 ? tasks[index].title : 'A task';
    tasks.removeWhere((task) => task.id == taskId);
    _createNotification(
      title: 'Task Deleted',
      message: '"$taskTitle" has been deleted.',
    );
  }

  static void toggleTaskStatus(int taskId, bool isCompleted) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      tasks[index].isCompleted = isCompleted;
      if (isCompleted) {
        _createNotification(
          title: 'Task Completed',
          message: '"${tasks[index].title}" has been marked as completed!',
        );
      } else {
        _createNotification(
          title: 'Task Reopened',
          message: '"${tasks[index].title}" has been marked as pending.',
        );
      }
    }
  }

  // ================= CATEGORIES =================

  static void setCategories(List<String> newCategories) {
    categories = newCategories;
  }

  static void addCategory(String categoryName) {
    final cleanName = categoryName.trim();
    if (cleanName.isNotEmpty && !categories.contains(cleanName)) {
      categories.add(cleanName);
    }
  }

  static void clearCategories() {
    categories = [
      'General',
      'Study',
      'Work',
      'Personal',
    ];
  }

  // ================= NOTIFICATIONS =================

  static Future<void> _createNotification({
    required String title,
    required String message,
  }) async {
    // Add locally immediately so UI updates instantly
    final localNotification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
    );
    notifications.insert(0, localNotification);

    // ✅ Save to backend — using postNotification which exists in api_service.dart
    try {
      await ApiService.postNotification(title: title, message: message);
    } catch (e) {
      // Local notification still shows even if backend fails
    }
  }

  static void setNotifications(List<NotificationItem> newNotifications) {
    notifications = newNotifications;
  }

  static void clearNotifications() {
    notifications.clear();
  }

  static int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;
}