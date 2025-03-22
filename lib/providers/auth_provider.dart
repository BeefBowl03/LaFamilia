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
  Future<void> createFamilyAndFirstParent(String familyName, String parentName) async {
    final familyId = _uuid.v4();
    final userId = _uuid.v4();

    // Create parent user
    final parent = User(
      id: userId,
      name: parentName,
      role: UserRole.parent,
      familyId: familyId,
    );

    // Create family
    final family = Family(
      id: familyId,
      name: familyName,
      memberIds: [userId],
      createdBy: userId,
    );

    // Save data
    await _dataService.saveUser(parent);
    await _dataService.saveFamily(family);
    await _dataService.setCurrentUserId(userId);

    // Update state
    _currentUser = parent;
    _currentFamily = family;
    notifyListeners();
  }

  // Add a new family member
  Future<void> addFamilyMember(String name, UserRole role) async {
    // Ensure there's a current family
    if (_currentFamily == null) return;

    final userId = _uuid.v4();
    
    // Create new user
    final newUser = User(
      id: userId,
      name: name,
      role: role,
      familyId: _currentFamily!.id,
    );

    // Update family members
    final updatedMemberIds = [..._currentFamily!.memberIds, userId];
    final updatedFamily = _currentFamily!.copyWith(memberIds: updatedMemberIds);

    // Save data
    await _dataService.saveUser(newUser);
    await _dataService.saveFamily(updatedFamily);

    // Update state
    _currentFamily = updatedFamily;
    notifyListeners();
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
  Future<bool> login(String name, String familyId, UserRole role) async {
    try {
      // Get all users in the family
      final familyMembers = await _dataService.getAllFamilyMembers(familyId);
      
      // Find user with matching name and role
      final user = familyMembers.firstWhere(
        (member) => 
          member.name.toLowerCase() == name.toLowerCase() &&
          member.role == role,
        orElse: () => throw 'User not found or role mismatch',
      );

      // Set current user and family
      _currentUser = user;
      _currentFamily = await _dataService.getFamily(familyId);
      
      // Save current user ID
      await _dataService.setCurrentUserId(user.id);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}