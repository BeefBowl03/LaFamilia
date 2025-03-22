import 'package:flutter/foundation.dart';
import '../models/shopping_item_model.dart';
import '../services/data_service.dart';

class ShoppingProvider with ChangeNotifier {
  final DataService _dataService;
  List<ShoppingItem> _items = [];

  ShoppingProvider(this._dataService);

  List<ShoppingItem> get items => _items;

  Future<void> loadShoppingItems() async {
    try {
      final items = await _dataService.getShoppingItems();
      _items = items;
      notifyListeners();
    } catch (e) {
      print('Error loading shopping items: $e');
      rethrow;
    }
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      final id = await _dataService.addShoppingItem(item);
      final newItem = ShoppingItem(
        id: id,
        name: item.name,
        quantity: item.quantity,
        notes: item.notes,
        isUrgent: item.isUrgent,
        createdAt: item.createdAt,
        addedBy: item.addedBy,
        isPurchased: item.isPurchased,
      );
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      print('Error adding shopping item: $e');
      rethrow;
    }
  }

  Future<void> toggleItemPurchased(String itemId) async {
    try {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        final updatedItem = ShoppingItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          notes: item.notes,
          isUrgent: item.isUrgent,
          createdAt: item.createdAt,
          addedBy: item.addedBy,
          isPurchased: !item.isPurchased,
        );
        await _dataService.updateShoppingItem(updatedItem);
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling item purchased: $e');
      rethrow;
    }
  }

  Future<void> deleteShoppingItem(String itemId) async {
    try {
      await _dataService.deleteShoppingItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print('Error deleting shopping item: $e');
      rethrow;
    }
  }
} 