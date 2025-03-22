import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class AddFamilyMemberDialog extends StatefulWidget {
  final Function(String name, int age, UserRole role, List<String> responsibilities) onAdd;

  const AddFamilyMemberDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  AddFamilyMemberDialogState createState() => AddFamilyMemberDialogState();
}

class AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  UserRole _selectedRole = UserRole.child;
  final List<String> _selectedResponsibilities = [];

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Family Member'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<UserRole>(
              value: _selectedRole,
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
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
                  final isSelected = _selectedResponsibilities.contains(responsibility);
                  return FilterChip(
                    label: Text(responsibility),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedResponsibilities.add(responsibility);
                        } else {
                          _selectedResponsibilities.remove(responsibility);
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text;
            final age = int.tryParse(_ageController.text) ?? 0;
            if (name.isNotEmpty && age > 0) {
              widget.onAdd(name, age, _selectedRole, _selectedResponsibilities);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
} 