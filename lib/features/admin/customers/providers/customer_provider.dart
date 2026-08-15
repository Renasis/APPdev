import 'dart:async';

import 'package:flutter/material.dart';

import '../../../authentication/services/user_service.dart';
import '../../../customer/orders/providers/order_provider.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  int totalOrders;
  double totalSpent;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.totalOrders = 0,
    this.totalSpent = 0,
  });

  factory Customer.fromUser(Map<String, dynamic> data, String uid) {
    return Customer(
      id: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  CustomerProvider({
    UserService? userService,
    OrderProvider? orderProvider,
  })  : _userService = userService,
        _orderProvider = orderProvider {
    if (_userService == null) {
      return;
    }

    _subscription = _userService!.watchCustomers().listen(
      _onCustomers,
      onError: _onError,
    );

    if (_orderProvider != null) {
      _orderProvider!.orders;
      _orderProvider!.addListener(_recomputeStats);
    }
  }

  UserService? _userService;
  OrderProvider? _orderProvider;

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  final List<Customer> _customers = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Customer> get customers => List.unmodifiable(_customers);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalCustomerRevenue {
    return _customers.fold(0, (sum, customer) => sum + customer.totalSpent);
  }

  int get totalCustomerOrders {
    return _customers.fold(0, (sum, customer) => sum + customer.totalOrders);
  }

  void _onCustomers(List<Map<String, dynamic>> users) {
    _customers
      ..clear()
      ..addAll(users.map((data) => Customer.fromUser(data, data['uid'] as String)));
    _recomputeStats();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = 'Could not load customers.';
    notifyListeners();
  }

  void _recomputeStats() {
    final orders = _orderProvider?.orders ?? const [];

    for (final customer in _customers) {
      final customerOrders = orders.where((order) {
        return order.customerName.toLowerCase() == customer.name.toLowerCase() ||
            order.customerName.toLowerCase() == customer.email.toLowerCase();
      }).toList();

      customer.totalOrders = customerOrders.length;
      customer.totalSpent = customerOrders.fold(0, (sum, order) => sum + order.totalAmount);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_orderProvider != null) {
      _orderProvider!.removeListener(_recomputeStats);
    }
    super.dispose();
  }
}
