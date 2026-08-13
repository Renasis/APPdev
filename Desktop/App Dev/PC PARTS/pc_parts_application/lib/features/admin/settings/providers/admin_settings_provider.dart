import 'package:flutter/material.dart';

import '../models/admin_settings_model.dart';

class AdminSettingsProvider extends ChangeNotifier {
  AdminSettings _settings = AdminSettings(
    storeName: 'End PC Parts',
    email: 'admin@endpcparts.com',
    phone: '09171234567',
    address: 'Binangonan, Rizal',
    currency: 'PHP',
    notificationsEnabled: true,
  );

  AdminSettings get settings => _settings;

  void updateSettings({
    required String storeName,
    required String email,
    required String phone,
    required String address,
    required String currency,
    required bool notificationsEnabled,
  }) {
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