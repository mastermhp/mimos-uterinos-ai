import 'dart:convert';
import 'package:menstrual_health_ai/models/user_auth.dart';
import 'package:menstrual_health_ai/utils/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  final SecureStorage _secureStorage = SecureStorage();
  final String _usersKey = 'auth_users';
  final String _currentUserKey = 'current_user';
  
  // Save users to storage
  Future<void> saveUsers(List<UserAuth> users) async {
    final usersJson = users.map((user) => user.toJson()).toList();
    await _secureStorage.write(_usersKey, jsonEncode(usersJson));
  }
  
  // Get users from storage
  Future<List<UserAuth>> getUsers() async {
    final usersJson = await _secureStorage.read(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(usersJson);
      return decoded.map((json) => UserAuth.fromJson(json)).toList();
    } catch (e) {
      // If secure storage fails, try shared preferences as fallback
      final prefs = await SharedPreferences.getInstance();
      final fallbackJson = prefs.getString(_usersKey);
      if (fallbackJson == null || fallbackJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(fallbackJson);
      return decoded.map((json) => UserAuth.fromJson(json)).toList();
    }
  }
  
  // Save current user
  Future<void> saveCurrentUser(UserAuth user) async {
    await _secureStorage.write(_currentUserKey, jsonEncode(user.toJson()));
  }
  
  // Get current user
  Future<UserAuth?> getCurrentUser() async {
    final userJson = await _secureStorage.read(_currentUserKey);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    
    try {
      return UserAuth.fromJson(jsonDecode(userJson));
    } catch (e) {
      // If secure storage fails, try shared preferences as fallback
      final prefs = await SharedPreferences.getInstance();
      final fallbackJson = prefs.getString(_currentUserKey);
      if (fallbackJson == null || fallbackJson.isEmpty) {
        return null;
      }
      
      return UserAuth.fromJson(jsonDecode(fallbackJson));
    }
  }
  
  // Clear current user
  Future<void> clearCurrentUser() async {
    await _secureStorage.delete(_currentUserKey);
  }
}
