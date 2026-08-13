class NotificationModel {
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}