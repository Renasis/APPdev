import 'package:flutter/material.dart';

import '../../../customer/orders/models/order_model.dart';

class SalesData {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  const SalesData({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

class SalesProvider extends ChangeNotifier {
  List<OrderModel> _completedOrders = const [];
  List<SalesData> _sales = const [];

  /// Rebuilds all sales data from the shared order list.
  ///
  /// This deliberately replaces the previous snapshot rather than adding to it,
  /// so a Provider rebuild can never double-count an order.
  void updateFromOrders(List<OrderModel> orders) {
    final completedOrders = orders
        .where((order) => order.status == 'Completed')
        .toList(growable: false);

    final salesByProduct = <String, SalesData>{};

    for (final order in completedOrders) {
      for (final item in order.items) {
        if (item.isPcBuild) {
          final productId = item.product.id;
          final existing = salesByProduct[productId];
          salesByProduct[productId] = SalesData(
            productId: productId,
            productName: item.displayName,
            quantitySold: (existing?.quantitySold ?? 0) + item.quantity,
            revenue: (existing?.revenue ?? 0) + item.totalPrice,
          );
          continue;
        }
        final productId = item.product.id;
        final existing = salesByProduct[productId];

        salesByProduct[productId] = SalesData(
          productId: productId,
          productName: item.product.name,
          quantitySold: (existing?.quantitySold ?? 0) + item.quantity,
          revenue: (existing?.revenue ?? 0) + item.totalPrice,
        );
      }
    }

    _completedOrders = List.unmodifiable(completedOrders);
    _sales = List.unmodifiable(salesByProduct.values);

    notifyListeners();
  }

  List<OrderModel> get completedOrders => _completedOrders;
  List<SalesData> get sales => _sales;

  int get totalOrders => _completedOrders.length;

  int get totalUnitsSold =>
      _sales.fold(0, (sum, sale) => sum + sale.quantitySold);

  double get totalRevenue =>
      _completedOrders.fold(0, (sum, order) => sum + order.totalAmount);

  List<OrderModel> get todayOrders {
    final now = DateTime.now();

    return _completedOrders.where((order) {
      final date = order.orderDate;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList(growable: false);
  }

  double get todaySales =>
      todayOrders.fold(0, (sum, order) => sum + order.totalAmount);

  List<OrderModel> get monthlyOrders {
    final now = DateTime.now();

    return _completedOrders.where((order) {
      final date = order.orderDate;
      return date.year == now.year && date.month == now.month;
    }).toList(growable: false);
  }

  double get monthlyRevenue =>
      monthlyOrders.fold(0, (sum, order) => sum + order.totalAmount);

  int get monthlyUnitsSold => monthlyOrders.fold(
        0,
        (sum, order) => sum +
            order.items.fold(0, (itemSum, item) => itemSum + item.quantity),
      );

  double get averageOrderValue =>
      totalOrders == 0 ? 0 : totalRevenue / totalOrders;

  SalesData get bestSellingProduct {
    if (_sales.isEmpty) {
      return const SalesData(
        productId: '',
        productName: 'No sales yet',
        quantitySold: 0,
        revenue: 0,
      );
    }

    return _sales.reduce(
      (current, next) {
        if (next.quantitySold > current.quantitySold) return next;
        if (next.quantitySold == current.quantitySold &&
            next.revenue > current.revenue) {
          return next;
        }
        return current;
      },
    );
  }

  String get topProduct => bestSellingProduct.productName;
}
