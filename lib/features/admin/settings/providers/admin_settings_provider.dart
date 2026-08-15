import 'package:flutter/material.dart';

import '../models/admin_settings_model.dart';
import '../../../authentication/services/user_service.dart';
import '../../../authentication/providers/auth_provider.dart';

class AdminSettingsProvider extends ChangeNotifier {
  AdminSettingsProvider({
    UserService? userService,
    AuthProvider? authProvider,
  })  : _userService = userService,
        _authProvider = authProvider {
    _loadSettings();
  }

  final UserService? _userService;
  final AuthProvider? _authProvider;

  AdminSettings _settings = AdminSettings(
    storeName: 'End PC Parts',
    email: '',
    phone: '',
    address: '',
    currency: 'PHP',
    notificationsEnabled: true,
  );

  AdminSettings get settings => _settings;

  Future<void> _loadSettings() async {
    final auth = _authProvider;
    if (auth == null || !auth.isLoggedIn || auth.currentUser == null) {
      return;
    }

    final uid = auth.currentUser!.id;
    final userData = await _userService?.fetchUser(uid);

    if (userData == null) {
      return;
    }

    _settings = AdminSettings(
      storeName: userData['storeName'] as String? ?? _settings.storeName,
      email: userData['email'] as String? ?? auth.currentUser?.email ?? _settings.email,
      phone: userData['phone'] as String? ?? _settings.phone,
      address: userData['address'] as String? ?? _settings.address,
      currency: userData['currency'] as String? ?? _settings.currency,
      notificationsEnabled: userData['notificationsEnabled'] as bool? ?? _settings.notificationsEnabled,
    );

    notifyListeners();
  }

  Future<void> updateSettings({
    required String storeName,
    required String email,
    required String phone,
    required String address,
    required String currency,
    required bool notificationsEnabled,
  }) async {
    final auth = _authProvider;
    if (auth == null || !auth.isLoggedIn || auth.currentUser == null) {
      return;
    }

    final uid = auth.currentUser!.id;

    await _userService?.updateUserProfile(uid, {
      'storeName': storeName,
      'email': email,
      'phone': phone,
      'address': address,
      'currency': currency,
      'notificationsEnabled': notificationsEnabled,
    });

    _settings = AdminSettings(
      storeName: storeName,
      email: email,
      phone: phone,
      address: address,
      currency: currency,
      notificationsEnabled: notificationsEnabled,
    );

    notifyListeners();
  }
}
