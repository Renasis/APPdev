import 'package:flutter/material.dart';

import '../../../admin/inventory/providers/inventory_provider.dart';
import '../../../customer/orders/models/order_model.dart';

enum StaffNotificationType {
  newOrder,
  lowStock,
  criticalStock,
}

class StaffNotification {
  final String id;
  final String title;
  String message;
  final StaffNotificationType type;
  DateTime createdAt;
  bool isRead;

  StaffNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class StaffNotificationProvider extends ChangeNotifier {
  final List<StaffNotification> _notifications = [];

  List<StaffNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  void sync({
    required List<OrderModel> orders,
    required List<InventoryItem> inventoryItems,
    bool newOrderAlertsEnabled = true,
    bool lowStockAlertsEnabled = true,
    bool criticalStockAlertsEnabled = true,
  }) {
    var changed = _removeDisabledTypes(
      newOrderAlertsEnabled: newOrderAlertsEnabled,
      lowStockAlertsEnabled: lowStockAlertsEnabled,
      criticalStockAlertsEnabled: criticalStockAlertsEnabled,
    );

    if (newOrderAlertsEnabled) {
      for (final order in orders) {
        if (order.status != 'Pending') {
          continue;
        }

        changed = _addIfMissing(
              StaffNotification(
                id: 'staff-order-${order.id}',
                title: 'New Customer Order',
                message:
                    'Order #${order.id} from ${order.customerName} is ready for confirmation.',
                type: StaffNotificationType.newOrder,
                createdAt: DateTime.now(),
              ),
            ) ||
            changed;
      }
    }

    for (final item in inventoryItems) {
      changed =
          _syncStockAlert(
            item,
            lowStockAlertsEnabled: lowStockAlertsEnabled,
            criticalStockAlertsEnabled: criticalStockAlertsEnabled,
          ) ||
          changed;
    }

    if (changed) {
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    final notification = _findById(id);
    if (notification == null || notification.isRead) {
      return;
    }

    notification.isRead = true;
    notifyListeners();
  }

  void markAllAsRead() {
    var changed = false;
    for (final notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    final before = _notifications.length;
    _notifications.removeWhere((notification) => notification.id == id);
    if (_notifications.length != before) {
      notifyListeners();
    }
  }

  void clearAll() {
    if (_notifications.isEmpty) {
      return;
    }

    _notifications.clear();
    notifyListeners();
  }

  bool _syncStockAlert(
    InventoryItem item, {
    required bool lowStockAlertsEnabled,
    required bool criticalStockAlertsEnabled,
  }) {
    final lowId = 'staff-low-stock-${item.id}';
    final criticalId = 'staff-critical-stock-${item.id}';

    if (item.stock <= 2 && criticalStockAlertsEnabled) {
      final removed = _removeIds({lowId});
      return _upsertStockAlert(
            id: criticalId,
            title: 'Critical Stock Alert',
            message: '${item.productName} has only ${item.stock} units remaining.',
            type: StaffNotificationType.criticalStock,
          ) ||
          removed;
    }

    if (item.stock <= 5 && lowStockAlertsEnabled) {
      final removed = _removeIds({criticalId});
      return _upsertStockAlert(
            id: lowId,
            title: 'Low Stock Alert',
            message: '${item.productName} has only ${item.stock} units remaining.',
            type: StaffNotificationType.lowStock,
          ) ||
          removed;
    }

    return _removeIds({lowId, criticalId});
  }

  bool _removeDisabledTypes({
    required bool newOrderAlertsEnabled,
    required bool lowStockAlertsEnabled,
    required bool criticalStockAlertsEnabled,
  }) {
    final disabledTypes = <StaffNotificationType>{
      if (!newOrderAlertsEnabled) StaffNotificationType.newOrder,
      if (!lowStockAlertsEnabled) StaffNotificationType.lowStock,
      if (!criticalStockAlertsEnabled) StaffNotificationType.criticalStock,
    };

    if (disabledTypes.isEmpty) {
      return false;
    }

    final before = _notifications.length;
    _notifications.removeWhere(
      (notification) => disabledTypes.contains(notification.type),
    );
    return _notifications.length != before;
  }

  bool _upsertStockAlert({
    required String id,
    required String title,
    required String message,
    required StaffNotificationType type,
  }) {
    final existing = _findById(id);
    if (existing == null) {
      _notifications.insert(
        0,
        StaffNotification(
          id: id,
          title: title,
          message: message,
          type: type,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    }

    if (existing.message == message) {
      return false;
    }

    existing.message = message;
    existing.createdAt = DateTime.now();
    existing.isRead = false;
    _notifications.remove(existing);
    _notifications.insert(0, existing);
    return true;
  }

  bool _addIfMissing(StaffNotification notification) {
    if (_findById(notification.id) != null) {
      return false;
    }

    _notifications.insert(0, notification);
    return true;
  }

  bool _removeIds(Set<String> ids) {
    final before = _notifications.length;
    _notifications.removeWhere((notification) => ids.contains(notification.id));
    return _notifications.length != before;
  }

  StaffNotification? _findById(String id) {
    for (final notification in _notifications) {
      if (notification.id == id) {
        return notification;
      }
    }
    return null;
  }
}
