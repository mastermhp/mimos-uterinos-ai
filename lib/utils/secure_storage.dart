import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  // Use secure storage for mobile platforms, shared preferences for web
  final bool _useSecureStorage = !kIsWeb;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<void> write(String key, String value) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.write(key: key, value: value);
      } catch (e) {
        // Fallback to shared preferences if secure storage fails
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      }
    } else {
      // Use shared preferences for web
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }
  
  Future<String?> read(String key) async {
    if (_useSecureStorage) {
      try {
        return await _secureStorage.read(key: key);
      } catch (e) {
        // Fallback to shared preferences if secure storage fails
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      }
    } else {
      // Use shared preferences for web
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }
  
  Future<void> delete(String key) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.delete(key: key);
      } catch (e) {
        // Fallback to shared preferences if secure storage fails
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      }
    } else {
      // Use shared preferences for web
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }
  
  Future<void> deleteAll() async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.deleteAll();
      } catch (e) {
        // Fallback to shared preferences if secure storage fails
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } else {
      // Use shared preferences for web
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}
