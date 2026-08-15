import 'dart:async';

import 'package:flutter/material.dart';

import '../repository/purchase_order_repository.dart';

export '../repository/purchase_order_repository.dart';

class PurchaseOrderProvider extends ChangeNotifier {
  PurchaseOrderProvider({PurchaseOrderRepository? repository})
      : _repository = repository {
    if (repository == null) {
      return;
    }

    _subscription = repository.watchPurchaseOrders().listen(
      _onPurchaseOrders,
      onError: _onError,
    );
  }

  final PurchaseOrderRepository? _repository;

  StreamSubscription<List<PurchaseOrder>>? _subscription;

  final List<PurchaseOrder> _purchaseOrders = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<PurchaseOrder> get purchaseOrders => List.unmodifiable(_purchaseOrders);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onPurchaseOrders(List<PurchaseOrder> orders) {
    _purchaseOrders
      ..clear()
      ..addAll(orders);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = 'Could not load purchase orders.';
    notifyListeners();
  }

  Future<void> addPurchaseOrder(PurchaseOrder order) async {
    try {
      await _repository?.createPurchaseOrder(order);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to create purchase order.';
    }

    notifyListeners();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final index = _purchaseOrders.indexWhere((order) => order.id == id);
    if (index == -1) return;

    final currentStatus = _purchaseOrders[index].status;

    const allowedTransitions = {
      'Draft': 'Submitted',
      'Submitted': 'Approved',
      'Approved': 'Ordered',
      'Ordered': 'Received',
      'Received': 'Completed',
    };

    if (allowedTransitions[currentStatus] != newStatus) {
      return;
    }

    try {
      await _repository?.updatePurchaseOrderStatus(id, newStatus);
      _purchaseOrders[index] = PurchaseOrder(
        id: _purchaseOrders[index].id,
        supplierName: _purchaseOrders[index].supplierName,
        status: newStatus,
        items: _purchaseOrders[index].items,
        createdAt: _purchaseOrders[index].createdAt,
      );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to update purchase order status.';
    }

    notifyListeners();
  }

  Future<void> deletePurchaseOrder(String id) async {
    try {
      await _repository?.deletePurchaseOrder(id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to delete purchase order.';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
