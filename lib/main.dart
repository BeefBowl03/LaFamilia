import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'providers/notification_provider.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final databaseService = DatabaseService();
  
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  
  const MyApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const FamilyTaskApp(),
    );
  }
}

class FamilyTaskApp extends StatefulWidget {
  const FamilyTaskApp({super.key});

  @override
  FamilyTaskAppState createState() => FamilyTaskAppState();
}

class FamilyTaskAppState extends State<FamilyTaskApp> {
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.initializeApp();
    
    setState(() {
      _isInitialized = true;
      _isAuthenticated = isAuthenticated;
    });

    if (isAuthenticated) {
      // Load data for the current user
      final user = authProvider.currentUser!;
      final family = authProvider.currentFamily!;
      
      // Load tasks
      await Provider.of<TaskProvider>(context, listen: false).loadUserTasks(user.id);
      
      // Load shopping list
      await Provider.of<ShoppingListProvider>(context, listen: false).loadShoppingList(family.id);
      
      // Load notifications
      await Provider.of<NotificationProvider>(context, listen: false).loadNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Task Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _isInitialized
          ? _isAuthenticated
              ? const HomeScreen()
              : const WelcomeScreen()
          : const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Family Task Manager',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}