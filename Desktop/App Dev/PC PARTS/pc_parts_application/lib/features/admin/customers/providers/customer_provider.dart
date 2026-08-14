import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalOrders;
  final double totalSpent;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
  });
}

class CustomerProvider extends ChangeNotifier {
  final List<Customer> _customers = [
    Customer(
      id: '1',
      name: 'John Dela Cruz',
      email: 'john@gmail.com',
      phone: '09171234567',
      totalOrders: 12,
      totalSpent: 45000,
    ),

    Customer(
      id: '2',
      name: 'Maria Santos',
      email: 'maria@gmail.com',
      phone: '09181234567',
      totalOrders: 5,
      totalSpent: 18000,
    ),

    Customer(
      id: '3',
      name: 'Joshua Customer',
      email: 'joshua@gmail.com',
      phone: '09991234567',
      totalOrders: 8,
      totalSpent: 32000,
    ),
  ];

  double get totalCustomerRevenue {
      return _customers.fold(
        0,
        (sum, customer) =>
            sum + customer.totalSpent,
      );
    }

    int get totalCustomerOrders {
      return _customers.fold(
        0,
        (sum, customer) =>
            sum + customer.totalOrders,
      );
    }

  List<Customer> get customers =>
      _customers;
}