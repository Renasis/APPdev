import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      title: 'Welcome',
      message: 'Welcome to End PC Parts!',
      date: DateTime.now(),
    ),
  ];

  List<NotificationModel> get notifications =>
      _notifications;

  void addNotification({
  required String title,
  required String message,
}) {
    _notifications.insert(
      0,
      NotificationModel(
        title: title,
        message: message,
        date: DateTime.now(),
      ),
    );

    notifyListeners();
  }
}