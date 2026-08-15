class NotificationModel {
  final String id;
  final String recipientUid;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}