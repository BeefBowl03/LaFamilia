import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../notifications/notification_screen.dart';
import '../tasks/create_task_screen.dart';
import '../auth/login_screen.dart';
import '../family/add_family_member_screen.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/shopping_list_tab.dart';
import 'tabs/family_tab.dart';
import 'tabs/settings_tab.dart';
import '../shopping/create_shopping_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    TasksTab(key: GlobalKey<TasksTabState>()),
    const ShoppingListTab(), 
    const FamilyTab(),
    const SettingsTab(),
  ];

  final List<String> _tabTitles = [
    'Tasks',
    'Shopping List',
    'Family',
    'Settings',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeTransition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();

    // Initialize by loading the current user's data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.loadNotifications(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final unreadCount = notificationProvider.unreadCount;
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Add debug print to check conditions
    print('Current Index: $_currentIndex');
    print('Is Parent: ${authProvider.isParent}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        elevation: 0,
        actions: [
          // Show logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && mounted) {
                Provider.of<AuthProvider>(context, listen: false).logout();
                // Navigation will be handled by the Consumer in main.dart
              }
            },
          ),
          if (_currentIndex == 0) // Show notification icon only on Tasks tab
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeTransition,
        child: _tabs[_currentIndex],
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Shopping',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Enhanced debug prints
    print('Building FAB:');
    print('Current Index: $_currentIndex');
    print('Is Parent: ${authProvider.isParent}');
    print('Current User: ${authProvider.currentUser}');
    print('User Role: ${authProvider.currentUser?.role}');
    
    // Only show FAB for parent users
    if (!authProvider.isParent) {
        print('FAB not shown: User is not a parent');
        print('Current User Details: ${authProvider.currentUser?.toString()}');
        return null;
    }

    switch (_currentIndex) {
      case 0: // Tasks tab
        print('Showing Tasks FAB');
        return FloatingActionButton(
          onPressed: () {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTaskScreen(
                  isParent: authProvider.currentUser?.role == UserRole.parent,
                ),
              ),
            ).then((_) {
              // Refresh tasks after creating a new one
              if (_tabs[0] is TasksTab) {
                final tasksTab = _tabs[0] as TasksTab;
                final state = (tasksTab.key as GlobalKey<TasksTabState>).currentState;
                if (state != null) {
                  state.loadTasks();
                }
              }
            });
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
          tooltip: 'Add Task',
        );
        
      case 1: // Shopping tab
        // Only show shopping FAB for parents
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateShoppingItemScreen()),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add_shopping_cart),
          tooltip: 'Add Shopping Item',
        );
        
      case 2: // Family tab
        // Only show family member FAB for parents
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddFamilyMemberScreen()),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.person_add),
          tooltip: 'Add Family Member',
        );
        
      default:
        return null;
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Tasks';
      case 1:
        return 'Shopping List';
      case 2:
        return 'Family';
      case 3:
        return 'Settings';
      default:
        return 'Family Task Management';
    }
  }
}