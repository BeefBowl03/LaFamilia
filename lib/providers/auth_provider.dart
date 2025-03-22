import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/family_model.dart';
import '../services/data_service.dart';

class AuthProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final Uuid _uuid = Uuid();
  
  User? _currentUser;
  Family? _currentFamily;
  List<User> _familyMembers = [];

  User? get currentUser => _currentUser;
  Family? get currentFamily => _currentFamily;
  bool get isAuthenticated => _currentUser != null;
  bool get isParent => _currentUser?.role == UserRole.parent;

  // Initialize from local storage
  Future<bool> initializeApp() async {
    await _dataService.init();
    
    final currentUserId = _dataService.getCurrentUserId();
    if (currentUserId != null) {
      _currentUser = _dataService.getUser(currentUserId);
      if (_currentUser != null) {
        _currentFamily = _dataService.getFamily(_currentUser!.familyId);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Create a new family and the first parent user
  Future<void> createFamilyAndFirstParent(String familyName, String parentName, int parentAge) async {
    // Implementation
  }

  // Add a new family member
  Future<void> addFamilyMember(String name, int age, bool isParent, String familyId) async {
    // Implementation
  }

  // Switch the current user (for testing and demo purposes)
  Future<void> switchUser(String userId) async {
    final user = _dataService.getUser(userId);
    if (user != null) {
      _currentUser = user;
      _currentFamily = _dataService.getFamily(user.familyId);
      await _dataService.setCurrentUserId(userId);
      notifyListeners();
    }
  }

  // Get all family members
  Future<List<User>> getFamilyMembers() async {
    if (_currentFamily == null) return [];
    return await _dataService.getAllFamilyMembers(_currentFamily!.id);
  }

  // Logout
  Future<void> logout() async {
    await _dataService.clearCurrentUser();
    _currentUser = null;
    _currentFamily = null;
    notifyListeners();
  }

  // Check if this is the first launch (no families exist)
  Future<bool> isFirstLaunch() async {
    await _dataService.init();
    return _dataService.getCurrentUserId() == null;
  }

  // Login with name, family ID, and role
  Future<bool> login(String email, String password) async {
    // Implementation
    return false; // or true based on login success
  }

  List<User> get familyMembers => _familyMembers;
}