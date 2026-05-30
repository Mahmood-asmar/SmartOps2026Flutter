import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _resetEmailKey = 'resetEmail';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) {
      return null;
    }

    return jsonDecode(userString) as Map<String, dynamic>;
  }

  static Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await saveToken(token);
    await saveUser(user);
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<void> saveResetEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resetEmailKey, email);
  }

  static Future<String?> getResetEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_resetEmailKey);
  }

  static Future<void> clearResetEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resetEmailKey);
  }
}