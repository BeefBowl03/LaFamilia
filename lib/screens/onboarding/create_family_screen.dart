import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  CreateFamilyScreenState createState() => CreateFamilyScreenState();
}

class CreateFamilyScreenState extends State<CreateFamilyScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();

  bool _isCreating = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _parentNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.createFamilyAndFirstParent(
        _familyNameController.text.trim(),
        _parentNameController.text.trim(),
      );

      // Navigate to home screen after family is created
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Family'),
        elevation: 0,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Illustration
                      Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.home,
                              size: 80,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        'Welcome! Let\'s set up your family',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your family group and you\'ll be the admin parent. You can add other family members later.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Family Name
                      Text(
                        'Family Name',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _familyNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your family name',
                          prefixIcon: const Icon(Icons.family_restroom),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your family name';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Parent Name
                      Text(
                        'Your Name (Parent)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _parentNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _createFamily(),
                      ),
                      const SizedBox(height: 40),
                      
                      // Create Family Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isCreating ? null : _createFamily,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isCreating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Family',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}