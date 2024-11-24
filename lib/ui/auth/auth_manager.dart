import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  User? _loggedInUser;

  AuthManager() {
    _authService = AuthService(onAuthChange: (User? user) {
      _loggedInUser = user;
      notifyListeners();
    });
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  String get currentUserId {
    return _loggedInUser?.id ?? ''; 
  }

  Future<bool> isEmailExist(String email) async {
    return await _authService.isEmailExist(email);
  }

  Future<void> updateAvatar(File avatar, User user) async {
    return _authService.updateAvatar(avatar, user);
  }

  Future<User> signup(Map<String, dynamic> authData) {
    return _authService.signup(authData);
  }

  Future<User> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (_loggedInUser != null) {
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    return _authService.logout();
  }

  Future<User> getUserInfo() async {
    return await _authService.getUserInfo();
  }

  Future<User> getUserInfoById(String userId) async {
    return await _authService.getUserInfoById(userId);
  }

  Future<User> updateUserInfo(Map<String, dynamic> authData) async {
    return _authService.updateUserInfo(authData);
  }
}
