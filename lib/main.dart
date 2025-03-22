import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dataService = DataService();
  await dataService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..setDataService(dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider()..setDataService(dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => ShoppingListProvider(dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..setDataService(dataService),
        ),
      ],
      child: MaterialApp(
        title: 'Family Task Management',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    ),
  );
}