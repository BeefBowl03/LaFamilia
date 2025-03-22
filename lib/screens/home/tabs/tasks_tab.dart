import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/task_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../theme/app_theme.dart';
import '../../tasks/create_task_screen.dart';
import '../../tasks/task_detail_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  TasksTabState createState() => TasksTabState();
}

class TasksTabState extends State<TasksTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        // If parent, load all family tasks, otherwise load only user's tasks
        if (authProvider.isParent) {
          await taskProvider.loadAllFamilyTasks(authProvider.currentFamily!.id);
        } else {
          await taskProvider.loadUserTasks(authProvider.currentUser!.id);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: loadTasks,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.0, color: AppTheme.primaryColor),
                      insets: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    tabs: const [
                      Tab(text: 'Today'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(
                        taskProvider.getTasksDueToday()..addAll(taskProvider.getOverdueTasks()),
                        'today',
                      ),
                      _buildTaskList(taskProvider.getUpcomingTasks(), 'upcoming'),
                      _buildTaskList(taskProvider.getTasksByCompletion(true), 'completed'),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildTaskList(List<Task> tasks, String listType) {
    if (tasks.isEmpty) {
      return _buildEmptyState(listType);
    }

    // Sort tasks based on due date and priority
    tasks.sort((a, b) {
      // For completed tasks, sort by most recently completed
      if (listType == 'completed') {
        return b.dueDate.compareTo(a.dueDate);
      }
      
      // First sort by due date
      final dateComparison = a.dueDate.compareTo(b.dueDate);
      if (dateComparison != 0) return dateComparison;
      
      // Then by priority (high -> medium -> low)
      return a.priority.index.compareTo(b.priority.index);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index]);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    // Get color based on priority
    Color priorityColor;
    switch (task.priority) {
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

    // Format the due date
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(task.dueDate);

    // Check if the task is overdue
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    final isOverdue = dueDate.isBefore(today) && !task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
            ).then((_) => loadTasks());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox for task completion
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (bool? value) async {
                      await taskProvider.toggleTaskCompletion(task);
                      
                      // If a child completes a task, notify the parent
                      if (value == true && !authProvider.isParent) {
                        // Find the parent user ID
                        final family = authProvider.currentFamily;
                        if (family != null) {
                          final parentId = family.createdBy;
                          final currentUser = authProvider.currentUser;
                          
                          if (currentUser != null && parentId != currentUser.id) {
                            await notificationProvider.createTaskCompletedNotification(
                              taskTitle: task.title,
                              completedByName: currentUser.name,
                              forParentId: parentId,
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Priority indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              task.priority.name.toUpperCase(),
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              task.category.toString(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Task title
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7)
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Due date with overdue indicator
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? AppTheme.dangerColor : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? AppTheme.dangerColor : Colors.grey,
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isOverdue) ...[  
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.dangerColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: AppTheme.dangerColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow for navigation
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String listType) {
    IconData icon;
    String title;
    String message;

    switch (listType) {
      case 'today':
        icon = Icons.calendar_today;
        title = 'No Tasks For Today';
        message = 'You don\'t have any tasks due today.';
        break;
      case 'upcoming':
        icon = Icons.upcoming;
        title = 'No Upcoming Tasks';
        message = 'You don\'t have any upcoming tasks.';
        break;
      case 'completed':
        icon = Icons.check_circle_outline;
        title = 'No Completed Tasks';
        message = 'You haven\'t completed any tasks yet.';
        break;
      default:
        icon = Icons.task_alt;
        title = 'No Tasks';
        message = 'You don\'t have any tasks.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}