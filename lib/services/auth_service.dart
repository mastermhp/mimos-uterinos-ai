import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:menstrual_health_ai/models/user_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  UserAuth? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  UserAuth? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      
      // Check if user already exists
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        _error = 'Email already in use';
        return false;
      }
      
      // Generate salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      
      // Generate verification token
      final verificationToken = _generateVerificationToken();
      
      // Create new user
      final user = UserAuth(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        hashedPassword: hashedPassword,
        salt: salt,
        isVerified: false,
        verificationToken: verificationToken,
        createdAt: DateTime.now(),
      );
      
      // Save user to storage
      await _saveUser(user);
      
      // In a real app, send verification email here
      if (kDebugMode) {
        print('Verification token: $verificationToken');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      
      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        _error = 'User not found';
        return false;
      }
      
      // Verify password
      final hashedPassword = _hashPassword(password, user.salt);
      if (hashedPassword != user.hashedPassword) {
        _error = 'Invalid password';
        return false;
      }
      
      // Check if user is verified
      if (!user.isVerified) {
        _error = 'Email not verified';
        return false;
      }
      
      // Set current user
      _currentUser = user;
      
      // Save auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('current_user_id', user.id);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', false);
    await prefs.remove('current_user_id');
  }
  
  // Verify email
  Future<bool> verifyEmail(String email, String token) async {
    try {
      _isLoading = true;
      _error = null;
      
      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        _error = 'User not found';
        return false;
      }
      
      // Verify token
      if (user.verificationToken != token) {
        _error = 'Invalid verification token';
        return false;
      }
      
      // Update user verification status
      final updatedUser = user.copyWith(
        isVerified: true,
        verificationToken: null,
      );
      
      // Save updated user
      await _saveUser(updatedUser);
      
      // Set current user
      _currentUser = updatedUser;
      
      // Save auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('current_user_id', updatedUser.id);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Resend verification code
  Future<bool> resendVerificationCode(String email) async {
    try {
      _isLoading = true;
      _error = null;
      
      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        _error = 'User not found';
        return false;
      }
      
      // Generate new verification token
      final verificationToken = _generateVerificationToken();
      
      // Update user verification token
      final updatedUser = user.copyWith(
        verificationToken: verificationToken,
      );
      
      // Save updated user
      await _saveUser(updatedUser);
      
      // In a real app, send verification email here
      if (kDebugMode) {
        print('New verification token: $verificationToken');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      _isLoading = true;
      _error = null;
      
      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        _error = 'User not found';
        return false;
      }
      
      // Generate reset token
      final resetToken = _generateVerificationToken();
      
      // Update user reset token
      final updatedUser = user.copyWith(
        resetToken: resetToken,
        resetTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      );
      
      // Save updated user
      await _saveUser(updatedUser);
      
      // In a real app, send reset email here
      if (kDebugMode) {
        print('Reset token: $resetToken');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email, String token, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      
      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        _error = 'User not found';
        return false;
      }
      
      // Verify token
      if (user.resetToken != token) {
        _error = 'Invalid reset token';
        return false;
      }
      
      // Check token expiry
      if (user.resetTokenExpiry == null || 
          user.resetTokenExpiry!.isBefore(DateTime.now())) {
        _error = 'Reset token expired';
        return false;
      }
      
      // Generate new salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);
      
      // Update user password
      final updatedUser = user.copyWith(
        hashedPassword: hashedPassword,
        salt: salt,
        resetToken: null,
        resetTokenExpiry: null,
      );
      
      // Save updated user
      await _saveUser(updatedUser);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      
      if (_currentUser == null) {
        _error = 'Not authenticated';
        return false;
      }
      
      // Verify current password
      final hashedCurrentPassword = _hashPassword(
        currentPassword, 
        _currentUser!.salt,
      );
      
      if (hashedCurrentPassword != _currentUser!.hashedPassword) {
        _error = 'Current password is incorrect';
        return false;
      }
      
      // Generate new salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);
      
      // Update user password
      final updatedUser = _currentUser!.copyWith(
        hashedPassword: hashedPassword,
        salt: salt,
      );
      
      // Save updated user
      await _saveUser(updatedUser);
      
      // Update current user
      _currentUser = updatedUser;
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({
    required String name,
    String? email,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      
      if (_currentUser == null) {
        _error = 'Not authenticated';
        return false;
      }
      
      // Check if email is being changed
      if (email != null && email != _currentUser!.email) {
        // Check if new email is already in use
        final existingUser = await _getUserByEmail(email);
        if (existingUser != null) {
          _error = 'Email already in use';
          return false;
        }
      }
      
      // Update user profile
      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email ?? _currentUser!.email,
      );
      
      // Save updated user
      await _saveUser(updatedUser);
      
      // Update current user
      _currentUser = updatedUser;
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _isLoading = true;
      _error = null;
      
      if (_currentUser == null) {
        _error = 'Not authenticated';
        return false;
      }
      
      // Verify password
      final hashedPassword = _hashPassword(
        password, 
        _currentUser!.salt,
      );
      
      if (hashedPassword != _currentUser!.hashedPassword) {
        _error = 'Password is incorrect';
        return false;
      }
      
      // Delete user
      await _deleteUser(_currentUser!.id);
      
      // Clear auth state
      await logout();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Check if user is authenticated
  Future<bool> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      if (!isAuthenticated) {
        return false;
      }
      
      final userId = prefs.getString('current_user_id');
      if (userId == null) {
        return false;
      }
      
      final user = await _getUserById(userId);
      if (user == null) {
        return false;
      }
      
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Helper methods
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
  
  String _hashPassword(String password, String salt) {
    final codec = Utf8Codec();
    final key = codec.encode(password);
    final saltBytes = base64Decode(salt);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(saltBytes);
    return digest.toString();
  }
  
  String _generateVerificationToken() {
    final random = Random.secure();
    // Generate a 6-digit verification code
    final tokenBytes = List<int>.generate(6, (_) => random.nextInt(10));
    return tokenBytes.join();
  }
  
  Future<UserAuth?> _getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) {
      return null;
    }
    
    final users = jsonDecode(usersJson) as Map<String, dynamic>;
    
    for (final user in users.values) {
      final userObj = UserAuth.fromJson(user);
      if (userObj.email.toLowerCase() == email.toLowerCase()) {
        return userObj;
      }
    }
    
    return null;
  }
  
  Future<UserAuth?> _getUserById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) {
      return null;
    }
    
    final users = jsonDecode(usersJson) as Map<String, dynamic>;
    
    if (users.containsKey(id)) {
      return UserAuth.fromJson(users[id]);
    }
    
    return null;
  }
  
  Future<void> _saveUser(UserAuth user) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> users = {};
    
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      users = jsonDecode(usersJson) as Map<String, dynamic>;
    }
    
    users[user.id] = user.toJson();
    
    await prefs.setString('users', jsonEncode(users));
  }
  
  Future<void> _deleteUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) {
      return;
    }
    
    final users = jsonDecode(usersJson) as Map<String, dynamic>;
    
    users.remove(id);
    
    await prefs.setString('users', jsonEncode(users));
  }
}
