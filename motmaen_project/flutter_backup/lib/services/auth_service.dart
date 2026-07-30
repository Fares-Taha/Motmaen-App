// services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserIdKey = 'current_user_id';
  
  // Cache variables
  bool? _isLoggedInCache;
  int? _currentUserIdCache;

  Future<bool> isUserLoggedIn() async {
    if (_isLoggedInCache != null) return _isLoggedInCache!;
    
    final prefs = await SharedPreferences.getInstance();
    _isLoggedInCache = prefs.getBool(_isLoggedInKey) ?? false;
    return _isLoggedInCache!;
  }

  Future<void> login(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setInt(_currentUserIdKey, userId);
    
    // Update cache
    _isLoggedInCache = true;
    _currentUserIdCache = userId;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserIdKey);
    
    // Clear cache
    _isLoggedInCache = false;
    _currentUserIdCache = null;
  }

  Future<int?> getCurrentUserId() async {
    if (_currentUserIdCache != null) return _currentUserIdCache;
    
    final prefs = await SharedPreferences.getInstance();
    _currentUserIdCache = prefs.getInt(_currentUserIdKey);
    return _currentUserIdCache;
  }

  // Clear cache method for when switching users
  void clearCache() {
    _isLoggedInCache = null;
    _currentUserIdCache = null;
  }
}