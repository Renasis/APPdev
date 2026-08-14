import 'package:flutter/material.dart';

class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
  });
}

class SupplierProvider extends ChangeNotifier {
  final List<Supplier> _suppliers = [
    Supplier(
      id: '1',
      name: 'TechSource PH',
      contactPerson: 'Juan Dela Cruz',
      phone: '09123456789',
      email: 'techsource@gmail.com',
      address: 'Quezon City',
    ),
  ];

  List<Supplier> get suppliers =>
      _suppliers;

  void addSupplier(
    Supplier supplier,
  ) {
    _suppliers.add(supplier);
    notifyListeners();
  }

  void updateSupplier(
    Supplier supplier,
  ) {
    final index =
        _suppliers.indexWhere(
      (s) => s.id == supplier.id,
    );

    if (index != -1) {
      _suppliers[index] = supplier;
      notifyListeners();
    }
  }

  void deleteSupplier(
    String id,
  ) {
    _suppliers.removeWhere(
      (s) => s.id == id,
    );

    notifyListeners();
  }
}