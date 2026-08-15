import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../../../shared/notifications/repository/notification_repository.dart';

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

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

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
      ..addAll(notifications.map((data) => NotificationModel(
            id: data['id'] as String? ?? '',
            recipientUid: data['recipientUid'] as String? ?? '',
            title: data['title'] as String? ?? '',
            message: data['message'] as String? ?? '',
            date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: data['isRead'] as bool? ?? false,
          )));
    notifyListeners();
  }

  void _onError(Object error) {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String? recipientUid,
  }) async {
    final uid = recipientUid ?? _recipientUid;

    if (_repository != null && uid != null && uid.isNotEmpty) {
      await _repository!.addNotification({
        'recipientUid': uid,
        'title': title,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }

    _notifications.insert(0, NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      recipientUid: uid ?? '',
      title: title,
      message: message,
      date: DateTime.now(),
      isRead: false,
    ));

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

    _notifications[index] = NotificationModel(
      id: _notifications[index].id,
      recipientUid: _notifications[index].recipientUid,
      title: _notifications[index].title,
      message: _notifications[index].message,
      date: _notifications[index].date,
      isRead: true,
    );

    notifyListeners();

    await _repository?.updateNotification(id, {'isRead': true});
  }

  Future<void> markAllAsRead() async {
    bool changed = false;

    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          recipientUid: _notifications[i].recipientUid,
          title: _notifications[i].title,
          message: _notifications[i].message,
          date: _notifications[i].date,
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
      // Re-fetch notifications to sync with Firestore
    }
  }

  Future<void> deleteNotification(String id) async {
    final before = _notifications.length;
    _notifications.removeWhere((notification) => notification.id == id);

    if (_notifications.length != before) {
      notifyListeners();
    }

    await _repository?.deleteNotification(id);
  }

  Future<void> clearAll() async {
    if (_notifications.isEmpty) {
      return;
    }

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
