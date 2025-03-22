import 'dart:convert';
import 'user_model.dart';

class Family {
  final String id;
  final String name;
  final List<String> memberIds; // Store user IDs instead of full user objects
  final String createdBy;

  Family({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdBy,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'],
      name: json['name'],
      memberIds: List<String>.from(json['memberIds']),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'createdBy': createdBy,
    };
  }

  Family copyWith({
    String? name,
    List<String>? memberIds,
  }) {
    return Family(
      id: id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy,
    );
  }
}