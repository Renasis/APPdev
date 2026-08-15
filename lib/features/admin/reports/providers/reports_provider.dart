import 'package:flutter/material.dart';

import '../../sales/providers/sales_provider.dart';
import '../../products/providers/admin_product_provider.dart';
import '../../purchase_orders/providers/purchase_order_provider.dart';
import '../../../customer/orders/providers/order_provider.dart';
import '../../../authentication/providers/auth_provider.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider({
    SalesProvider? salesProvider,
    AdminProductProvider? productProvider,
    PurchaseOrderProvider? purchaseOrderProvider,
    OrderProvider? orderProvider,
    AuthProvider? authProvider,
  })  : _salesProvider = salesProvider,
        _productProvider = productProvider,
        _purchaseOrderProvider = purchaseOrderProvider,
        _orderProvider = orderProvider,
        _authProvider = authProvider {
    _salesProvider?.addListener(_onDataChanged);
    _productProvider?.addListener(_onDataChanged);
    _purchaseOrderProvider?.addListener(_onDataChanged);
    _orderProvider?.addListener(_onDataChanged);
    _authProvider?.addListener(_onDataChanged);
    _onDataChanged();
  }

  final SalesProvider? _salesProvider;
  final AdminProductProvider? _productProvider;
  final PurchaseOrderProvider? _purchaseOrderProvider;
  final OrderProvider? _orderProvider;
  final AuthProvider? _authProvider;

  String _highestRevenueProduct = 'No sales yet';
  String _lowestStockProduct = 'No products';
  double _totalPurchaseOrderValue = 0;
  double _inventoryValue = 0;
  final List<Map<String, dynamic>> _monthlySales = [];

  String get highestRevenueProduct => _highestRevenueProduct;
  String get lowestStockProduct => _lowestStockProduct;
  double get totalPurchaseOrderValue => _totalPurchaseOrderValue;
  double get inventoryValue => _inventoryValue;
  List<Map<String, dynamic>> get monthlySales => List.unmodifiable(_monthlySales);

  void _onDataChanged() {
    final sales = _salesProvider;
    final products = _productProvider;
    final purchaseOrders = _purchaseOrderProvider;
    final orders = _orderProvider;

    if (sales != null) {
      final bestSeller = sales.bestSellingProduct;
      _highestRevenueProduct = bestSeller.productName != 'No sales yet'
          ? bestSeller.productName
          : 'No sales yet';
    }

    if (products != null && products.products.isNotEmpty) {
      final critical = products.criticalStockProducts;
      final lowStock = products.lowStockProducts;

      if (critical.isNotEmpty) {
        _lowestStockProduct = critical.first.name;
      } else if (lowStock.isNotEmpty) {
        _lowestStockProduct = lowStock.first.name;
      } else {
        _lowestStockProduct = products.products.first.name;
      }

      _inventoryValue = products.products.fold(
        0,
        (sum, product) => sum + (product.price * product.stock),
      );
    }

    if (purchaseOrders != null) {
      _totalPurchaseOrderValue = purchaseOrders.purchaseOrders.fold(
        0,
        (sum, order) => sum + order.totalAmount,
      );
    }

    if (orders != null && sales != null) {
      final monthlyOrders = sales.monthlyOrders;

      final Map<String, double> aggregated = {};
      for (final order in monthlyOrders) {
        final monthKey = '${order.orderDate.month}/${order.orderDate.year}';
        aggregated[monthKey] = (aggregated[monthKey] ?? 0) + order.totalAmount;
      }

      _monthlySales
        ..clear()
        ..addAll(
          aggregated.entries.map(
            (entry) => {'month': entry.key, 'sales': entry.value},
          ),
        );

      _monthlySales.sort((a, b) {
        final partsA = (a['month'] as String).split('/');
        final partsB = (b['month'] as String).split('/');
        final dateA = DateTime(int.parse(partsB[1]), int.parse(partsB[0]));
        final dateB = DateTime(int.parse(partsA[1]), int.parse(partsA[0]));
        return dateB.compareTo(dateA);
      });
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _salesProvider?.removeListener(_onDataChanged);
    _productProvider?.removeListener(_onDataChanged);
    _purchaseOrderProvider?.removeListener(_onDataChanged);
    _orderProvider?.removeListener(_onDataChanged);
    _authProvider?.removeListener(_onDataChanged);
    super.dispose();
  }
}
