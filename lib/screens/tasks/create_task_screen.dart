import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

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
        id: '', // Will be set by the provider
        familyId: authProvider.currentFamily!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        priority: _priority,
        dueDate: dueDateTime,
        recurrence: _recurrence,
        createdByUserId: authProvider.currentUser!.id,
        assignedToUserId: _assignedToUserId ?? authProvider.currentUser!.id,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
    final familyMembers = authProvider.familyMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _createTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Due Date & Time
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_dueTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<TaskCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Priority
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Recurrence
              DropdownButtonFormField<TaskRecurrence>(
                value: _recurrence,
                decoration: const InputDecoration(
                  labelText: 'Recurrence',
                  border: OutlineInputBorder(),
                ),
                items: TaskRecurrence.values.map((recurrence) {
                  return DropdownMenuItem(
                    value: recurrence,
                    child: Text(recurrence.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recurrence = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Assign To
              if (familyMembers.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _assignedToUserId ?? authProvider.currentUser!.id,
                  decoration: const InputDecoration(
                    labelText: 'Assign To',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ...familyMembers.map((member) {
                      return DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _assignedToUserId = value);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}