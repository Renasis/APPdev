import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../dashboard/screens/admin_dashboard_screen.dart';
import '../../products/screens/product_list_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../purchase_orders/screens/purchase_order_list_screen.dart';
import '../../staff/screens/staff_list_screen.dart';
import '../../customers/screens/customer_list_screen.dart';
import '../../orders/screens/admin_order_list_screen.dart';
import '../../sales/screens/sales_dashboard_screen.dart';
import '../../reports/screens/reports_dashboard_screen.dart';
import '../../settings/screens/admin_settings_screen.dart';
import '../../inventory/screens/stock_movement_screen.dart';
import '../../sales/screens/walk_in_sale_screen.dart';
import 'package:pc_parts_application/features/admin/support/screens/admin_support_screen.dart';
import 'package:pc_parts_application/features/admin/notifications/providers/notification_provider.dart';
import 'package:pc_parts_application/features/admin/notifications/screens/notification_center_screen.dart';

import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/routes/route_names.dart';
import 'package:pc_parts_application/core/enums/user_role.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({
    super.key,
  });

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AdminDashboardScreen(),
    ProductListScreen(),
    InventoryScreen(),
    StockMovementScreen(),
    PurchaseOrderListScreen(),
    WalkInSaleScreen(),
    StaffListScreen(),
    CustomerListScreen(),
    AdminOrderListScreen(),
    AdminSupportScreen(),
    SalesDashboardScreen(),
    ReportsDashboardScreen(),
    AdminSettingsScreen(),
  ];

    final List<String> titles = [
      'Dashboard',
      'Products',
      'Inventory',
      'Stock Movements',
      'Purchase Orders',
      'POS / Walk-In Sales',
      'Staff',
      'Customers',
      'Orders',
      'Support / Inquiries',
      'Sales',
      'Reports',
      'Settings',
    ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.role != UserRole.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/');
        }
      });

      return const Scaffold(
        body: Center(
          child: Text('Access denied.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Portal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                context.go(RouteNames.roleSelection);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 220,
              selectedIndex: selectedIndex,

            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },

             destinations: const [
               NavigationRailDestination(
                 icon: Icon(Icons.dashboard_outlined),
                 label: Text('Dashboard'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.inventory_2_outlined),
                 label: Text('Products'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.warehouse_outlined),
                 label: Text('Inventory'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.history_outlined),
                 label: Text('Stock Movements'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.receipt_long),
                 label: Text('PO'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.point_of_sale_outlined),
                 label: Text('POS'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.people_outline),
                 label: Text('Staff'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.people_alt_outlined),
                 label: Text('Customers'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.shopping_bag_outlined),
                 label: Text('Orders'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.support_agent_outlined),
                 label: Text('Support'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.bar_chart),
                 label: Text('Sales'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.analytics_outlined),
                 label: Text('Reports'),
               ),

               NavigationRailDestination(
                 icon: Icon(Icons.settings),
                 label: Text('Settings'),
               ),
             ],

            leading: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 12,
                right: 12,
              ),

              child: Column(
                children: const [
                  Icon(
                    Icons.computer,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'END PC PARTS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const VerticalDivider(
            width: 1,
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),

                  child: Row(
                    children: [
                      Text(
                        titles[selectedIndex],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Consumer<NotificationProvider>(
                        builder: (context, provider, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                tooltip: 'Notifications',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationCenterScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_none,
                                ),
                              ),

                              if (provider.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      provider.unreadCount > 99
                                          ? '99+'
                                          : provider.unreadCount.toString(),
                                      textAlign: TextAlign.center,
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

                      const SizedBox(width: 12),

                      Row(
                        children: const [
                          CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                ),

                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,

                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1200,
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: pages[selectedIndex],
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
