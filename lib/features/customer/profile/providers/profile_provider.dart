import 'package:flutter/material.dart';

import '../../../authentication/services/user_service.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../models/customer_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    UserService? userService,
    AuthProvider? authProvider,
  })  : _userService = userService,
        _authProvider = authProvider {
    _loadProfile();
  }

  final UserService? _userService;
  final AuthProvider? _authProvider;

  CustomerModel _customer = CustomerModel(
    id: '',
    fullName: '',
    email: '',
    phoneNumber: '',
  );

  CustomerModel get customer => _customer;

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loadProfile() async {
    final auth = _authProvider;
    if (auth == null || !auth.isLoggedIn || auth.currentUser == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uid = auth.currentUser!.id;
      final data = await _userService?.fetchUser(uid);

      if (data == null) {
        _customer = CustomerModel(
          id: uid,
          fullName: auth.currentUser!.fullName,
          email: auth.currentUser!.email,
          phoneNumber: data?['phone'] as String? ?? auth.currentUser!.phone,
        );
      } else {
        _customer = CustomerModel(
          id: uid,
          fullName: data['name'] as String? ?? auth.currentUser!.fullName,
          email: data['email'] as String? ?? auth.currentUser!.email,
          phoneNumber: data['phone'] as String? ?? auth.currentUser!.phone,
        );
      }

      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final auth = _authProvider;
    if (auth == null || !auth.isLoggedIn || auth.currentUser == null) {
      return;
    }

    try {
      final uid = auth.currentUser!.id;
      await _userService?.updateUserProfile(uid, {
        'name': fullName,
        'email': email,
        'phone': phoneNumber,
      });

      _customer = CustomerModel(
        id: _customer.id,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to update profile.';
    }

    notifyListeners();
  }
}