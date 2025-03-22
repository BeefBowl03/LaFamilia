import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

class CreateTaskScreen extends StatefulWidget {
  final bool isParent;

  const CreateTaskScreen({
    super.key,
    required this.isParent,
  });

  @override
  CreateTaskScreenState createState() => CreateTaskScreenState();
}

class CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _dueTime = TimeOfDay.now();
  TaskCategory _category = TaskCategory.other;
  TaskPriority _priority = TaskPriority.medium;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  String? _assignedToUserId;
  bool _isLoading = false;
  List<User> _familyMembers = [];

  // Task categories
  final List<String> _categories = [
    'Homework',
    'Chores',
    'Errands',
    'School',
    'Activities',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final members = await authProvider.getFamilyMembers();
      
      setState(() {
        _familyMembers = members;
        // Select current user by default
        if (authProvider.currentUser != null) {
          _assignedToUserId = authProvider.currentUser!.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading family members: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      final task = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: dueDateTime,
        assignedToId: _assignedToUserId ?? authProvider.currentUser!.id,
        assignedByParentId: authProvider.currentUser!.id,
        assignedToUserId: _assignedToUserId ?? authProvider.currentUser!.id,
        familyId: authProvider.currentFamily!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
        priority: _priority,
        category: _category,
        recurrence: _recurrence,
        createdBy: authProvider.currentUser!.id,
      );

      await taskProvider.createTask(task);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Add these debug prints
    print('Current user role: ${authProvider.currentUser?.role}');
    print('Is parent from widget: ${widget.isParent}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title field - available to all
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field - available to all
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Due date - available to all
              InkWell(
                onTap: () => _selectDate(),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dueDate != null
                        ? DateFormat('MMM d, yyyy').format(_dueDate!)
                        : 'Select Due Date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Parent-only fields
              if (widget.isParent) ...[
                // Assigned to field
                DropdownButtonFormField<String>(
                  value: _assignedToUserId ?? authProvider.currentUser!.id,
                  decoration: const InputDecoration(
                    labelText: 'Assign To',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ..._familyMembers.map((member) => DropdownMenuItem(
                      value: member.id,
                      child: Text(member.name),
                    )),
                  ],
                  onChanged: (value) => setState(() => _assignedToUserId = value),
                ),
                const SizedBox(height: 16),
                
                // Category field
                DropdownButtonFormField<TaskCategory>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Recurrence field
                DropdownButtonFormField<TaskRecurrence>(
                  value: _recurrence,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskRecurrence.values.map((recurrence) => DropdownMenuItem(
                    value: recurrence,
                    child: Text(recurrence.toString().split('.').last),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _recurrence = value);
                    }
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}