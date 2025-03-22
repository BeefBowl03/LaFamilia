import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  AddFamilyMemberScreenState createState() => AddFamilyMemberScreenState();
}

class AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.child;
  bool _isAdding = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addFamilyMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.addFamilyMember(
        _nameController.text.trim(),
        _selectedRole,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_nameController.text.trim()} added to family')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding family member: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Family Member'),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Illustration
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              
              // Name input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              
              // Role selection
              Text(
                'Role',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildRoleSelection(),
              const SizedBox(height: 40),
              
              // Add button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _addFamilyMember,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Family Member',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<UserRole>(
            title: const Text('Parent'),
            subtitle: const Text('Can create and manage tasks for all family members'),
            value: UserRole.parent,
            groupValue: _selectedRole,
            onChanged: (UserRole? value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const Divider(height: 1),
          RadioListTile<UserRole>(
            title: const Text('Child'),
            subtitle: const Text('Can view and complete their assigned tasks'),
            value: UserRole.child,
            groupValue: _selectedRole,
            onChanged: (UserRole? value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }
}