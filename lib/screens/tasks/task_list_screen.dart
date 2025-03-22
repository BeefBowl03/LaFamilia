import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'create_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  ViewType _currentView = ViewType.daily;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (authProvider.isParent) {
        await taskProvider.loadAllFamilyTasks(authProvider.currentFamily!.id);
      } else {
        await taskProvider.loadUserTasks(authProvider.currentUser!.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // View type toggle
          PopupMenuButton<ViewType>(
            icon: Icon(
              _currentView == ViewType.daily
                  ? Icons.view_day
                  : _currentView == ViewType.weekly
                      ? Icons.view_week
                      : Icons.calendar_month,
            ),
            onSelected: (ViewType type) {
              setState(() => _currentView = type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ViewType.daily,
                child: Text('Daily View'),
              ),
              const PopupMenuItem(
                value: ViewType.weekly,
                child: Text('Weekly View'),
              ),
              const PopupMenuItem(
                value: ViewType.monthly,
                child: Text('Monthly View'),
              ),
            ],
          ),
          // Filter by category
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCategoryFilter,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: _buildTaskList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          ).then((_) => _loadTasks());
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = _getTasksForCurrentView(taskProvider);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for this view',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        taskProvider.reorderTasks(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, index);
      },
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    final Color categoryColor = _getCategoryColor(task.category);
    
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Delete task
          Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
        } else {
          // Complete task
          Provider.of<TaskProvider>(context, listen: false)
              .toggleTaskCompletion(task.id);
        }
      },
      child: Card(
        key: Key(task.id),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          leading: Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            '${task.category.name} • Due ${_formatDate(task.dueDate)}',
            style: TextStyle(
              color: _isOverdue(task) ? Colors.red : null,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.recurrence != TaskRecurrence.none)
                Icon(
                  Icons.repeat,
                  size: 20,
                  color: Colors.grey[600],
                ),
              const SizedBox(width: 8),
              Icon(
                _getPriorityIcon(task.priority),
                color: _getPriorityColor(task.priority),
                size: 20,
              ),
            ],
          ),
          onTap: () => _showTaskDetails(task),
        ),
      ),
    );
  }

  List<Task> _getTasksForCurrentView(TaskProvider provider) {
    switch (_currentView) {
      case ViewType.daily:
        return provider.getTasksDueToday();
      case ViewType.weekly:
        return provider.getTasksDueThisWeek();
      case ViewType.monthly:
        return provider.getTasksDueThisMonth();
    }
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => CategoryFilterSheet(
        onCategorySelected: (category) {
          Provider.of<TaskProvider>(context, listen: false)
              .setSelectedCategory(category);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTaskDetails(Task task) {
    // TODO: Implement task details view
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.school:
        return Colors.blue;
      case TaskCategory.chores:
        return Colors.green;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.arrow_downward;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  bool _isOverdue(Task task) {
    if (task.isCompleted) return false;
    final now = DateTime.now();
    return task.dueDate.isBefore(now);
  }
}

enum ViewType {
  daily,
  weekly,
  monthly,
}

class CategoryFilterSheet extends StatelessWidget {
  final Function(TaskCategory?) onCategorySelected;

  const CategoryFilterSheet({
    super.key,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('All Categories'),
            onTap: () => onCategorySelected(null),
          ),
          ...TaskCategory.values.map((category) => ListTile(
                leading: Icon(
                  category == TaskCategory.school
                      ? Icons.school
                      : category == TaskCategory.chores
                          ? Icons.home
                          : category == TaskCategory.health
                              ? Icons.favorite
                              : Icons.more_horiz,
                  color: _getCategoryColor(category),
                ),
                title: Text(category.name),
                onTap: () => onCategorySelected(category),
              )),
        ],
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.school:
        return Colors.blue;
      case TaskCategory.chores:
        return Colors.green;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.other:
        return Colors.grey;
    }
  }
} 