// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:my_quiz/models/users.dart'; // Import model User Anda
import 'package:my_quiz/services/users_service.dart'; // Import UserService Anda

class UserProvider with ChangeNotifier {
  User? _loggedInUser;
  bool _isLoggedIn = false;
  bool _isLoadingAuth = true;

  User? get loggedInUser => _loggedInUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoadingAuth => _isLoadingAuth;

  final UserService _userService = UserService();

  UserProvider() {
    _checkLoginStatus();
  }
  
  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await _userService.checkLoginStatus();
    if (_isLoggedIn) {
      final userId = await _userService.getLoggedInUserId();
      if (userId != null) {
        _loggedInUser = await _userService.getUserById(userId);
        _isLoggedIn = (_loggedInUser != null);
      } else {
        _isLoggedIn = false;
      }
    }
    _isLoadingAuth = false;
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoadingAuth = true;
    notifyListeners();

    final user = await _userService.registerUser(username, email, password);
    _isLoadingAuth = false;
    notifyListeners();

    return user != null;
  }

  Future<bool> login(String identifier, String password) async {
    _isLoadingAuth = true;
    notifyListeners();

    _loggedInUser = await _userService.loginUser(identifier, password);
    _isLoggedIn = (_loggedInUser != null);
    _isLoadingAuth = false;
    notifyListeners();

    return _isLoggedIn;
  }

  Future<void> logout() async {
    await _userService.logoutUser();
    _loggedInUser = null;
    _isLoggedIn = false;
    notifyListeners();
    // Navigasi logout akan ditangani oleh widget yang memanggilnya, biasanya di main.dart
  }

  Future<bool> updateProfile(int id, {String? username, String? email, String? password}) async {
    bool success = await _userService.updateUser(id, username: username, email: email, password: password);
    if (success) {
      // Jika update di backend berhasil, update juga data di provider
      if (_loggedInUser != null) {
        _loggedInUser = User(
          id: _loggedInUser!.id,
          username: username ?? _loggedInUser!.username,
          email: email ?? _loggedInUser!.email,
          createdAt: _loggedInUser!.createdAt,
          updatedAt: DateTime.now(), // Update timestamp
        );
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> deleteAccount() async {
    if (_loggedInUser == null) return false;
    bool success = await _userService.deleteUser(_loggedInUser!.id);
    if (success) {
      await logout(); // Logout setelah akun dihapus
    }
    return success;
  }

  getUsers() {}
}