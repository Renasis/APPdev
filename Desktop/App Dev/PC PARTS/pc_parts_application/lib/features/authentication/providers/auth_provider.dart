import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _currentUser = _authService.currentUser;
    _isGuest = _currentUser == null;
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthService _authService;

  StreamSubscription<AuthUserModel?>? _authSubscription;

  AuthUserModel? _currentUser;
  bool _isGuest = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get currentUser => _currentUser;

  void continueAsGuest() {
    _isGuest = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _run(
      () => _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      ),
    );
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _isGuest = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<AuthUserModel> Function() action) async {
    _setLoading(true);
    try {
      _currentUser = await action();
      _isGuest = false;
      _errorMessage = null;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _onAuthStateChanged(AuthUserModel? user) {
    if (user == null && _currentUser == null) {
      return;
    }

    final existing = _currentUser;
    if (user != null && existing != null && existing.id == user.id) {
      // Firebase only stores the display name, so keep the richer local model.
      _currentUser = AuthUserModel(
        id: user.id,
        fullName: user.fullName.isEmpty ? existing.fullName : user.fullName,
        email: user.email.isEmpty ? existing.email : user.email,
        phone: user.phone.isEmpty ? existing.phone : user.phone,
      );
    } else {
      _currentUser = user;
    }

    _isGuest = _currentUser == null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
