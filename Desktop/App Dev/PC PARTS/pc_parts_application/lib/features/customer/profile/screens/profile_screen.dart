import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../orders/screens/orders_screen.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import '../../support/screens/support_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../address/screens/address_list_screen.dart';
import 'personal_information_screen.dart';
import '../../saved_builds/screens/saved_builds_screen.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../../../core/routes/route_names.dart';
import '../../../authentication/providers/auth_provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

 @override
Widget build(BuildContext context) {

  final profileProvider =
      Provider.of<ProfileProvider>(context);

  final customer =
      profileProvider.customer;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Profile'),
    ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // =========================
            // PROFILE HEADER
            // =========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 45,
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
  customer.fullName,
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

                  const SizedBox(height: 5),

                  Text(
                    customer.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // MY ACCOUNT
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Personal Information
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.person_outline,
                ),

                title: const Text(
                  'Personal Information',
                ),

                subtitle: const Text(
                  'View and manage your account',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PersonalInformationScreen(),
                    ),
                  );
                },
              ),
            ),

            // Delivery Address
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_on_outlined,
                ),

                title: const Text(
                  'Delivery Address',
                ),

                subtitle: const Text(
                  'Manage your delivery addresses',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddressListScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // SHOPPING
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Shopping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // My Orders
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.receipt_long,
                ),

                title: const Text(
                  'My Orders',
                ),

                subtitle: const Text(
                  'View your orders and order status',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const OrdersScreen(),
                    ),
                  );
                },
              ),
            ),

            // Wishlist
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.favorite_border,
                ),

                title: const Text(
                  'Wishlist',
                ),

                subtitle: const Text(
                  'View your saved products',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const WishlistScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
  child: ListTile(
    leading: const Icon(
      Icons.computer,
    ),

    title: const Text(
      'Saved Builds',
    ),

    subtitle: const Text(
      'View your saved PC builds',
    ),

    trailing: const Icon(
      Icons.chevron_right,
    ),

    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SavedBuildsScreen(),
        ),
      );
    },
  ),
),

            const SizedBox(height: 25),

            // =========================
            // SETTINGS
            // =========================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Notifications
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.notifications_outlined,
                ),

                title: const Text(
                  'Notifications',
                ),

                subtitle: const Text(
                  'Manage notification preferences',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ),

            // Help & Support
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.help_outline,
                ),

                title: const Text(
                  'Help & Support',
                ),

                subtitle: const Text(
                  'Get assistance with your orders',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SupportScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // LOGOUT
            // =========================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                          'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, false);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, true);
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout != true || !context.mounted) {
                    return;
                  }

                  await context.read<AuthProvider>().logout();

                  if (!context.mounted) {
                    return;
                  }

                  context.go(RouteNames.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}