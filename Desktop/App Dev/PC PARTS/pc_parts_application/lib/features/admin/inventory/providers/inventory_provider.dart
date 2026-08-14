import 'dart:async';

import 'package:flutter/material.dart';

import '../../notifications/providers/notification_provider.dart';
import '../../../customer/orders/models/order_model.dart';
import '../repository/inventory_repository.dart';



class InventoryItem {
  final String id;
  String productName;
  int stock;

  InventoryItem({
    required this.id,
    required this.productName,
    required this.stock,
  });

  String get status {
    if (stock <= 2) {
      return 'Critical';
    }

    if (stock <= 5) {
      return 'Low Stock';
    }

    return 'In Stock';
  }
}

// ========================================
// STOCK MOVEMENT
// ========================================

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String reason;
  final String notes;
  final DateTime date;
  final String type;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    required this.notes,
    required this.date,
    required this.type,
  });
}

class StockShortage {
  final String productName;
  final int requestedQuantity;
  final int availableQuantity;

  const StockShortage({
    required this.productName,
    required this.requestedQuantity,
    required this.availableQuantity,
  });
}



// ========================================
// INVENTORY PROVIDER
// ========================================

class InventoryProvider extends ChangeNotifier {
  /// Without a [repository] the provider keeps its built-in demo stock, which
  /// is what the widget tests rely on. With one, stock and movements come from
  /// Firestore and every change is written back to it.
  InventoryProvider({InventoryRepository? repository})
      : _repository = repository {
    if (repository == null) {
      return;
    }

    _items.clear();
    _movements.clear();

    _itemSubscription = repository.watchItems().listen(_onItems);
    _movementSubscription = repository.watchMovements().listen(_onMovements);
  }

  final InventoryRepository? _repository;

  StreamSubscription<List<InventoryItem>>? _itemSubscription;

  StreamSubscription<List<StockMovement>>? _movementSubscription;

  final List<InventoryItem> _items = [
    InventoryItem(
      id: '1',
      productName: 'RTX 4060',
      stock: 10,
    ),
    InventoryItem(
      id: '2',
      productName: 'Ryzen 7 7800X3D',
      stock: 3,
    ),
    InventoryItem(id: '3', productName: 'Corsair Vengeance 16GB RAM', stock: 20),
    InventoryItem(id: '4', productName: 'MSI B650 Motherboard', stock: 8),
    InventoryItem(id: '5', productName: 'Samsung 1TB SSD', stock: 15),
    InventoryItem(id: 'psu-001', productName: 'Corsair CX650', stock: 10),
    InventoryItem(id: 'case-001', productName: 'NZXT H5 Flow Case', stock: 10),
  ];

  final List<StockMovement> _movements = [
    StockMovement(
      id: 'SM-001',
      productId: '1',
      productName: 'RTX 4060',
      quantity: 2,
      previousStock: 12,
      newStock: 10,
      reason: 'Stock Adjustment',
      notes: 'Initial stock adjustment',
      date: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      type: 'Stock In',
    ),
  ];

  final Set<String> _stockDeductedOrderIds = <String>{};

  NotificationProvider? _notificationProvider;

  bool notificationsEnabled = true;

  void setNotificationsEnabled(bool enabled) {
    if (notificationsEnabled == enabled) {
      return;
    }

    notificationsEnabled = enabled;
    notifyListeners();
  }

  // ========================================
  // NOTIFICATION CONNECTION
  // ========================================

  void setNotificationProvider(
  NotificationProvider provider,
) {
  _notificationProvider = provider;

  for (final item in _items) {
    _checkStockLevel(item);
  }
}

  // ========================================
  // GETTERS
  // ========================================

  List<InventoryItem> get items => _items;

  List<StockMovement> get movements => _movements;

  void _onItems(List<InventoryItem> items) {
    _items
      ..clear()
      ..addAll(items);

    for (final item in _items) {
      _checkStockLevel(item);
    }

    notifyListeners();
  }

  /// Movement ids for order deductions are deterministic
  /// (`ORDER-<orderId>-<productId>`), so the persisted audit trail is what
  /// tells us an order was already deducted after a restart.
  void _onMovements(List<StockMovement> movements) {
    _movements
      ..clear()
      ..addAll(movements);

    for (final movement in movements) {
      if (!movement.id.startsWith('ORDER-')) {
        continue;
      }

      final withoutPrefix = movement.id.substring('ORDER-'.length);
      final separator = withoutPrefix.lastIndexOf('-${movement.productId}');

      if (separator > 0) {
        _stockDeductedOrderIds.add(withoutPrefix.substring(0, separator));
      }
    }

    notifyListeners();
  }

  void _persistItem(InventoryItem item) {
    unawaited(_repository?.saveItem(item) ?? Future<void>.value());
  }

  void _persistMovement(StockMovement movement) {
    unawaited(_repository?.saveMovement(movement) ?? Future<void>.value());
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _movementSubscription?.cancel();
    super.dispose();
  }

  InventoryItem? itemById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  bool addInventoryItem({
    required String id,
    required String productName,
    required int stock,
  }) {
    if (stock < 0 || itemById(id) != null) {
      return false;
    }

    final item = InventoryItem(
      id: id,
      productName: productName,
      stock: stock,
    );
    _items.add(item);
    _persistItem(item);
    _checkStockLevel(item);
    notifyListeners();
    return true;
  }

  void updateInventoryItemName(String id, String productName) {
    final item = itemById(id);
    if (item == null || item.productName == productName) {
      return;
    }

    item.productName = productName;
    _persistItem(item);
    _checkStockLevel(item);
    notifyListeners();
  }

  void removeInventoryItem(String id) {
    final item = itemById(id);
    if (item == null) {
      return;
    }

    _items.remove(item);
    unawaited(_repository?.deleteItem(id) ?? Future<void>.value());
    _notificationProvider?.syncStockLevelNotification(
      productId: id,
      productName: item.productName,
      stock: 6,
    );
    notifyListeners();
  }

  /// Returns every product that prevents [order] from being completed.
  /// Duplicate lines for the same product are combined before checking stock.
  List<StockShortage> stockShortagesForOrder(OrderModel order) {
    final quantitiesByProductId = <String, int>{};
    final productNames = <String, String>{};

    for (final cartItem in order.items.expand((item) => item.stockItems)) {
      final productId = cartItem.product.id;
      quantitiesByProductId[productId] =
          (quantitiesByProductId[productId] ?? 0) + cartItem.quantity;
      productNames[productId] = cartItem.product.name;
    }

    return quantitiesByProductId.entries
        .map((entry) {
          final inventoryItem = _items.cast<InventoryItem?>().firstWhere(
                (item) => item?.id == entry.key,
                orElse: () => null,
              );
          final availableQuantity = inventoryItem?.stock ?? 0;

          if (availableQuantity >= entry.value) {
            return null;
          }

          return StockShortage(
            productName: productNames[entry.key] ?? entry.key,
            requestedQuantity: entry.value,
            availableQuantity: availableQuantity,
          );
        })
        .whereType<StockShortage>()
        .toList(growable: false);
  }

  // ========================================
  // CHECK STOCK LEVEL
  // ========================================

  void _checkStockLevel(
    InventoryItem item,
  ) {
    final notificationProvider =
        _notificationProvider;

    if (notificationProvider == null ||
        !notificationsEnabled) {
      return;
    }

    notificationProvider.syncStockLevelNotification(
      productId: item.id,
      productName: item.productName,
      stock: item.stock,
    );
}

  // ========================================
  // UPDATE STOCK
  // ========================================

  void updateStock(
    String id,
    int newStock,
  ) {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return;
    }

    if (newStock < 0) {
      return;
    }

    _items[index].stock = newStock;
    _persistItem(_items[index]);

    _checkStockLevel(
      _items[index],
    );

    notifyListeners();
  }

    // ========================================
  // DEDUCT STOCK FOR COMPLETED ORDERS
  // ========================================

  void syncCompletedOrders(
    List<OrderModel> orders,
  ) {
    var inventoryChanged = false;

    for (final order in orders) {
      if (order.status != 'Completed' ||
          _stockDeductedOrderIds.contains(order.id)) {
        continue;
      }

      // Combine duplicate products in one order before deducting stock.
      final quantitiesByProductId = <String, int>{};
      final productNames = <String, String>{};

      for (final cartItem in order.items.expand((item) => item.stockItems)) {
        final productId = cartItem.product.id;

        quantitiesByProductId[productId] =
            (quantitiesByProductId[productId] ?? 0) +
                cartItem.quantity;

        productNames[productId] = cartItem.product.name;
      }

      // Keep this as a backstop in case an order reaches Completed elsewhere.
      if (stockShortagesForOrder(order).isNotEmpty) {
        continue;
      }

      for (final entry in quantitiesByProductId.entries) {
        final inventoryItem = _items.firstWhere(
          (item) => item.id == entry.key,
        );

        final previousStock = inventoryItem.stock;
        inventoryItem.stock -= entry.value;
        _persistItem(inventoryItem);

        _recordMovement(
          StockMovement(
            id: 'ORDER-${order.id}-${entry.key}',
            productId: entry.key,
            productName:
                productNames[entry.key] ?? inventoryItem.productName,
            quantity: entry.value,
            previousStock: previousStock,
            newStock: inventoryItem.stock,
            reason: 'Completed Customer Order',
            notes: 'Stock deducted for order #${order.id}.',
            date: DateTime.now(),
            type: 'Stock Out',
          ),
        );

        _checkStockLevel(inventoryItem);
      }

      // Mark only after the entire order was deducted successfully.
      _stockDeductedOrderIds.add(order.id);
      inventoryChanged = true;
    }

    if (inventoryChanged) {
      notifyListeners();
    }
  }

  // ========================================
  // ADD STOCK
  // ========================================

  bool addStock(
    String id,
    int quantity,
    {
    String reason = 'Manual Stock In',
    String notes = '',
  }) {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return false;
    }

    if (quantity <= 0) {
      return false;
    }

    final item = _items[index];
    final previousStock = item.stock;
    item.stock += quantity;
    _persistItem(item);

    _recordMovement(
      StockMovement(
        id: 'STOCK-IN-${DateTime.now().microsecondsSinceEpoch}-$id',
        productId: item.id,
        productName: item.productName,
        quantity: quantity,
        previousStock: previousStock,
        newStock: item.stock,
        reason: reason,
        notes: notes,
        date: DateTime.now(),
        type: 'Stock In',
      ),
    );

    _checkStockLevel(
      item,
    );

    notifyListeners();

    return true;
  }

  // ========================================
  // DEDUCT STOCK
  // ========================================

  bool deductStock(
    String id,
    int quantity,
  ) {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return false;
    }

    if (quantity <= 0) {
      return false;
    }

    if (_items[index].stock < quantity) {
      return false;
    }

    _items[index].stock -= quantity;
    _persistItem(_items[index]);

    _checkStockLevel(
      _items[index],
    );

    notifyListeners();

    return true;
  }

  // ========================================
  // RECORD STOCK MOVEMENT
  // ========================================



  void addStockMovement(
    StockMovement movement,
  ) {
    _recordMovement(movement);

    notifyListeners();
  }

  void _recordMovement(StockMovement movement) {
    _movements.insert(
      0,
      movement,
    );

    _persistMovement(movement);
  }
}
