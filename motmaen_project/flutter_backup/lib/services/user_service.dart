// services/user_service.dart - FIXED
import 'package:motmaen/models/user_profile.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/services/auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserProfile? _currentUser;
  
  UserProfile? get currentUser => _currentUser;

  Future<void> loadCurrentUser() async {
    _currentUser = await getCurrentUser();
  }

  Future<UserProfile?> getCurrentUser() async {
    // First check if we have a cached user
    if (_currentUser != null) return _currentUser;
    
    // Get the current user ID from AuthService
    final authService = AuthService();
    final currentUserId = await authService.getCurrentUserId();
    
    if (currentUserId == null) {
      _currentUser = null;
      return null;
    }
    
    // Fetch the user by ID from database
    try {
      final user = await DatabaseHelper().getUserById(currentUserId);
      _currentUser = user;
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      _currentUser = null;
      return null;
    }
  }

  Future<bool> updateUserProfile(UserProfile updatedUser) async {
    try {
      final result = await DatabaseHelper().updateUser(updatedUser);
      if (result > 0) {
        _currentUser = updatedUser;
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<void> refreshUser() async {
    // Clear cache and reload
    _currentUser = null;
    await loadCurrentUser();
  }

  void clearUserData() {
    _currentUser = null;
  }

  // Get user by email (for login)
  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      return await DatabaseHelper().getUser(email);
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Check if email exists
  Future<bool> doesEmailExist(String email) async {
    try {
      return await DatabaseHelper().doesEmailExist(email);
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  // Create new user
  Future<int?> createUser(UserProfile user) async {
    try {
      return await DatabaseHelper().insertUser(user);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Get current user ID
  Future<int?> getCurrentUserId() async {
    final authService = AuthService();
    return await authService.getCurrentUserId();
  }
}