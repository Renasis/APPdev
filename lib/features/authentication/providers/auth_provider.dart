import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/auth_user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

import 'package:pc_parts_application/core/enums/user_role.dart';
import 'package:pc_parts_application/features/admin/staff/services/staff_account_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._authService,
    this._userService,
    this._staffAccountService,
  ) {
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthService _authService;
  final UserService _userService;
  final StaffAccountService _staffAccountService;

  StreamSubscription<AuthUserModel?>? _authSubscription;
  StreamSubscription<Map<String, dynamic>?>? _userDocumentSubscription;

  AuthUserModel? _currentUser;
  UserRole? _role;

  bool _isGuest = true;
  bool _isLoading = false;
  String? _errorMessage;

  Stream<AuthUserModel?> get authStateChanges => _authService.authStateChanges;

  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get currentUser => _currentUser;
  UserRole? get role => _role;

  bool get isAdmin => _role == UserRole.admin;
  bool get isStaff => _role == UserRole.staff;
  bool get isCustomer => _role == UserRole.customer;

  bool hasRole(UserRole role) => _role == role;

  void continueAsGuest() {
    _isGuest = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      await _loadUserRole(user.id);

      // Make sure the user has a valid Firestore profile.
      if (_role == null) {
        throw const AuthException(
          'Your account profile could not be found.',
        );
      }

      // Check whether the account is active.
      final isActive = await _userService.isActive(user.id);

      if (!isActive) {
        await _authService.signOut();

        throw const AuthException(
          'Your staff account is currently inactive. Please contact your administrator.',
        );
      }

      return AuthUserModel(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        role: _role!,
        isActive: true,
      );
    });
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _run(() async {
      final normalizedEmail = email.trim().toLowerCase();

      /*
       * STEP 1
       *
       * Create the Firebase Authentication account first.
       * The user is signed in immediately after registration,
       * which allows Firestore security rules to grant access
       * to the staff invitation document tied to this email.
       */
      final user = await _authService.register(
        fullName: fullName,
        email: normalizedEmail,
        phone: phone,
        password: password,
      );

      /*
       * Ensure the auth token is fully propagated to Firestore security
       * rules before performing any Firestore writes. This is especially
       * important on web where token propagation can lag behind account
       * creation.
       */
      await _authService.ensureTokenFresh();

      /*
       * STEP 2
       *
       * Check whether the email belongs to a pending staff invitation.
       *
       * If an invitation exists:
       *     this registration becomes STAFF.
       *
       * If no invitation exists:
       *     this registration becomes CUSTOMER.
       */
      final staffInvitation =
          await _staffAccountService.fetchPendingInvitation(
        normalizedEmail,
      );

      /*
       * STEP 3
       *
       * STAFF REGISTRATION
       */
      if (staffInvitation != null) {
        await _staffAccountService.activateStaffAccount(
          uid: user.id,
          email: normalizedEmail,
        );

        _role = UserRole.staff;

        return AuthUserModel(
          id: user.id,
          fullName: fullName.trim(),
          email: normalizedEmail,
          phone: phone.trim(),
          role: UserRole.staff,
        );
      }

      /*
       * STEP 4
       *
       * NORMAL CUSTOMER REGISTRATION
       */
      try {
        await _userService.createUser(
          uid: user.id,
          name: fullName.trim(),
          email: normalizedEmail,
          role: UserRole.customer,
        );
      } catch (error) {
        await _authService.signOut();
        throw const AuthException(
          'Failed to create profile. Please try again.',
        );
      }

      _role = UserRole.customer;

      return AuthUserModel(
        id: user.id,
        fullName: fullName.trim(),
        email: normalizedEmail,
        phone: phone.trim(),
        role: UserRole.customer,
      );
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
    _userDocumentSubscription?.cancel();
    _userDocumentSubscription = null;

    notifyListeners();
  }

  Future<void> _loadUserRole(String uid) async {
    final role = await _userService.fetchUserRole(uid);
    _role = role;
    notifyListeners();
  }

  void _listenToUserDocument(String uid) {
    _userDocumentSubscription?.cancel();
    _userDocumentSubscription = _userService.watchUser(uid).listen(
      (data) {
        if (data == null || _currentUser == null || _currentUser!.id != uid) {
          return;
        }

        final isActive = data['isActive'] as bool? ?? true;
        final role = data['role'] as String?;

        if (!isActive) {
          _authService.signOut();
          _currentUser = null;
          _role = null;
          _isGuest = true;
          _errorMessage = 'Your staff account is currently inactive. Please contact your administrator.';
          notifyListeners();
        } else if (role != null && _role?.name != role) {
          final newRole = UserRole.values.firstWhere(
            (e) => e.name == role,
            orElse: () => UserRole.customer,
          );
          _role = newRole;
          _currentUser = AuthUserModel(
            id: _currentUser!.id,
            fullName: _currentUser!.fullName,
            email: _currentUser!.email,
            phone: _currentUser!.phone,
            role: newRole,
            isActive: true,
          );
          notifyListeners();
        }
      },
    );
  }

  Future<bool> _run(
    Future<AuthUserModel> Function() action,
  ) async {
    _setLoading(true);

    try {
      _currentUser = await action();

      _isGuest = false;
      _errorMessage = null;

      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } on FirebaseException catch (error) {
      _errorMessage =
          error.message ?? 'Something went wrong. Please try again.';

      return false;
    } catch (error) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _onAuthStateChanged(AuthUserModel? user) {
    if (user == null && _currentUser == null) {
      return;
    }

    if (user != null) {
      _currentUser = user;
      _isGuest = true;
      _errorMessage = null;
      notifyListeners();

      unawaited(_validateAndLoadUserState(user.id));
      return;
    }

    _currentUser = null;
    _role = null;
    _isGuest = true;
    _errorMessage = null;
    _userDocumentSubscription?.cancel();
    _userDocumentSubscription = null;

    notifyListeners();
  }

  Future<void> _validateAndLoadUserState(String uid) async {
    final isActive = await _userService.isActive(uid);
    if (!isActive) {
      await _authService.signOut();
      _currentUser = null;
      _role = null;
      _isGuest = true;
      _errorMessage = 'Your staff account is currently inactive. Please contact your administrator.';
      _userDocumentSubscription?.cancel();
      _userDocumentSubscription = null;
      notifyListeners();
      return;
    }

    await _loadUserRole(uid);

    if (_currentUser != null && _currentUser!.id == uid) {
      _currentUser = AuthUserModel(
        id: _currentUser!.id,
        fullName: _currentUser!.fullName,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        role: _role ?? _currentUser!.role,
        isActive: true,
      );
      _isGuest = false;
      _listenToUserDocument(uid);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocumentSubscription?.cancel();
    super.dispose();
  }
}