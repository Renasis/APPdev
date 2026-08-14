import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../inventory/staff_inventory_screen.dart';
import '../../orders/screens/staff_orders_screen.dart';
import '../../notifications/providers/staff_notification_provider.dart';
import '../../notifications/screens/staff_notifications_screen.dart';
import '../../profile/screens/staff_profile_screen.dart';

class StaffShellScreen extends StatefulWidget {
  const StaffShellScreen({super.key});

  @override
  State<StaffShellScreen> createState() => _StaffShellScreenState();
}

class _StaffShellScreenState extends State<StaffShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(showAppBar: false),
    StaffOrdersScreen(),
    StaffInventoryScreen(),
    StaffNotificationsScreen(),
    StaffProfileScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Orders',
    'Inventory',
    'Notifications',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 220,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index >= _pages.length) {
                return;
              }

              setState(() => _selectedIndex = index);
            },
            leading: const Padding(
              padding: EdgeInsets.only(top: 20, left: 12, right: 12),
              child: Column(
                children: [
                  Icon(Icons.computer, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'END PC PARTS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warehouse_outlined),
                selectedIcon: Icon(Icons.warehouse),
                label: Text('Inventory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_none),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _titles[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Consumer<StaffNotificationProvider>(
                        builder: (context, provider, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                tooltip: 'Notifications',
                                onPressed: () {
                                  setState(() => _selectedIndex = 3);
                                },
                                icon: const Icon(Icons.notifications_none),
                              ),
                              if (provider.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 9,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      provider.unreadCount > 9
                                          ? '9+'
                                          : provider.unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 8),
                      const Text(
                        'Staff',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _pages[_selectedIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
