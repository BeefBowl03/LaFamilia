import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/notification_model.dart';
import '../services/data_service.dart';

class NotificationProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Load notifications for the current user
  Future<void> loadNotifications(String userId) async {
    _notifications = await _dataService.getNotifications(userId);
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp, newest first
    notifyListeners();
  }

  // Create a notification
  Future<void> createNotification({
    required String title,
    required String message,
    required String forUserId,
  }) async {
    await _dataService.createNotification(title, message, forUserId);
    await loadNotifications(forUserId);
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    await _dataService.markNotificationAsRead(notificationId, userId);
    await loadNotifications(userId);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    for (final notification in _notifications.where((n) => !n.isRead)) {
      await _dataService.markNotificationAsRead(notification.id, userId);
    }
    await loadNotifications(userId);
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId, String userId) async {
    await _dataService.deleteNotification(notificationId, userId);
    await loadNotifications(userId);
  }

  // Create a task assignment notification
  Future<void> createTaskAssignedNotification({
    required String taskTitle,
    required String assignedByName,
    required String forUserId,
  }) async {
    final title = 'New Task Assigned';
    final message = '$assignedByName assigned you a new task: $taskTitle';
    await createNotification(
      title: title,
      message: message,
      forUserId: forUserId,
    );
  }

  // Create a task completion notification for parent
  Future<void> createTaskCompletedNotification({
    required String taskTitle,
    required String completedByName,
    required String forParentId,
  }) async {
    final title = 'Task Completed';
    final message = '$completedByName completed the task: $taskTitle';
    await createNotification(
      title: title,
      message: message,
      forUserId: forParentId,
    );
  }

  // Create a shopping list update notification
  Future<void> createShoppingListUpdateNotification({
    required String updaterName,
    required String actionType, // 'added', 'updated', 'completed'
    required String itemName,
    required List<String> familyMemberIds,
  }) async {
    final title = 'Shopping List Updated';
    final message = '$updaterName $actionType $itemName to the shopping list';
    
    for (final memberId in familyMemberIds) {
      await createNotification(
        title: title,
        message: message,
        forUserId: memberId,
      );
    }
  }
}