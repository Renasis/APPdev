import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../shared/notifications/repository/notification_repository.dart';

enum NotificationType {
  criticalStock,
  lowStock,
  purchaseOrder,
  sales,
  system,
}

class AdminNotification {
  final String id;
  final String recipientUid;
  final String title;
  String message;
  final NotificationType type;
  DateTime createdAt;
  bool isRead;

  AdminNotification({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({
    NotificationRepository? repository,
    String? recipientUid,
  })  : _repository = repository,
        _recipientUid = recipientUid {
    if (_repository != null && _recipientUid != null && _recipientUid!.isNotEmpty) {
      _subscription = _repository!.watchNotificationsForUser(_recipientUid!).listen(
        _onNotifications,
        onError: _onError,
      );
    }
  }

  final NotificationRepository? _repository;
  final String? _recipientUid;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

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

  void setRecipientUid(String? uid) {
    if (_recipientUid == uid) {
      return;
    }

    _subscription?.cancel();
    _subscription = null;
    _notifications.clear();

    if (_repository != null && uid != null && uid.isNotEmpty) {
      _subscription = _repository!.watchNotificationsForUser(uid).listen(
        _onNotifications,
        onError: _onError,
      );
    }

    notifyListeners();
  }

  void _onNotifications(List<Map<String, dynamic>> notifications) {
    _notifications
      ..clear()
      ..addAll(notifications.map((data) => AdminNotification(
            id: data['id'] as String? ?? '',
            recipientUid: data['recipientUid'] as String? ?? '',
            title: data['title'] as String? ?? '',
            message: data['message'] as String? ?? '',
            type: _typeFromString(data['type'] as String? ?? 'system'),
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: data['isRead'] as bool? ?? false,
          )));
    notifyListeners();
  }

  void _onError(Object error) {
    _notifications.clear();
    notifyListeners();
  }

  NotificationType _typeFromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.system,
    );
  }

  String _typeToString(NotificationType type) {
    return type.name;
  }

  Future<void> addNotification(
    AdminNotification notification,
  ) async {
    debugPrint('[NOTIFICATION] addNotification started: id=${notification.id}');
    final uid = _recipientUid ?? notification.recipientUid;

    if (_repository != null && uid.isNotEmpty) {
      debugPrint('[NOTIFICATION] addNotification writing to Firestore: uid=$uid');
      await _repository!.addNotification({
        'recipientUid': uid,
        'title': notification.title,
        'message': notification.message,
        'type': _typeToString(notification.type),
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      debugPrint('[NOTIFICATION] addNotification Firestore write completed');
    } else {
      debugPrint('[NOTIFICATION] addNotification skipped: no repository or empty uid');
    }

    _notifications.insert(0, notification);
    notifyListeners();
    debugPrint('[NOTIFICATION] addNotification completed');
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1) {
      return;
    }

    if (_notifications[index].isRead) {
      return;
    }

    _notifications[index] = AdminNotification(
      id: _notifications[index].id,
      recipientUid: _notifications[index].recipientUid,
      title: _notifications[index].title,
      message: _notifications[index].message,
      type: _notifications[index].type,
      createdAt: _notifications[index].createdAt,
      isRead: true,
    );

    notifyListeners();

    await _repository?.updateNotification(id, {'isRead': true});
  }

  Future<void> markAllAsRead() async {
    bool changed = false;

    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = AdminNotification(
          id: _notifications[i].id,
          recipientUid: _notifications[i].recipientUid,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          createdAt: _notifications[i].createdAt,
          isRead: true,
        );
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }

    if (_recipientUid != null && _recipientUid!.isNotEmpty) {
      await _repository?.clearNotificationsForUser(_recipientUid!);
    }
  }

  Future<void> addCriticalStockNotification({
    required String productId,
    required String productName,
    required int stock,
  }) async {
    final notificationId = 'critical-stock-$productId';
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

    await addNotification(
      AdminNotification(
        id: notificationId,
        recipientUid: _recipientUid ?? '',
        title: 'Critical Stock Alert',
        message: message,
        type: NotificationType.criticalStock,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> addLowStockNotification({
    required String productId,
    required String productName,
    required int stock,
  }) async {
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

    await addNotification(
      AdminNotification(
        id: notificationId,
        recipientUid: _recipientUid ?? '',
        title: 'Low Stock Alert',
        message: message,
        type: NotificationType.lowStock,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> syncStockLevelNotification({
    required String productId,
    required String productName,
    required int stock,
  }) async {
    debugPrint('[NOTIFICATION] syncStockLevelNotification started: productId=$productId stock=$stock');
    final criticalId = 'critical-stock-$productId';
    final lowId = 'low-stock-$productId';

    if (stock <= 2) {
      debugPrint('[NOTIFICATION] syncStockLevelNotification: stock <= 2, removing low and adding critical');
      await _removeNotifications({lowId});
      await addCriticalStockNotification(
        productId: productId,
        productName: productName,
        stock: stock,
      );
      debugPrint('[NOTIFICATION] syncStockLevelNotification completed (critical)');
      return;
    }

    if (stock <= 5) {
      debugPrint('[NOTIFICATION] syncStockLevelNotification: stock <= 5, removing critical and adding low');
      await _removeNotifications({criticalId});
      await addLowStockNotification(
        productId: productId,
        productName: productName,
        stock: stock,
      );
      debugPrint('[NOTIFICATION] syncStockLevelNotification completed (low)');
      return;
    }

    debugPrint('[NOTIFICATION] syncStockLevelNotification: stock > 5, removing critical and low');
    await _removeNotifications({criticalId, lowId});
    debugPrint('[NOTIFICATION] syncStockLevelNotification completed (normal)');
  }

  Future<void> _removeNotifications(Set<String> ids) async {
    debugPrint('[NOTIFICATION] _removeNotifications started: ids=$ids');
    final before = _notifications.length;
    _notifications.removeWhere((notification) => ids.contains(notification.id));

    if (_notifications.length != before) {
      notifyListeners();
    }

    for (final id in ids) {
      debugPrint('[NOTIFICATION] _removeNotifications deleting: id=$id');
      await _repository?.deleteNotification(id);
      debugPrint('[NOTIFICATION] _removeNotifications deleted: id=$id');
    }
    debugPrint('[NOTIFICATION] _removeNotifications completed');
  }

  Future<void> addPurchaseOrderNotification({
    required String purchaseOrderId,
    required String message,
  }) async {
    await addNotification(
      AdminNotification(
        id: 'purchase-order-$purchaseOrderId',
        recipientUid: _recipientUid ?? '',
        title: 'Purchase Order Update',
        message: message,
        type: NotificationType.purchaseOrder,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> addSalesNotification({
    required String saleId,
    required String message,
  }) async {
    await addNotification(
      AdminNotification(
        id: 'sale-$saleId',
        recipientUid: _recipientUid ?? '',
        title: 'New Sale',
        message: message,
        type: NotificationType.sales,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> addSystemNotification({
    required String notificationId,
    required String title,
    required String message,
  }) async {
    await addNotification(
      AdminNotification(
        id: 'system-$notificationId',
        recipientUid: _recipientUid ?? '',
        title: title,
        message: message,
        type: NotificationType.system,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteNotification(String id) async {
    debugPrint('[NOTIFICATION] deleteNotification started: id=$id');
    _notifications.removeWhere(
      (notification) => notification.id == id,
    );

    notifyListeners();

    debugPrint('[NOTIFICATION] deleteNotification calling Firestore delete');
    await _repository?.deleteNotification(id);
    debugPrint('[NOTIFICATION] deleteNotification completed');
  }

  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();

    if (_recipientUid != null && _recipientUid!.isNotEmpty) {
      await _repository?.clearNotificationsForUser(_recipientUid!);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

