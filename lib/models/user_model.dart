import 'dart:convert';
import 'package:flutter/foundation.dart';

enum UserRole {
  parent,
  child,
}

class User {
  final String id;
  final String name;
  final String email;
  final String familyId;
  final UserRole role;
  final int age;
  final bool isParent;
  final List<String> responsibilities;
  final DateTime createdAt;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.familyId,
    required this.role,
    required this.age,
    required this.isParent,
    this.responsibilities = const [],
    DateTime? createdAt,
    this.avatarUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? familyId,
    UserRole? role,
    int? age,
    bool? isParent,
    List<String>? responsibilities,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      familyId: familyId ?? this.familyId,
      role: role ?? this.role,
      age: age ?? this.age,
      isParent: isParent ?? this.isParent,
      responsibilities: responsibilities ?? this.responsibilities,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'familyId': familyId,
      'role': role.toString(),
      'age': age,
      'isParent': isParent,
      'responsibilities': responsibilities,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      familyId: json['familyId'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.toString() == json['role'],
        orElse: () => UserRole.child,
      ),
      age: json['age'] as int,
      isParent: json['isParent'] as bool,
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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      familyId: map['familyId'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == map['role'],
        orElse: () => UserRole.child,
      ),
      age: map['age'],
      isParent: map['isParent'] ?? false,
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, familyId: $familyId, role: $role, age: $age, isParent: $isParent)';
  }
}