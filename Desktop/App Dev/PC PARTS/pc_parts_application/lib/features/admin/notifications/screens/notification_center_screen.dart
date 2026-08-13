import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pc_parts_application/features/admin/notifications/providers/notification_provider.dart';



class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllAsRead,
              child: const Text(
                'Mark all as read',
              ),
            ),

          IconButton(
            tooltip: 'Clear all',
            onPressed: provider.notifications.isEmpty
                ? null
                : () {
                    _showClearConfirmation(
                      context,
                      provider,
                    );
                  },
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: provider.notifications.isEmpty
          ? const _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification =
                    provider.notifications[index];

                return _NotificationCard(
                  notification: notification,
                  onTap: () {
                    provider.markAsRead(
                      notification.id,
                    );
                  },
                  onDelete: () {
                    provider.deleteNotification(
                      notification.id,
                    );
                  },
                );
              },
            ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Clear notifications?',
          ),
          content: const Text(
            'This will permanently remove all notifications.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clearAll();
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _notificationColor(
      notification.type,
    );

    return Card(
      elevation: notification.isRead ? 0 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  _notificationIcon(
                    notification.type,
                  ),
                  color: color,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 9,
                            height: 9,
                            decoration:
                                const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _formatTime(
                        notification.createdAt,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.close,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.criticalStock:
        return Icons.error_outline;

      case NotificationType.lowStock:
        return Icons.warning_amber_outlined;

      case NotificationType.purchaseOrder:
        return Icons.receipt_long_outlined;

      case NotificationType.sales:
        return Icons.payments_outlined;

      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  Color _notificationColor(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.criticalStock:
        return Colors.red;

      case NotificationType.lowStock:
        return Colors.orange;

      case NotificationType.purchaseOrder:
        return Colors.blue;

      case NotificationType.sales:
        return Colors.green;

      case NotificationType.system:
        return Colors.indigo;
    }
  }

  String _formatTime(DateTime time) {
    final difference =
        DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${difference.inDays} days ago';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 72,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 16),

          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'You are all caught up.',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}