import 'package:flutter/material.dart';

import '../models/customer_model.dart';

class ProfileProvider extends ChangeNotifier {
  CustomerModel _customer = CustomerModel(
    id: '1',
    fullName: 'Joshua Lascano',
    email: 'joshua@email.com',
    phoneNumber: '09123456789',
  );

  CustomerModel get customer => _customer;

  void updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) {
    _customer = CustomerModel(
      id: _customer.id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );

    notifyListeners();
  }
}