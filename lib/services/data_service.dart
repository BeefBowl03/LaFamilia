import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/family_model.dart';
import '../models/task_model.dart';
import '../models/shopping_item_model.dart';
import '../models/notification_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final Uuid _uuid = Uuid();
  late SharedPreferences _prefs;
  List<ShoppingItem> _shoppingItems = [];

  // Initialization method
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys for SharedPreferences
  static const String _currentUserIdKey = 'current_user_id';
  static const String _familyPrefix = 'family_';
  static const String _userPrefix = 'user_';
  static const String _tasksPrefix = 'tasks_';
  static const String _shoppingPrefix = 'shopping_';
  static const String _notificationPrefix = 'notification_';

  // Current User Methods
  Future<void> setCurrentUserId(String userId) async {
    await _prefs.setString(_currentUserIdKey, userId);
  }

  String? getCurrentUserId() {
    return _prefs.getString(_currentUserIdKey);
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_currentUserIdKey);
  }

  // User Methods
  Future<void> saveUser(User user) async {
    await _prefs.setString(_userPrefix + user.id, jsonEncode(user.toJson()));
  }

  User? getUser(String userId) {
    final userJson = _prefs.getString(_userPrefix + userId);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<List<User>> getAllFamilyMembers(String familyId) async {
    final family = getFamily(familyId);
    if (family == null) return [];

    List<User> members = [];
    for (String memberId in family.memberIds) {
      final user = getUser(memberId);
      if (user != null) {
        members.add(user);
      }
    }
    return members;
  }

  // Family Methods
  Future<void> saveFamily(Family family) async {
    await _prefs.setString(_familyPrefix + family.id, jsonEncode(family.toJson()));
  }

  Family? getFamily(String familyId) {
    final familyJson = _prefs.getString(_familyPrefix + familyId);
    if (familyJson == null) return null;
    return Family.fromJson(jsonDecode(familyJson));
  }

  // Tasks Methods
  Future<String> createTask(Task task) async {
    final taskId = task.id.isNotEmpty ? task.id : _uuid.v4();
    final newTask = Task(
      id: taskId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      assignedToId: task.assignedToId,
      assignedByParentId: task.assignedByParentId,
      category: task.category,
      priority: task.priority,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      orderIndex: task.orderIndex,
      assignedToUserId: task.assignedToUserId,
      familyId: task.familyId,
      createdBy: task.createdBy,
      updatedAt: DateTime.now(),
      recurrence: task.recurrence,
    );

    // Get all tasks for the family
    final allTasks = await getTasks(task.assignedToUserId);
    allTasks.add(newTask);

    // Save all tasks
    await saveTasks(task.assignedToUserId, allTasks);
    return taskId;
  }

  Future<void> saveTasks(String userId, List<Task> tasks) async {
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await _prefs.setString(_tasksPrefix + userId, jsonEncode(tasksJson));
  }

  Future<List<Task>> getTasks(String userId) async {
    final tasksJson = _prefs.getString(_tasksPrefix + userId);
    if (tasksJson == null) return [];

    final List<dynamic> taskList = jsonDecode(tasksJson);
    return taskList.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> updateTask(Task task) async {
    final tasks = await getTasks(task.assignedToUserId);
    final index = tasks.indexWhere((t) => t.id == task.id);
    
    if (index >= 0) {
      tasks[index] = task;
      await saveTasks(task.assignedToUserId, tasks);
    }
  }

  Future<void> deleteTask(Task task) async {
    final tasks = await getTasks(task.assignedToUserId);
    tasks.removeWhere((t) => t.id == task.id);
    await saveTasks(task.assignedToUserId, tasks);
  }

  // Shopping List Methods
  Future<String> addShoppingItem(ShoppingItem item) async {
    final itemId = _uuid.v4();
    final newItem = item.copyWith(id: itemId);
    _shoppingItems.add(newItem);
    
    // Save to SharedPreferences
    await _saveShoppingItems();
    return itemId;
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    if (item.id == null) return;
    
    final index = _shoppingItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shoppingItems[index] = item;
      await _saveShoppingItems();
    }
  }

  Future<void> deleteShoppingItem(String itemId) async {
    _shoppingItems.removeWhere((item) => item.id == itemId);
    await _saveShoppingItems();
  }

  Future<List<ShoppingItem>> getShoppingItems() async {
    final itemsJson = _prefs.getString(_shoppingPrefix);
    if (itemsJson != null) {
      final List<dynamic> itemsList = jsonDecode(itemsJson);
      _shoppingItems = itemsList.map((json) => ShoppingItem.fromJson(json)).toList();
    }
    return _shoppingItems;
  }

  Future<void> _saveShoppingItems() async {
    final itemsJson = jsonEncode(_shoppingItems.map((item) => item.toJson()).toList());
    await _prefs.setString(_shoppingPrefix, itemsJson);
  }

  // Notification Methods
  Future<String> createNotification(
    String title,
    String message,
    String forUserId,
  ) async {
    final notificationId = _uuid.v4();
    final notification = NotificationModel(
      id: notificationId,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      forUserId: forUserId,
    );

    // Get all notifications for the user
    final allNotifications = await getNotifications(forUserId);
    allNotifications.add(notification);

    // Save all notifications
    await saveNotifications(forUserId, allNotifications);
    return notificationId;
  }

  Future<void> saveNotifications(String userId, List<NotificationModel> notifications) async {
    final notificationsJson = notifications.map((notification) => notification.toJson()).toList();
    await _prefs.setString(_notificationPrefix + userId, jsonEncode(notificationsJson));
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final notificationsJson = _prefs.getString(_notificationPrefix + userId);
    if (notificationsJson == null) return [];

    final List<dynamic> notificationList = jsonDecode(notificationsJson);
    return notificationList.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markNotificationAsRead(String notificationId, String userId) async {
    final notifications = await getNotifications(userId);
    final index = notifications.indexWhere((n) => n.id == notificationId);
    
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await saveNotifications(userId, notifications);
    }
  }

  Future<void> deleteNotification(String notificationId, String userId) async {
    final notifications = await getNotifications(userId);
    notifications.removeWhere((n) => n.id == notificationId);
    await saveNotifications(userId, notifications);
  }

  // Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}