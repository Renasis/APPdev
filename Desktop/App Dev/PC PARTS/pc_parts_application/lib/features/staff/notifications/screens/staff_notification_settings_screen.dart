import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/staff_notification_settings_provider.dart';

class StaffNotificationSettingsScreen extends StatelessWidget {
  const StaffNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StaffNotificationSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Staff Alerts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose which alerts appear in the Staff notification center.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('New customer orders'),
                  subtitle: const Text('Alert when an order needs confirmation.'),
                  value: settings.newOrderAlertsEnabled,
                  onChanged: settings.setNewOrderAlertsEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.warning_amber_outlined),
                  title: const Text('Low stock'),
                  subtitle: const Text('Alert when stock is between 3 and 5 units.'),
                  value: settings.lowStockAlertsEnabled,
                  onChanged: settings.setLowStockAlertsEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.error_outline),
                  title: const Text('Critical stock'),
                  subtitle: const Text('Alert when stock is 2 units or fewer.'),
                  value: settings.criticalStockAlertsEnabled,
                  onChanged: settings.setCriticalStockAlertsEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'These preferences affect only the Staff portal. They do not change Admin or Customer notifications.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
