import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class AddFamilyMemberDialog extends StatefulWidget {
  final Function(String name, int age, UserRole role, List<String> responsibilities) onAdd;

  const AddFamilyMemberDialog({
    super.key,
    required this.onAdd,
  });

  @override
  AddFamilyMemberDialogState createState() => AddFamilyMemberDialogState();
}

class AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  UserRole _selectedRole = UserRole.child;
  final List<String> _responsibilities = [];

  final List<String> _commonResponsibilities = [
    'Clean Room',
    'Make Bed',
    'Do Homework',
    'Help with Dishes',
    'Take Out Trash',
    'Feed Pets',
    'Laundry',
    'Set Table',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addMember() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(
        _nameController.text,
        int.parse(_ageController.text),
        _selectedRole,
        _responsibilities,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Family Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter age',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role == UserRole.parent ? 'Parent' : 'Child'),
                  );
                }).toList(),
                onChanged: (UserRole? value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              if (_selectedRole == UserRole.child) ...[
                const SizedBox(height: 16),
                const Text(
                  'Select Responsibilities:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _commonResponsibilities.map((responsibility) {
                    final isSelected = _responsibilities.contains(responsibility);
                    return FilterChip(
                      label: Text(responsibility),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _responsibilities.add(responsibility);
                          } else {
                            _responsibilities.remove(responsibility);
                          }
                        });
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addMember,
          child: const Text('Add'),
        ),
      ],
    );
  }
} 