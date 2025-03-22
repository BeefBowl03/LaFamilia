import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/shopping_item_model.dart';
import 'package:shopping_app/providers/shopping_provider.dart';
import 'package:shopping_app/providers/auth_provider.dart';

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
        title: const Text('Create Shopping Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              Checkbox(
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createShoppingItem,
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 