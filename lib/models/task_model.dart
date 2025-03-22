import 'package:flutter/foundation.dart';

enum TaskCategory {
  school,
  chores,
  health,
  other
}

enum TaskRecurrence {
  none,
  daily,
  weekly,
  monthly
}

enum TaskPriority {
  high,
  medium,
  low
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskRecurrence recurrence;
  final String assignedToId;
  final String assignedByParentId;
  final TaskCategory category;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int orderIndex; // For drag and drop priority
  final String assignedToUserId;
  final String familyId;
  final String createdBy;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.recurrence = TaskRecurrence.none,
    required this.assignedToId,
    required this.assignedByParentId,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.orderIndex = 0,
    required this.assignedToUserId,
    required this.familyId,
    required this.createdBy,
    required this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskRecurrence? recurrence,
    String? assignedToId,
    String? assignedByParentId,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? orderIndex,
    String? assignedToUserId,
    String? familyId,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedByParentId: assignedByParentId ?? this.assignedByParentId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      familyId: familyId ?? this.familyId,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'recurrence': recurrence.toString(),
      'assignedToId': assignedToId,
      'assignedByParentId': assignedByParentId,
      'category': category.toString(),
      'priority': priority.toString(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'orderIndex': orderIndex,
      'assignedToUserId': assignedToUserId,
      'familyId': familyId,
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      recurrence: TaskRecurrence.values.firstWhere(
        (r) => r.toString() == json['recurrence'],
        orElse: () => TaskRecurrence.none,
      ),
      assignedToId: json['assignedToId'] as String,
      assignedByParentId: json['assignedByParentId'] as String,
      category: TaskCategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'] as String)
        : null,
      orderIndex: json['orderIndex'] as int? ?? 0,
      assignedToUserId: json['assignedToUserId'] as String,
      familyId: json['familyId'] as String,
      createdBy: json['createdBy'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}