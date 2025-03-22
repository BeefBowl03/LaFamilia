import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  FamilySetupScreenState createState() => FamilySetupScreenState();
}

class FamilySetupScreenState extends State<FamilySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final List<FamilyMemberEntry> _familyMembers = [];
  int _currentStep = 0;

  @override
  void dispose() {
    _familyNameController.dispose();
    _parentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Family'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _handleFamilyCreation();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: const Text('Family Details'),
            content: _buildFamilyDetailsStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Add Family Members'),
            content: _buildFamilyMembersStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Review & Finish'),
            content: _buildReviewStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _familyNameController,
            decoration: const InputDecoration(
              labelText: 'Family Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.family_restroom),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your family name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _parentNameController,
            decoration: const InputDecoration(
              labelText: 'Your Name (Parent)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersStep() {
    return Column(
      children: [
        ..._familyMembers.map((member) => _buildFamilyMemberCard(member)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showAddMemberDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Family Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Family Name: ${_familyNameController.text}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Parent: ${_parentNameController.text}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Family Members:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._familyMembers.map((member) => Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Text(
            '${member.name} (${member.isParent ? "Parent" : "Child"})',
            style: const TextStyle(fontSize: 16),
          ),
        )),
      ],
    );
  }

  Widget _buildFamilyMemberCard(FamilyMemberEntry member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          member.isParent ? Icons.person : Icons.child_care,
          color: AppTheme.primaryColor,
        ),
        title: Text(member.name),
        subtitle: Text(member.email),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _familyMembers.remove(member);
            });
          },
        ),
      ),
    );
  }

  void _handleFamilyCreation() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Add debug prints
        print('Creating family with parent:');
        print('Family Name: ${_familyNameController.text}');
        print('Parent Name: ${_parentNameController.text}');
        
        // Create family and first parent
        final parentId = await authProvider.createFamilyAndFirstParent(
          _familyNameController.text,
          _parentNameController.text,
          30, // default age for testing
        );
        
        // Add debug print after creation
        print('Parent created with ID: $parentId');
        print('Current User after creation: ${authProvider.currentUser}');
        print('Is Parent after creation: ${authProvider.isParent}');

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        print('Error creating family: $e');  // Add error debug print
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating family: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    bool isParent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_add),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Parent?'),
                value: isParent,
                onChanged: (value) => setState(() => isParent = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _familyMembers.add(FamilyMemberEntry(
                      name: nameController.text,
                      email: '', // Empty for now
                      isParent: isParent,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyMemberEntry {
  final String name;
  final String email;
  final bool isParent;

  FamilyMemberEntry({
    required this.name,
    required this.email,
    required this.isParent,
  });
} 