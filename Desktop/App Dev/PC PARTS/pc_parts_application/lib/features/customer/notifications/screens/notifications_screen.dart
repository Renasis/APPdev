import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<NotificationProvider>(context);

    final notifications =
        provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),

      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )

          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  notifications.length,

              itemBuilder:
                  (context, index) {

                final notification =
                    notifications[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        notification.isRead
                            ? Icons.notifications_none
                            : Icons.notifications,
                      ),
                    ),

                    title: Text(
                      notification.title,
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          notification.message,
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          notification.date
                              .toString(),
                          style:
                              const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}