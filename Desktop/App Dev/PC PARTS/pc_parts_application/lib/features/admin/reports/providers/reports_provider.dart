import 'package:flutter/material.dart';

class ReportsProvider extends ChangeNotifier {
  double totalRevenue = 0;
  int totalOrders = 0;
  int totalCustomers = 0;

  String highestRevenueProduct = 'RTX 4060';
  String lowestStockProduct = 'Ryzen 7 7800X3D';

  double totalPurchaseOrderValue = 157992;
  double inventoryValue = 289980;

  final List<Map<String, dynamic>> monthlySales = [
    {'month': 'Jan', 'sales': 18000},
    {'month': 'Feb', 'sales': 22000},
    {'month': 'Mar', 'sales': 25000},
    {'month': 'Apr', 'sales': 28000},
    {'month': 'May', 'sales': 32000},
    {'month': 'Jun', 'sales': 35000},
  ];

  void updateMetrics({
    required double revenue,
    required int orders,
    required int customers,
  }) {
    totalRevenue = revenue;
    totalOrders = orders;
    totalCustomers = customers;

    notifyListeners();
  }

  void updateBusinessInsights({
    required String topRevenueProduct,
    required String lowStockProduct,
    required double purchaseOrderAmount,
    required double totalInventoryValue,
  }) {
    highestRevenueProduct = topRevenueProduct;
    lowestStockProduct = lowStockProduct;
    totalPurchaseOrderValue = purchaseOrderAmount;
    inventoryValue = totalInventoryValue;

    notifyListeners();
  }


  
}