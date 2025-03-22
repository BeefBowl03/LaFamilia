import 'dart:convert';
import 'package:flutter/foundation.dart';

enum UserRole { parent, child }

class User {
  final String id;
  final String name;
  final int age;
  final UserRole role;
  final String familyId;
  final List<String> responsibilities;
  final DateTime createdAt;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.familyId,
    this.responsibilities = const [],
    DateTime? createdAt,
    this.avatarUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? name,
    int? age,
    UserRole? role,
    String? familyId,
    List<String>? responsibilities,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      role: role ?? this.role,
      familyId: familyId ?? this.familyId,
      responsibilities: responsibilities ?? this.responsibilities,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'role': role.toString(),
      'familyId': familyId,
      'responsibilities': responsibilities,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      role: UserRole.values.firstWhere(
        (role) => role.toString() == json['role'],
        orElse: () => UserRole.child,
      ),
      familyId: json['familyId'] as String,
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}