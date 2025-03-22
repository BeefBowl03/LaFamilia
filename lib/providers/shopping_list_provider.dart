import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/shopping_item_model.dart';
import '../services/data_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  final DataService _dataService;
  final Uuid _uuid = Uuid();

  List<ShoppingItem> _items = [];

  ShoppingListProvider(this._dataService);

  List<ShoppingItem> get items => _items;

  // Load shopping list items for the family
  Future<void> loadShoppingList(String familyId) async {
    try {
      final items = await _dataService.getShoppingItems();
      _items = items;
      notifyListeners();
    } catch (e) {
      print('Error loading shopping list: $e');
      rethrow;
    }
  }

  // Add a new item to the shopping list
  Future<void> addItem({
    required String name,
    required int quantity,
    required String addedBy,
    required String familyId,
  }) async {
    try {
      final item = ShoppingItem(
        name: name,
        quantity: quantity,
        notes: '',
        isUrgent: false,
        createdAt: DateTime.now(),
        addedBy: addedBy,
        isPurchased: false,
      );

      final id = await _dataService.addShoppingItem(item);
      final newItem = item.copyWith(id: id);
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  // Toggle completion status of an item
  Future<void> toggleItemCompletion(ShoppingItem item, String familyId) async {
    try {
      final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
      if (item.id != null) {
        await _dataService.updateShoppingItem(updatedItem);
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = updatedItem;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error toggling item completion: $e');
      rethrow;
    }
  }

  // Update an item
  Future<void> updateItem(ShoppingItem updatedItem) async {
    try {
      await _dataService.updateShoppingItem(updatedItem);
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  // Delete an item
  Future<void> deleteItem(String? itemId, String familyId) async {
    if (itemId == null) return;
    
    try {
      await _dataService.deleteShoppingItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }

  // Get items filtered by completion status
  List<ShoppingItem> getItemsByCompletion(bool isPurchased) {
    return _items.where((item) => item.isPurchased == isPurchased).toList();
  }
}