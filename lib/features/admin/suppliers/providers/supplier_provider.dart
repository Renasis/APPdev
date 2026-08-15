import 'dart:async';

import 'package:flutter/material.dart';

import '../models/supplier.dart';
import '../repository/supplier_repository.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProvider({SupplierRepository? repository})
      : _repository = repository {
    if (repository == null) {
      return;
    }

    _subscription = repository.watchSuppliers().listen(
      _onSuppliers,
      onError: _onError,
    );
  }

  final SupplierRepository? _repository;

  StreamSubscription<List<Supplier>>? _subscription;

  final List<Supplier> _suppliers = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onSuppliers(List<Supplier> suppliers) {
    _suppliers
      ..clear()
      ..addAll(suppliers);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = 'Could not load suppliers.';
    notifyListeners();
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _repository?.createSupplier(supplier);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to add supplier.';
    }

    notifyListeners();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _repository?.updateSupplier(supplier);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to update supplier.';
    }

    notifyListeners();
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _repository?.deleteSupplier(id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to delete supplier.';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
