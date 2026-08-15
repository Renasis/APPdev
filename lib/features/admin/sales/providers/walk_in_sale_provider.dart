import 'dart:async';

import 'package:flutter/material.dart';

import '../models/walk_in_sale_model.dart';
import '../repository/walk_in_sale_repository.dart';
import '../../inventory/providers/inventory_provider.dart';

class WalkInSaleProvider extends ChangeNotifier {
  WalkInSaleProvider({
    WalkInSaleRepository? repository,
  }) : _repository = repository {
    if (repository == null) {
      return;
    }

    _subscription = repository.watchSales().listen(_onSales);
  }

  final WalkInSaleRepository? _repository;
  InventoryProvider? _inventoryProvider;

  StreamSubscription<List<WalkInSale>>? _subscription;

  final List<WalkInSaleItem> _items = [];
  String _customerName = 'Walk-in Customer';
  String _contactNumber = '';
  String _paymentMethod = 'Cash';

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<WalkInSaleItem> get items => List.unmodifiable(_items);
  String get customerName => _customerName;
  String get contactNumber => _contactNumber;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  void setInventoryProvider(InventoryProvider inventoryProvider) {
    _inventoryProvider = inventoryProvider;
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setContactNumber(String number) {
    _contactNumber = number;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void addItem(WalkInSaleItem item) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      _items[existingIndex] = WalkInSaleItem(
        productId: item.productId,
        productName: item.productName,
        quantity: _items[existingIndex].quantity + item.quantity,
        unitPrice: item.unitPrice,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateItemQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = WalkInSaleItem(
          productId: _items[index].productId,
          productName: _items[index].productName,
          quantity: quantity,
          unitPrice: _items[index].unitPrice,
        );
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _customerName = 'Walk-in Customer';
    _contactNumber = '';
    _paymentMethod = 'Cash';
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> completeSale({
    required String performedByUid,
    required String performedByName,
    required String performedByRole,
  }) async {
    if (_items.isEmpty) {
      _errorMessage = 'Add at least one product to the sale.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final inventory = _inventoryProvider;
      if (inventory == null) {
        _errorMessage = 'Inventory provider not available.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      for (final item in _items) {
        final inventoryItem = inventory.itemById(item.productId);
        if (inventoryItem == null) {
          _errorMessage = 'Product "${item.productName}" not found in inventory.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        if (item.quantity > inventoryItem.stock) {
          _errorMessage = 'Insufficient stock for "${item.productName}". Available: ${inventoryItem.stock}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final saleId = 'WALKIN-${DateTime.now().millisecondsSinceEpoch}';
      final sale = WalkInSale(
        id: saleId,
        customerName: _customerName.trim().isEmpty ? 'Walk-in Customer' : _customerName.trim(),
        contactNumber: _contactNumber.trim(),
        items: List.from(_items),
        totalAmount: subtotal,
        paymentMethod: _paymentMethod,
        performedByUid: performedByUid,
        performedByName: performedByName,
        performedByRole: performedByRole,
        saleDate: DateTime.now(),
        status: 'Completed',
      );

      await _repository?.saveSale(sale);

      for (final item in _items) {
        final previousStock = inventory.itemById(item.productId)?.stock ?? 0;
        final movementId = 'WALKIN-${sale.id}-${item.productId}';
        final success = await inventory.deductStock(
          item.productId,
          item.quantity,
          reason: 'Walk-in Sale',
          notes: 'Sale #${sale.id}',
          movementId: movementId,
        );

        if (!success) {
          _errorMessage = 'Failed to deduct stock for "${item.productName}".';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _successMessage = 'Sale #$saleId completed successfully.';
      _items.clear();
      _customerName = 'Walk-in Customer';
      _contactNumber = '';
      _paymentMethod = 'Cash';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Failed to complete sale: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _onSales(List<WalkInSale> sales) {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
