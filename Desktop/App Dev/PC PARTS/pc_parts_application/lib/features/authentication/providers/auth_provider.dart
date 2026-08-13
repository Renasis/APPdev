import 'package:flutter/material.dart';

import '../models/auth_user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isGuest = true;

  AuthUserModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  AuthUserModel? get currentUser => _currentUser;

  void continueAsGuest() {
    _isGuest = true;
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  void login(AuthUserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    _isGuest = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _isGuest = true;
    notifyListeners();
  }
}