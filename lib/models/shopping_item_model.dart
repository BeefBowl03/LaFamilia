import 'dart:convert';

class ShoppingItem {
  final String? id;
  final String name;
  final int quantity;
  final String notes;
  final bool isUrgent;
  final DateTime createdAt;
  final String addedBy;
  bool isPurchased;

  ShoppingItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.notes,
    required this.isUrgent,
    required this.createdAt,
    required this.addedBy,
    required this.isPurchased,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'notes': notes,
      'isUrgent': isUrgent,
      'createdAt': createdAt.toIso8601String(),
      'addedBy': addedBy,
      'isPurchased': isPurchased,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String?,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String,
      isUrgent: json['isUrgent'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      addedBy: json['addedBy'] as String,
      isPurchased: json['isPurchased'] as bool,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? notes,
    bool? isUrgent,
    DateTime? createdAt,
    String? addedBy,
    bool? isPurchased,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      isUrgent: isUrgent ?? this.isUrgent,
      createdAt: createdAt ?? this.createdAt,
      addedBy: addedBy ?? this.addedBy,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}