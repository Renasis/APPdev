import 'package:flutter/material.dart';

enum NotificationType {
  criticalStock,
  lowStock,
  purchaseOrder,
  sales,
  system,
}

class AdminNotification {
  final String id;
  final String title;
  String message;
  final NotificationType type;
  DateTime createdAt;
  bool isRead;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<AdminNotification> _notifications = [];

  List<AdminNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount {
    return _notifications
        .where(
          (notification) => !notification.isRead,
        )
        .length;
  }

  List<AdminNotification> get unreadNotifications {
    return _notifications
        .where(
          (notification) => !notification.isRead,
        )
        .toList();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1) {
      return;
    }

    if (_notifications[index].isRead) {
      return;
    }

    _notifications[index].isRead = true;

    notifyListeners();
  }

  void markAllAsRead() {
    bool changed = false;

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

  void addNotification(
    AdminNotification notification,
  ) {
    // Prevent duplicate notifications
    // with the same ID.
    final alreadyExists = _notifications.any(
      (existing) => existing.id == notification.id,
    );

    if (alreadyExists) {
      return;
    }

    _notifications.insert(
      0,
      notification,
    );

    notifyListeners();
  }

  void addCriticalStockNotification({
    required String productId,
    required String productName,
    required int stock,
  }) {
    final notificationId = 'critical-stock-$productId';
    final message = '$productName has only $stock units remaining.';
    final existingIndex = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (existingIndex != -1) {
      final existing = _notifications[existingIndex];

      // A new stock value is actionable again, including when the old alert
      // was read. Keep one alert per product and surface the latest value.
      if (existing.message != message) {
        existing.message = message;
        existing.createdAt = DateTime.now();
        existing.isRead = false;
        _notifications.removeAt(existingIndex);
        _notifications.insert(0, existing);
        notifyListeners();
      }
      return;
    }

    addNotification(
      AdminNotification(
        id: notificationId,
        title: 'Critical Stock Alert',
        message: message,
        type: NotificationType.criticalStock,
        createdAt: DateTime.now(),
      ),
    );
  }

  void addLowStockNotification({
    required String productId,
    required String productName,
    required int stock,
  }) {
    final notificationId = 'low-stock-$productId';
    final message = '$productName has only $stock units remaining.';
    final existingIndex = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (existingIndex != -1) {
      final existing = _notifications[existingIndex];

      if (existing.message != message) {
        existing.message = message;
        existing.createdAt = DateTime.now();
        existing.isRead = false;
        _notifications.removeAt(existingIndex);
        _notifications.insert(0, existing);
        notifyListeners();
      }
      return;
    }

    addNotification(
      AdminNotification(
        id: notificationId,
        title: 'Low Stock Alert',
        message: message,
        type: NotificationType.lowStock,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Keeps one active stock alert at the appropriate severity for a product.
  /// Alerts are removed when replenishment brings stock above the low-stock
  /// threshold, so the bell and notification center reflect actionable issues.
  void syncStockLevelNotification({
    required String productId,
    required String productName,
    required int stock,
  }) {
    final criticalId = 'critical-stock-$productId';
    final lowId = 'low-stock-$productId';

    if (stock <= 2) {
      _removeNotifications({lowId});
      addCriticalStockNotification(
        productId: productId,
        productName: productName,
        stock: stock,
      );
      return;
    }

    if (stock <= 5) {
      _removeNotifications({criticalId});
      addLowStockNotification(
        productId: productId,
        productName: productName,
        stock: stock,
      );
      return;
    }

    _removeNotifications({criticalId, lowId});
  }

  void _removeNotifications(Set<String> ids) {
    final before = _notifications.length;
    _notifications.removeWhere((notification) => ids.contains(notification.id));

    if (_notifications.length != before) {
      notifyListeners();
    }
  }

  void addPurchaseOrderNotification({
    required String purchaseOrderId,
    required String message,
  }) {
    addNotification(
      AdminNotification(
        id: 'purchase-order-$purchaseOrderId',
        title: 'Purchase Order Update',
        message: message,
        type: NotificationType.purchaseOrder,
        createdAt: DateTime.now(),
      ),
    );
  }

  void addSalesNotification({
    required String saleId,
    required String message,
  }) {
    addNotification(
      AdminNotification(
        id: 'sale-$saleId',
        title: 'New Sale',
        message: message,
        type: NotificationType.sales,
        createdAt: DateTime.now(),
      ),
    );
  }

  void addSystemNotification({
    required String notificationId,
    required String title,
    required String message,
  }) {
    addNotification(
      AdminNotification(
        id: 'system-$notificationId',
        title: title,
        message: message,
        type: NotificationType.system,
        createdAt: DateTime.now(),
      ),
    );
  }

  void deleteNotification(String id) {
    _notifications.removeWhere(
      (notification) => notification.id == id,
    );

    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
