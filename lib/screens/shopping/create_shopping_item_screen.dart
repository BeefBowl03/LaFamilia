import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shopping_item_model.dart';
import '../../providers/shopping_provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class CreateShoppingItemScreen extends StatefulWidget {
  const CreateShoppingItemScreen({super.key});

  @override
  CreateShoppingItemScreenState createState() => CreateShoppingItemScreenState();
}

class CreateShoppingItemScreenState extends State<CreateShoppingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isUrgent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createShoppingItem() async {
    if (!_formKey.currentState!.validate()) return;

    final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final item = ShoppingItem(
      name: _nameController.text,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      notes: _notesController.text,
      isUrgent: _isUrgent,
      createdAt: DateTime.now(),
      addedBy: authProvider.currentUser!.id,
      isPurchased: false,
    );

    try {
      await shoppingProvider.addShoppingItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shopping item added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding shopping item: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shopping Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Urgent'),
                value: _isUrgent,
                onChanged: (bool value) {
                  setState(() {
                    _isUrgent = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createShoppingItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Add Item',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 