import 'dart:convert';

class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final bool isCompleted;
  final String addedBy; // User ID

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.isCompleted = false,
    required this.addedBy,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      isCompleted: json['isCompleted'],
      addedBy: json['addedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isCompleted': isCompleted,
      'addedBy': addedBy,
    };
  }

  ShoppingItem copyWith({
    String? name,
    int? quantity,
    bool? isCompleted,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      addedBy: addedBy,
    );
  }
}