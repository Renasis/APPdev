import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../admin/inventory/providers/inventory_provider.dart';
import '../../../customer/orders/providers/order_provider.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  final bool showAppBar;

  const DashboardScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final inventory = context.watch<InventoryProvider>();
    final today = DateTime.now();

    final todayOrders = orders.where((order) {
      final date = order.orderDate;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
    final pendingOrders =
        orders.where((order) => order.status == 'Pending').length;
    final completedToday = orders.where((order) {
      final date = order.orderDate;
      return order.status == 'Completed' &&
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
    final lowStock = inventory.items.where((item) => item.stock <= 5).length;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Staff Dashboard'),
            )
          : null,

      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 1000 ? 4 : 2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text(
              'Welcome Staff',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage daily store operations.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                  DashboardCard(
                    title: 'Today Orders',
                    value: todayOrders.toString(),
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.blue,
                  ),

                  DashboardCard(
                    title: 'Pending',
                    value: pendingOrders.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),

                  DashboardCard(
                    title: 'Low Stock',
                    value: lowStock.toString(),
                    icon: Icons.warning_amber,
                    color: Colors.red,
                  ),

                  DashboardCard(
                    title: 'Completed Today',
                    value: completedToday.toString(),
                    icon: Icons.task_alt,
                    color: Colors.green,
                  ),
              ],
            ),
              ],
            ),
          );
        },
      ),
    );
  }
}
