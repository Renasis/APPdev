import 'package:flutter/material.dart';

import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final List<AddressModel> _addresses = [];

  List<AddressModel> get addresses => _addresses;

  void addAddress(AddressModel address) {
    if (_addresses.isEmpty) {
      address.isDefault = true;
    }

    _addresses.add(address);

    notifyListeners();
  }

  void updateAddress(AddressModel updatedAddress) {
    final index = _addresses.indexWhere(
      (address) => address.id == updatedAddress.id,
    );

    if (index != -1) {
      _addresses[index] = updatedAddress;
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
  final wasDefault = _addresses.any(
    (address) =>
        address.id == id &&
        address.isDefault,
  );

  _addresses.removeWhere(
    (address) => address.id == id,
  );

  if (wasDefault &&
      _addresses.isNotEmpty) {
    _addresses.first.isDefault = true;
  }

  notifyListeners();
}

  void setDefaultAddress(String id) {
    for (final address in _addresses) {
      address.isDefault = false;
    }

    final index = _addresses.indexWhere(
      (address) => address.id == id,
    );

    if (index != -1) {
      _addresses[index].isDefault = true;
    }

    notifyListeners();
  }

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere(
        (address) => address.isDefault,
      );
    } catch (_) {
      return null;
    }
  }
}