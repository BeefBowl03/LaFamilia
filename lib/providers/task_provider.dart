import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _db;
  final Uuid _uuid = Uuid();

  List<Task> _tasks = [];
  TaskCategory? _selectedCategory;
  bool _isLoading = false;

  TaskProvider(this._db);

  List<Task> get tasks => _tasks;
  TaskCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  void setSelectedCategory(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Task> getTasksDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _filterTasks(_tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(today);
    }).toList());
  }

  List<Task> getTasksDueThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _filterTasks(_tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          taskDate.isBefore(weekEnd);
    }).toList());
  }

  List<Task> getTasksDueThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    return _filterTasks(_tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          taskDate.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList());
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_selectedCategory == null) return tasks;
    return tasks.where((task) => task.category == _selectedCategory).toList();
  }

  Future<void> loadAllFamilyTasks(String familyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _db.getFamilyTasks(familyId);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      print('Error loading family tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _db.getUserTasks(userId);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      print('Error loading user tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    try {
      final createdTask = await _db.createTask(task);
      _tasks.add(createdTask);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _db.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _db.deleteTask(task.id);
      _tasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex == -1) return;

      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );

      await _db.updateTask(updatedTask);
      _tasks[taskIndex] = updatedTask;
      notifyListeners();

      // Handle recurring tasks
      if (updatedTask.isCompleted && updatedTask.recurrence != TaskRecurrence.none) {
        final nextDueDate = _calculateNextDueDate(updatedTask);
        final newTask = updatedTask.copyWith(
          id: '', // Will be set by the database
          isCompleted: false,
          dueDate: nextDueDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await createTask(newTask);
      }
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
    }
  }

  DateTime _calculateNextDueDate(Task task) {
    final dueDate = task.dueDate;
    switch (task.recurrence) {
      case TaskRecurrence.daily:
        return dueDate.add(const Duration(days: 1));
      case TaskRecurrence.weekly:
        return dueDate.add(const Duration(days: 7));
      case TaskRecurrence.monthly:
        return DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
      case TaskRecurrence.none:
        return dueDate;
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    notifyListeners();
  }

  // Get tasks filtered by category
  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  // Get tasks filtered by completion status
  List<Task> getTasksByCompletion(bool isCompleted) {
    return _tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // Get upcoming tasks (due within the next 7 days)
  List<Task> getUpcomingTasks() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final weekLater = todayDate.add(const Duration(days: 7));
    
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(todayDate) && taskDate.isBefore(weekLater);
    }).toList();
  }

  // Get overdue tasks
  List<Task> getOverdueTasks() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isBefore(todayDate) && !task.isCompleted;
    }).toList();
  }
}