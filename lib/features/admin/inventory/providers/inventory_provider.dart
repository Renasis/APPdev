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
  final String performedByUid;
  final String performedByName;
  final String performedByRole;

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
    this.performedByUid = '',
    this.performedByName = '',
    this.performedByRole = '',
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
      performedByUid: '',
      performedByName: '',
      performedByRole: '',
    ),
  ];

  final Set<String> _stockDeductedOrderIds = <String>{};

  NotificationProvider? _notificationProvider;

  bool notificationsEnabled = true;

  Map<String, String>? _performedBy;

  void setPerformedBy({
    required String uid,
    required String name,
    required String role,
  }) {
    _performedBy = {
      'uid': uid,
      'name': name,
      'role': role,
    };
  }

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

  Future<void> setNotificationProvider(
  NotificationProvider provider,
) async {
  _notificationProvider = provider;

  for (final item in _items) {
    await _checkStockLevel(item);
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
    debugPrint('[INVENTORY] _persistItem started: id=${item.id}');
    unawaited(_repository?.saveItem(item) ?? Future<void>.value());
    debugPrint('[INVENTORY] _persistItem fire-and-forget completed');
  }

  void _persistMovement(StockMovement movement) {
    debugPrint('[INVENTORY] _persistMovement started: id=${movement.id}');
    unawaited(_repository?.saveMovement(movement) ?? Future<void>.value());
    debugPrint('[INVENTORY] _persistMovement fire-and-forget completed');
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

  Future<bool> createInventoryRecord({
    required String productId,
    required String productName,
    required int initialStock,
    String notes = '',
  }) async {
    debugPrint('[INVENTORY] createInventoryRecord started: productId=$productId initialStock=$initialStock');
    if (initialStock <= 0 || itemById(productId) != null) {
      debugPrint('[INVENTORY] createInventoryRecord rejected: invalid params or duplicate');
      return false;
    }

    final item = InventoryItem(
      id: productId,
      productName: productName,
      stock: initialStock,
    );

    final movementId = 'INITIAL-${DateTime.now().microsecondsSinceEpoch}-$productId';

    try {
      debugPrint('[INVENTORY] createInventoryRecord adding item to local list');
      _items.add(item);
      _persistItem(item);

      debugPrint('[INVENTORY] createInventoryRecord recording movement');
      _recordMovement(
        _createStockMovement(
          id: movementId,
          productId: productId,
          productName: productName,
          quantity: initialStock,
          previousStock: 0,
          newStock: initialStock,
          reason: 'Initial Inventory',
          notes: notes,
          date: DateTime.now(),
          type: 'Stock In',
        ),
      );

      debugPrint('[INVENTORY] createInventoryRecord checking stock level');
      await _checkStockLevel(item);
      debugPrint('[INVENTORY] createInventoryRecord stock level check completed');

      notifyListeners();
      debugPrint('[INVENTORY] createInventoryRecord completed: true');
      return true;
    } catch (error) {
      debugPrint('[INVENTORY] createInventoryRecord FAILED: $error');
      _items.removeWhere((i) => i.id == productId);
      _movements.removeWhere((m) => m.id == movementId);
      notifyListeners();
      return false;
    }
  }

  Future<bool> addInventoryItem({
    required String id,
    required String productName,
    required int stock,
  }) async {
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
    await _checkStockLevel(item);
    notifyListeners();
    return true;
  }

  Future<void> updateInventoryItemName(String id, String productName) async {
    final item = itemById(id);
    if (item == null || item.productName == productName) {
      return;
    }

    item.productName = productName;
    _persistItem(item);
    await _checkStockLevel(item);
    notifyListeners();
  }

  Future<void> removeInventoryItem(String id) async {
    final item = itemById(id);
    if (item == null) {
      return;
    }

    _items.remove(item);
    unawaited(_repository?.deleteItem(id) ?? Future<void>.value());
    await _notificationProvider?.syncStockLevelNotification(
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

  Future<void> _checkStockLevel(
    InventoryItem item,
  ) async {
    debugPrint('[INVENTORY] _checkStockLevel started: productId=${item.id} stock=${item.stock}');
    final notificationProvider =
        _notificationProvider;

    if (notificationProvider == null ||
        !notificationsEnabled) {
      debugPrint('[INVENTORY] _checkStockLevel skipped: no notification provider or disabled');
      return;
    }

    debugPrint('[INVENTORY] _checkStockLevel calling syncStockLevelNotification');
    await notificationProvider.syncStockLevelNotification(
      productId: item.id,
      productName: item.productName,
      stock: item.stock,
    );
    debugPrint('[INVENTORY] _checkStockLevel completed');
  }

  // ========================================
  // UPDATE STOCK
  // ========================================

  Future<void> updateStock(
    String id,
    int newStock,
  ) async {
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

    await _checkStockLevel(
      _items[index],
    );

    notifyListeners();
  }

    // ========================================
  // DEDUCT STOCK FOR COMPLETED ORDERS
  // ========================================

  Future<void> syncCompletedOrders(
    List<OrderModel> orders,
  ) async {
    var inventoryChanged = false;

    for (final order in orders) {
      if (order.status != 'Completed' ||
          _stockDeductedOrderIds.contains(order.id) ||
          order.orderType == 'walk_in') {
        continue;
      }

      final quantitiesByProductId = <String, int>{};
      final productNames = <String, String>{};

      for (final cartItem in order.items.expand((item) => item.stockItems)) {
        final productId = cartItem.product.id;

        quantitiesByProductId[productId] =
            (quantitiesByProductId[productId] ?? 0) +
                cartItem.quantity;

        productNames[productId] = cartItem.product.name;
      }

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
          _createStockMovement(
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

        await _checkStockLevel(inventoryItem);
      }

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

  Future<bool> addStock(
    String id,
    int quantity,
    {
    String reason = 'Manual Stock In',
    String notes = '',
    String? movementId,
  }) async {
    debugPrint('[INVENTORY] addStock started: id=$id quantity=$quantity reason=$reason');
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      debugPrint('[INVENTORY] addStock rejected: item not found');
      return false;
    }

    if (quantity <= 0) {
      debugPrint('[INVENTORY] addStock rejected: invalid quantity');
      return false;
    }

    final effectiveMovementId = movementId ?? 'STOCK-IN-${DateTime.now().microsecondsSinceEpoch}-$id';
    if (_movements.any((movement) => movement.id == effectiveMovementId)) {
      debugPrint('[INVENTORY] addStock skipped: duplicate movement id');
      return true;
    }

    try {
      debugPrint('[INVENTORY] addStock updating stock');
      final item = _items[index];
      final previousStock = item.stock;
      item.stock += quantity;
      _persistItem(item);

      debugPrint('[INVENTORY] addStock recording movement');
      _recordMovement(
        _createStockMovement(
          id: effectiveMovementId,
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

      debugPrint('[INVENTORY] addStock checking stock level');
      await _checkStockLevel(
        item,
      );
      debugPrint('[INVENTORY] addStock stock level check completed');

      notifyListeners();

      debugPrint('[INVENTORY] addStock completed: true');
      return true;
    } catch (error) {
      debugPrint('[INVENTORY] addStock FAILED: $error');
      _items[index].stock = _items[index].stock - quantity;
      notifyListeners();
      return false;
    }
  }

  // ========================================
  // DEDUCT STOCK
  // ========================================

  Future<bool> deductStock(
    String id,
    int quantity, {
    String reason = 'Manual Stock Out',
    String notes = '',
    String? movementId,
  }) async {
    debugPrint('[INVENTORY] deductStock started: id=$id quantity=$quantity reason=$reason');
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      debugPrint('[INVENTORY] deductStock rejected: item not found');
      return false;
    }

    if (quantity <= 0) {
      debugPrint('[INVENTORY] deductStock rejected: invalid quantity');
      return false;
    }

    if (_items[index].stock < quantity) {
      debugPrint('[INVENTORY] deductStock rejected: insufficient stock');
      return false;
    }

    final effectiveMovementId = movementId ?? 'STOCK-OUT-${DateTime.now().microsecondsSinceEpoch}-$id';
    if (_movements.any((movement) => movement.id == effectiveMovementId)) {
      debugPrint('[INVENTORY] deductStock skipped: duplicate movement id');
      return true;
    }

    try {
      debugPrint('[INVENTORY] deductStock updating stock');
      final item = _items[index];
      final previousStock = item.stock;
      item.stock -= quantity;
      _persistItem(item);

      debugPrint('[INVENTORY] deductStock recording movement');
      _recordMovement(
        _createStockMovement(
          id: effectiveMovementId,
          productId: item.id,
          productName: item.productName,
          quantity: quantity,
          previousStock: previousStock,
          newStock: item.stock,
          reason: reason,
          notes: notes,
          date: DateTime.now(),
          type: 'Stock Out',
        ),
      );

      debugPrint('[INVENTORY] deductStock checking stock level');
      await _checkStockLevel(
        item,
      );
      debugPrint('[INVENTORY] deductStock stock level check completed');

      notifyListeners();

      debugPrint('[INVENTORY] deductStock completed: true');
      return true;
    } catch (error) {
      debugPrint('[INVENTORY] deductStock FAILED: $error');
      _items[index].stock = _items[index].stock + quantity;
      notifyListeners();
      return false;
    }
  }

  // ========================================
  // RECORD STOCK MOVEMENT
  // ========================================



  StockMovement _createStockMovement({
    required String id,
    required String productId,
    required String productName,
    required int quantity,
    required int previousStock,
    required int newStock,
    required String reason,
    required String notes,
    required DateTime date,
    required String type,
  }) {
    return StockMovement(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      reason: reason,
      notes: notes,
      date: date,
      type: type,
      performedByUid: _performedBy?['uid'] ?? '',
      performedByName: _performedBy?['name'] ?? '',
      performedByRole: _performedBy?['role'] ?? '',
    );
  }

  void addStockMovement(
    StockMovement movement,
  ) {
    final performerUid = movement.performedByUid.isEmpty
        ? (_performedBy?['uid'] ?? '')
        : movement.performedByUid;
    final performerName = movement.performedByName.isEmpty
        ? (_performedBy?['name'] ?? '')
        : movement.performedByName;
    final performerRole = movement.performedByRole.isEmpty
        ? (_performedBy?['role'] ?? '')
        : movement.performedByRole;

    final merged = StockMovement(
      id: movement.id,
      productId: movement.productId,
      productName: movement.productName,
      quantity: movement.quantity,
      previousStock: movement.previousStock,
      newStock: movement.newStock,
      reason: movement.reason,
      notes: movement.notes,
      date: movement.date,
      type: movement.type,
      performedByUid: performerUid,
      performedByName: performerName,
      performedByRole: performerRole,
    );
    _recordMovement(merged);

    notifyListeners();
  }

  void _recordMovement(StockMovement movement) {
    debugPrint('[INVENTORY] _recordMovement: id=${movement.id} type=${movement.type}');
    _movements.insert(
      0,
      movement,
    );

    _persistMovement(movement);
    debugPrint('[INVENTORY] _recordMovement completed');
  }
}
