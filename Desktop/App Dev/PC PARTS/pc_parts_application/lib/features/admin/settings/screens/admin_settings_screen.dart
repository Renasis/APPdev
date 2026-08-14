import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_settings_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState
    extends State<AdminSettingsScreen> {
  late TextEditingController storeController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool notificationsEnabled = true;
  String currency = 'PHP';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settings =
        context.read<AdminSettingsProvider>().settings;

    storeController = TextEditingController(
      text: settings.storeName,
    );

    emailController = TextEditingController(
      text: settings.email,
    );

    phoneController = TextEditingController(
      text: settings.phone,
    );

    addressController = TextEditingController(
      text: settings.address,
    );

    notificationsEnabled =
        settings.notificationsEnabled;

    currency = settings.currency;
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.read<AdminSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Settings',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: storeController,
              decoration: const InputDecoration(
                labelText: 'Store Name',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Business Address',
              ),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'PHP',
                  child: Text('PHP'),
                ),
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  currency = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              title:
                  const Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.updateSettings(
                    storeName: storeController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    currency: currency,
                    notificationsEnabled: notificationsEnabled,
                  );

                  context
                    .read<InventoryProvider>()
                    .setNotificationsEnabled(
                      notificationsEnabled,
                    );

                  if (!notificationsEnabled) {
                    context.read<NotificationProvider>().clearAll();
                  }

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Settings saved successfully',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Save Settings',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}