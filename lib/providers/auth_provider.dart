import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/family_model.dart';
import '../services/data_service.dart';

class AuthProvider extends ChangeNotifier {
  late DataService _dataService;
  final Uuid _uuid = Uuid();
  
  User? _currentUser;
  Family? _currentFamily;
  final List<User> _familyMembers = [];

  User? get currentUser => _currentUser;
  Family? get currentFamily => _currentFamily;
  bool get isAuthenticated => _currentUser != null;
  bool get isParent => _currentUser?.role == UserRole.parent;
  String? get familyId => _currentUser?.familyId;

  void setDataService(DataService dataService) {
    _dataService = dataService;
  }

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

  // Create a new family and set the first parent
  Future<String> createFamilyAndFirstParent(
    String familyName,
    String parentName,
    int parentAge,
  ) async {
    final familyId = _uuid.v4();
    final parentId = _uuid.v4();

    final parent = User(
      id: parentId,
      name: parentName,
      email: '$parentName@example.com',
      familyId: familyId,
      role: UserRole.parent,
      age: parentAge,
      isParent: true,
    );

    // Create the family with the parent as the first member
    final family = Family(
      id: familyId,
      name: familyName,
      memberIds: [parentId], // Add the parent as the first member
      createdAt: DateTime.now(),
      createdBy: parentId,
    );

    // Save to DataService
    await _dataService.saveUser(parent);
    await _dataService.saveFamily(family);
    await _dataService.setCurrentUserId(parentId);

    _currentUser = parent;
    _currentFamily = family;
    _familyMembers.add(parent);
    
    notifyListeners();
    return parentId;
  }

  // Add a family member
  Future<String> addFamilyMember(
    String name,
    int age,
    UserRole role,
  ) async {
    if (_currentUser == null || _currentFamily == null) {
      throw Exception('No family exists');
    }

    final memberId = _uuid.v4();
    final member = User(
      id: memberId,
      name: name,
      email: '$name@example.com',
      familyId: _currentUser!.familyId,
      role: role,
      age: age,
      isParent: role == UserRole.parent,
      responsibilities: [],
      createdAt: DateTime.now(),
    );

    // Update family with new member
    final updatedFamily = _currentFamily!.copyWith(
      memberIds: [..._currentFamily!.memberIds, memberId],
    );

    // Save to DataService
    await _dataService.saveUser(member);
    await _dataService.saveFamily(updatedFamily);
    
    _currentFamily = updatedFamily;
    _familyMembers.add(member);
    notifyListeners();
    return memberId;
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
    // Clear DataService
    await _dataService.clearCurrentUser();
    
    _currentUser = null;
    _currentFamily = null;
    _familyMembers.clear();
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

  List<User> get familyMembers => List.unmodifiable(_familyMembers);

  // Add this method for testing
  void setParentStatus(bool isParent) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        role: isParent ? UserRole.parent : UserRole.child,
      );
      notifyListeners();
    }
  }

  // Get family member by ID
  User? getFamilyMember(String id) {
    return _familyMembers.firstWhere(
      (member) => member.id == id,
      orElse: () => throw Exception('Family member not found'),
    );
  }
}