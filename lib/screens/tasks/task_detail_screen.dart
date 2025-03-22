import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  TaskDetailScreenState createState() => TaskDetailScreenState();
}

class TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _toggleTaskCompletion() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await taskProvider.toggleTaskCompletion(_task);
      setState(() {
        _task = _task.copyWith(isCompleted: !_task.isCompleted);
      });

      // If a child completes a task, notify the parent
      if (!_task.isCompleted && !authProvider.isParent) {
        // Find the parent user ID
        final family = authProvider.currentFamily;
        if (family != null) {
          final parentId = family.createdBy;
          final currentUser = authProvider.currentUser;
          
          if (currentUser != null && parentId != currentUser.id) {
            await notificationProvider.createTaskCompletedNotification(
              taskTitle: _task.title,
              completedByName: currentUser.name,
              forParentId: parentId,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        await taskProvider.deleteTask(_task);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting task: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isParent = authProvider.isParent;
    
    // Get color based on priority
    Color priorityColor;
    switch (_task.priority) {
      case TaskPriority.high:
        priorityColor = AppTheme.dangerColor;
        break;
      case TaskPriority.medium:
        priorityColor = AppTheme.warningColor;
        break;
      case TaskPriority.low:
        priorityColor = AppTheme.successColor;
        break;
    }

    // Format dates
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDueDate = dateFormat.format(_task.dueDate);

    // Check if the task is overdue
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(_task.dueDate.year, _task.dueDate.month, _task.dueDate.day);
    final isOverdue = dueDate.isBefore(today) && !_task.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (isParent && !_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task status indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _task.isCompleted
                              ? AppTheme.successColor.withOpacity(0.2)
                              : isOverdue
                                  ? AppTheme.dangerColor.withOpacity(0.2)
                                  : AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _task.isCompleted
                              ? 'COMPLETED'
                              : isOverdue
                                  ? 'OVERDUE'
                                  : 'PENDING',
                          style: TextStyle(
                            color: _task.isCompleted
                                ? AppTheme.successColor
                                : isOverdue
                                    ? AppTheme.dangerColor
                                    : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _task.priority.name.toUpperCase() + ' PRIORITY',
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Task title
                  Text(
                    _task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: _task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _task.category,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Due date section
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    title: 'Due Date',
                    value: formattedDueDate,
                    valueColor: isOverdue ? AppTheme.dangerColor : null,
                  ),
                  const SizedBox(height: 16),

                  // Assignee section
                  _buildInfoRow(
                    icon: Icons.person,
                    title: 'Assigned To',
                    value: 'Looking up...', // Would be replaced with actual user name lookup
                  ),
                  const SizedBox(height: 16),

                  // Created by section
                  _buildInfoRow(
                    icon: Icons.assignment_ind,
                    title: 'Created By',
                    value: 'Looking up...', // Would be replaced with actual user name lookup
                  ),
                  const SizedBox(height: 32),

                  // Description section
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerTheme.color ?? Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _task.description.isNotEmpty ? _task.description : 'No description provided.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _task.description.isEmpty
                            ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5)
                            : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _isDeleting
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mark as complete/incomplete button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleTaskCompletion,
                      icon: Icon(_task.isCompleted ? Icons.refresh : Icons.check_circle),
                      label: Text(_task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _task.isCompleted ? Colors.grey : AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  // Edit button - only visible to parents
                  if (isParent) ...[  
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Would navigate to edit task screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit task functionality would be implemented here')),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}