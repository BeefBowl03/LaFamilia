import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/shopping_item_model.dart';
import '../services/data_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final Uuid _uuid = Uuid();

  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => _items;

  // Load shopping list items for the family
  Future<void> loadShoppingList(String familyId) async {
    _items = await _dataService.getShoppingList(familyId);
    notifyListeners();
  }

  // Add a new item to the shopping list
  Future<void> addItem({
    required String name,
    required int quantity,
    required String addedBy,
    required String familyId,
  }) async {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      addedBy: addedBy,
      isCompleted: false,
    );

    await _dataService.addShoppingItem(item, familyId);
    await loadShoppingList(familyId);
  }

  // Toggle completion status of an item
  Future<void> toggleItemCompletion(ShoppingItem item, String familyId) async {
    final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
    await _dataService.updateShoppingItem(updatedItem, familyId);
    await loadShoppingList(familyId);
  }

  // Update an item
  Future<void> updateItem(ShoppingItem updatedItem, String familyId) async {
    await _dataService.updateShoppingItem(updatedItem, familyId);
    await loadShoppingList(familyId);
  }

  // Delete an item
  Future<void> deleteItem(String itemId, String familyId) async {
    await _dataService.deleteShoppingItem(itemId, familyId);
    await loadShoppingList(familyId);
  }

  // Get items filtered by completion status
  List<ShoppingItem> getItemsByCompletion(bool isCompleted) {
    return _items.where((item) => item.isCompleted == isCompleted).toList();
  }
}