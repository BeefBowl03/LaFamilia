import 'package:flutter/foundation.dart';

enum ShoppingItemCategory {
  groceries,
  household,
  school,
  other
}

class ShoppingItem {
  final String id;
  final String name;
  final String? note;
  final ShoppingItemCategory category;
  final bool isBought;
  final String addedByUserId;
  final DateTime createdAt;
  final DateTime? boughtAt;
  final String? boughtByUserId;

  ShoppingItem({
    required this.id,
    required this.name,
    this.note,
    this.category = ShoppingItemCategory.groceries,
    this.isBought = false,
    required this.addedByUserId,
    DateTime? createdAt,
    this.boughtAt,
    this.boughtByUserId,
  }) : createdAt = createdAt ?? DateTime.now();

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? note,
    ShoppingItemCategory? category,
    bool? isBought,
    String? addedByUserId,
    DateTime? createdAt,
    DateTime? boughtAt,
    String? boughtByUserId,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      category: category ?? this.category,
      isBought: isBought ?? this.isBought,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      createdAt: createdAt ?? this.createdAt,
      boughtAt: boughtAt ?? this.boughtAt,
      boughtByUserId: boughtByUserId ?? this.boughtByUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'category': category.toString(),
      'isBought': isBought,
      'addedByUserId': addedByUserId,
      'createdAt': createdAt.toIso8601String(),
      'boughtAt': boughtAt?.toIso8601String(),
      'boughtByUserId': boughtByUserId,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      note: json['note'] as String?,
      category: ShoppingItemCategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => ShoppingItemCategory.groceries,
      ),
      isBought: json['isBought'] as bool? ?? false,
      addedByUserId: json['addedByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      boughtAt: json['boughtAt'] != null 
        ? DateTime.parse(json['boughtAt'] as String)
        : null,
      boughtByUserId: json['boughtByUserId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ShoppingList {
  final String id;
  final String familyId;
  final List<ShoppingItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    required this.id,
    required this.familyId,
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ShoppingList copyWith({
    String? id,
    String? familyId,
    List<ShoppingItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      items: (json['items'] as List<dynamic>)
        .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
        .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
} 