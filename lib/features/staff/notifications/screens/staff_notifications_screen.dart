import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/staff_notification_provider.dart';
import 'staff_notification_settings_screen.dart';

class StaffNotificationsScreen extends StatelessWidget {
  const StaffNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffNotificationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${provider.unreadCount} unread',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Spacer(),
            TextButton(
              onPressed: provider.unreadCount == 0 ? null : provider.markAllAsRead,
              child: const Text('Mark all as read'),
            ),
            IconButton(
              tooltip: 'Notification settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StaffNotificationSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined),
            ),
            IconButton(
              tooltip: 'Clear all',
              onPressed: provider.clearAll,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: provider.notifications.isEmpty
              ? const Center(child: Text('No staff notifications found.'))
              : ListView.separated(
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    return Card(
                      color: notification.isRead ? null : Colors.blue.shade50,
                      child: ListTile(
                        leading: _NotificationIcon(type: notification.type),
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                        trailing: IconButton(
                          tooltip: 'Delete notification',
                          onPressed: () =>
                              provider.deleteNotification(notification.id),
                          icon: const Icon(Icons.close),
                        ),
                        onTap: () => provider.markAsRead(notification.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final StaffNotificationType type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      StaffNotificationType.newOrder => Icons.shopping_bag_outlined,
      StaffNotificationType.lowStock => Icons.warning_amber_outlined,
      StaffNotificationType.criticalStock => Icons.error_outline,
      StaffNotificationType.system => Icons.notifications_outlined,
    };
    final color = switch (type) {
      StaffNotificationType.newOrder => Colors.blue,
      StaffNotificationType.lowStock => Colors.orange,
      StaffNotificationType.criticalStock => Colors.red,
      StaffNotificationType.system => Colors.grey,
    };

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(icon, color: color),
    );
  }
}
