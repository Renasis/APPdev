import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'package:pc_parts_application/core/enums/user_role.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._userService) {
    _currentUser = _authService.currentUser;
    _isGuest = _currentUser == null;
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthService _authService;
  final UserService _userService;

  StreamSubscription<AuthUserModel?>? _authSubscription;

  AuthUserModel? _currentUser;
  UserRole? _role;
  bool _isGuest = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get currentUser => _currentUser;
  UserRole? get role => _role;
  bool get isAdmin => _role == UserRole.admin;
  bool get isStaff => _role == UserRole.staff;

  bool hasRole(UserRole role) => _role == role;

  void continueAsGuest() {
    _isGuest = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _run(() async {
      final user = await _authService.signIn(email: email, password: password);
      await _loadUserRole(user.id);
      return user;
    });
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _run(() async {
      final user = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      await _userService.createUser(
        uid: user.id,
        name: fullName.trim(),
        email: email.trim(),
        role: UserRole.customer,
      );

      _role = UserRole.customer;
      return user;
    });
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
    _role = null;
    _isGuest = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadUserRole(String uid) async {
    final role = await _userService.fetchUserRole(uid);
    _role = role;
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
      _currentUser = AuthUserModel(
        id: user.id,
        fullName: user.fullName.isEmpty ? existing.fullName : user.fullName,
        email: user.email.isEmpty ? existing.email : user.email,
        phone: user.phone.isEmpty ? existing.phone : user.phone,
        role: existing.role,
      );
    } else {
      _currentUser = user;
    }

    _isGuest = _currentUser == null;

    if (_currentUser != null) {
      unawaited(_loadUserRole(_currentUser!.id));
    } else {
      _role = null;
    }

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
