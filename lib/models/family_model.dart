import 'dart:convert';
import 'user_model.dart';

class Family {
  final String id;
  final String name;
  final List<String> memberIds; // Store user IDs instead of full user objects
  final DateTime createdAt;
  final String createdBy;

  Family({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Family.fromMap(Map<String, dynamic> map) {
    return Family(
      id: map['id'],
      name: map['name'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }

  factory Family.fromJson(Map<String, dynamic> json) => Family.fromMap(json);

  Family copyWith({
    String? name,
    List<String>? memberIds,
  }) {
    return Family(
      id: id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  @override
  String toString() {
    return 'Family(id: $id, name: $name, memberIds: $memberIds, createdAt: $createdAt, createdBy: $createdBy)';
  }
}