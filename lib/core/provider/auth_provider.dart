import 'package:flutter/material.dart';
import 'package:smartops/core/local_storage/auth_storage.dart';
import 'package:smartops/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  String get role => (_user?['role'] ?? '').toString();

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
  bool get isClient => role == 'client';

  String get userName => (_user?['name'] ?? 'User').toString();
  String get userEmail => (_user?['email'] ?? '').toString();

  Future<void> loadAuthData() async {
    _token = await AuthStorage.getToken();
    _user = await AuthStorage.getUser();

    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (!isAuthenticated) return;

    final data = await AuthService.getMe();
    final freshUser = data['user'] ?? data['data'] ?? data;

    if (freshUser is Map<String, dynamic>) {
      _user = freshUser;
      await AuthStorage.saveUser(freshUser);
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final data = await AuthService.login(
        email: email,
        password: password,
      );

      final token = data['token'] as String;
      final user = Map<String, dynamic>.from(data['user']);

      await AuthStorage.saveAuthData(
        token: token,
        user: user,
      );

      _token = token;
      _user = user;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await AuthService.register(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await AuthStorage.clearAuthData();

    _token = null;
    _user = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}