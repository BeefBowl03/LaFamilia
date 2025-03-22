import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/shopping_item_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/shopping_list_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../theme/app_theme.dart';

class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  ShoppingListTabState createState() => ShoppingListTabState();
}

class ShoppingListTabState extends State<ShoppingListTab> with SingleTickerProviderStateMixin {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    _loadShoppingList();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadShoppingList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
      
      if (authProvider.currentFamily != null) {
        await shoppingListProvider.loadShoppingList(authProvider.currentFamily!.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shopping list: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddItemDialog() {
    _itemNameController.clear();
    _quantityController.text = '1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Shopping Item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.shopping_basket),
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addItemToShoppingList,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Item'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addItemToShoppingList() async {
    final itemName = _itemNameController.text.trim();
    final quantityText = _quantityController.text.trim();
    
    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }

    int quantity = 1;
    try {
      quantity = int.parse(quantityText);
      if (quantity <= 0) throw FormatException();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (authProvider.currentUser != null && authProvider.currentFamily != null) {
      Navigator.pop(context);
      
      await shoppingListProvider.addItem(
        name: itemName,
        quantity: quantity,
        addedBy: authProvider.currentUser!.id,
        familyId: authProvider.currentFamily!.id,
      );

      // Notify other family members
      final currentUser = authProvider.currentUser!;
      final familyMembers = await authProvider.getFamilyMembers();
      final otherMembersIds = familyMembers
          .where((member) => member.id != currentUser.id)
          .map((member) => member.id)
          .toList();

      if (otherMembersIds.isNotEmpty) {
        await notificationProvider.createShoppingListUpdateNotification(
          updaterName: currentUser.name,
          actionType: 'added',
          itemName: itemName,
          familyMemberIds: otherMembersIds,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final items = shoppingListProvider.items;
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadShoppingList,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: items.isEmpty
                    ? _buildEmptyState()
                    : _buildShoppingList(items),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShoppingList(List<ShoppingItem> items) {
    final notCompletedItems = items.where((item) => !item.isCompleted).toList();
    final completedItems = items.where((item) => item.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (notCompletedItems.isNotEmpty) ...[  
          Text(
            'Items to Buy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...notCompletedItems.map((item) => _buildShoppingItemCard(item, false)),
          const SizedBox(height: 24),
        ],
        
        if (completedItems.isNotEmpty) ...[  
          Text(
            'Completed Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...completedItems.map((item) => _buildShoppingItemCard(item, true)),
        ],
      ],
    );
  }

  Widget _buildShoppingItemCard(ShoppingItem item, bool isCompleted) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(item.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: AppTheme.dangerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) async {
          if (authProvider.currentFamily != null) {
            await shoppingListProvider.deleteItem(
              item.id,
              authProvider.currentFamily!.id,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? Colors.transparent
                  : Theme.of(context).dividerTheme.color!.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: item.isCompleted,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: AppTheme.primaryColor,
              onChanged: (bool? value) async {
                if (authProvider.currentFamily != null && authProvider.currentUser != null) {
                  await shoppingListProvider.toggleItemCompletion(
                    item,
                    authProvider.currentFamily!.id,
                  );
                  
                  // Notify other family members
                  final currentUser = authProvider.currentUser!;
                  final familyMembers = await authProvider.getFamilyMembers();
                  final otherMembersIds = familyMembers
                      .where((member) => member.id != currentUser.id)
                      .map((member) => member.id)
                      .toList();

                  if (otherMembersIds.isNotEmpty) {
                    await notificationProvider.createShoppingListUpdateNotification(
                      updaterName: currentUser.name,
                      actionType: value == true ? 'completed' : 'uncompleted',
                      itemName: item.name,
                      familyMemberIds: otherMembersIds,
                    );
                  }
                }
              },
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCompleted ? FontWeight.normal : FontWeight.bold,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6)
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'x${item.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Shopping List is Empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your family shopping list',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}