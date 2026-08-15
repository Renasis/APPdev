import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../admin/inventory/providers/inventory_provider.dart';
import '../../../customer/orders/models/order_model.dart';
import '../../../shared/notifications/repository/notification_repository.dart';

enum StaffNotificationType {
  newOrder,
  lowStock,
  criticalStock,
  system,
}

class StaffNotification {
  final String id;
  final String recipientUid;
  final String title;
  String message;
  final StaffNotificationType type;
  DateTime createdAt;
  bool isRead;

  StaffNotification({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class StaffNotificationProvider extends ChangeNotifier {
  StaffNotificationProvider({
    NotificationRepository? repository,
    String? recipientUid,
  })  : _repository = repository,
        _recipientUid = recipientUid {
    _subscribe();
  }

  final NotificationRepository? _repository;
  String? _recipientUid;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  final List<StaffNotification> _notifications = [];

  List<StaffNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  void _subscribe() {
    if (_repository != null && _recipientUid != null && _recipientUid!.isNotEmpty) {
      _subscription = _repository!.watchNotificationsForUser(_recipientUid!).listen(
        _onNotifications,
        onError: _onError,
      );
    }
  }

  void _onNotifications(List<Map<String, dynamic>> notifications) {
    _notifications
      ..clear()
      ..addAll(notifications.map((data) => StaffNotification(
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

  StaffNotificationType _typeFromString(String type) {
    return StaffNotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => StaffNotificationType.system,
    );
  }

  String _typeToString(StaffNotificationType type) {
    return type.name;
  }

  void setRecipientUid(String? uid) {
    if (_recipientUid == uid) {
      return;
    }

    _subscription?.cancel();
    _subscription = null;
    _notifications.clear();

    _recipientUid = uid;

    _subscribe();

    notifyListeners();
  }

  Future<void> addNotification(
    StaffNotification notification,
  ) async {
    final uid = _recipientUid ?? notification.recipientUid;

    if (_repository != null && uid.isNotEmpty) {
      await _repository!.setNotification(
        notification.id,
        {
          'recipientUid': uid,
          'title': notification.title,
          'message': notification.message,
          'type': _typeToString(notification.type),
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        },
      );
    }

    _notifications.insert(0, notification);
    notifyListeners();
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

    _notifications[index] = StaffNotification(
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
        _notifications[i] = StaffNotification(
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

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere(
      (notification) => notification.id == id,
    );

    notifyListeners();

    await _repository?.deleteNotification(id);
  }

  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();

    if (_recipientUid != null && _recipientUid!.isNotEmpty) {
      await _repository?.clearNotificationsForUser(_recipientUid!);
    }
  }

  void sync({
    required List<OrderModel> orders,
    required List<InventoryItem> inventoryItems,
    bool newOrderAlertsEnabled = true,
    bool lowStockAlertsEnabled = true,
    bool criticalStockAlertsEnabled = true,
  }) {
    final previousIds = _notifications.map((n) => n.id).toSet();

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
                recipientUid: _recipientUid ?? '',
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
      _persistChanges(previousIds);
    }
  }

  void _persistChanges(Set<String> previousIds) {
    if (_repository == null || _recipientUid == null || _recipientUid!.isEmpty) {
      return;
    }

    final currentIds = _notifications.map((n) => n.id).toSet();
    final removedIds = previousIds.difference(currentIds);

    for (final id in removedIds) {
      _repository!.deleteNotification(id);
    }

    for (final notification in _notifications) {
      _repository!.setNotification(
        notification.id,
        {
          'recipientUid': _recipientUid!,
          'title': notification.title,
          'message': notification.message,
          'type': _typeToString(notification.type),
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': notification.isRead,
        },
      );
    }
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
          recipientUid: _recipientUid ?? '',
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
