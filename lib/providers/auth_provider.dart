import 'package:flutter/material.dart';
import 'package:menstrual_health_ai/services/auth_service.dart';
import 'package:menstrual_health_ai/models/user_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserAuth? get currentUser => _authService.currentUser;
  bool get isLoading => _authService.isLoading;
  String? get error => _authService.error;
  bool get isAuthenticated => _authService.isAuthenticated;
  
  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _authService.register(
      name: name,
      email: email,
      password: password,
    );
  }
  
  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
    );
  }
  
  // Logout user
  Future<void> logout() async {
    await _authService.logout();
  }
  
  // Verify email
  Future<bool> verifyEmail(String email, String token) async {
    return await _authService.verifyEmail(email, token);
  }
  
  // Resend verification code
  Future<bool> resendVerificationCode(String email) async {
    return await _authService.resendVerificationCode(email);
  }
  
  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    return await _authService.requestPasswordReset(email);
  }
  
  // Reset password
  Future<bool> resetPassword(String email, String token, String newPassword) async {
    return await _authService.resetPassword(email, token, newPassword);
  }
  
  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    return await _authService.changePassword(currentPassword, newPassword);
  }
  
  // Update user profile
  Future<bool> updateProfile({
    required String name,
    String? email,
  }) async {
    return await _authService.updateProfile(
      name: name,
      email: email,
    );
  }
  
  // Delete account
  Future<bool> deleteAccount(String password) async {
    return await _authService.deleteAccount(password);
  }
}
