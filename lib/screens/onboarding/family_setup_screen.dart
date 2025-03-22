import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../onboarding/add_family_member_dialog.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  FamilySetupScreenState createState() => FamilySetupScreenState();
}

class FamilySetupScreenState extends State<FamilySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Family Info
  final _familyNameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentAgeController = TextEditingController();

  // Family Members
  final List<Map<String, dynamic>> _familyMembers = [];

  @override
  void dispose() {
    _familyNameController.dispose();
    _parentNameController.dispose();
    _parentAgeController.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.createFamilyAndFirstParent(
        _familyNameController.text,
        _parentNameController.text,
        int.parse(_parentAgeController.text),
      );

      // Add other family members
      for (final member in _familyMembers) {
        await authProvider.addFamilyMember(
          member['name'],
          int.parse(member['age']),
          member['isParent'] ? UserRole.parent : UserRole.child,
        );
      }

      if (mounted) {
        // Navigate to home screen and remove all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating family: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addFamilyMember() {
    showDialog(
      context: context,
      builder: (context) => AddFamilyMemberDialog(
        onAdd: (name, age, role, responsibilities) {
          setState(() {
            _familyMembers.add({
              'name': name,
              'age': age,
              'isParent': role == UserRole.parent,
              'responsibilities': responsibilities,
            });
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Family'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _createFamily();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            // Step 1: Family Info
            Step(
              title: const Text('Family Information'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _familyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Family Name',
                      hintText: 'Enter your family name',
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
                      hintText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _parentAgeController,
                    decoration: const InputDecoration(
                      labelText: 'Your Age',
                      hintText: 'Enter your age',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            // Step 2: Add Family Members
            Step(
              title: const Text('Family Members'),
              content: Column(
                children: [
                  ..._familyMembers.map((member) => ListTile(
                    title: Text(member['name']),
                    subtitle: Text('${member['age']} years old - ${member['isParent'] ? 'Parent' : 'Child'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _familyMembers.remove(member);
                        });
                      },
                    ),
                  )),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addFamilyMember,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Family Member'),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            // Step 3: Review
            Step(
              title: const Text('Review'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Family Name: ${_familyNameController.text}'),
                  const SizedBox(height: 8),
                  Text('Parent: ${_parentNameController.text}'),
                  const SizedBox(height: 16),
                  const Text('Family Members:'),
                  ..._familyMembers.map((member) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text('${member['name']} (${member['age']} years)'),
                  )),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
} 