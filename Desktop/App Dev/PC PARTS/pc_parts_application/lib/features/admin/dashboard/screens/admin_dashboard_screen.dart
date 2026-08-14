import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../sales/providers/sales_provider.dart';
import '../../customers/providers/customer_provider.dart';
import '../../products/providers/admin_product_provider.dart';

import '../../products/screens/product_list_screen.dart';
import '../../purchase_orders/screens/purchase_order_list_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../inventory/screens/stock_out_screen.dart';
import '../../settings/screens/admin_settings_screen.dart';
import '../../inventory/providers/inventory_provider.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final salesProvider =
        context.watch<SalesProvider>();

    final customerProvider =
        context.watch<CustomerProvider>();

    final productProvider =
        context.watch<AdminProductProvider>();

    final inventoryProvider =
    context.watch<InventoryProvider>();

    final lowStockItems = inventoryProvider.items
        .where(
          (item) => item.stock > 2 && item.stock <= 5,
        )
        .toList();

    final criticalStockItems = inventoryProvider.items
        .where(
          (item) => item.stock <= 2,
        )
        .toList();

    final stockAlertItems = [
      ...criticalStockItems,
      ...lowStockItems,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Welcome Admin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Manage business operations and monitor performance.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // KPI CARDS
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Revenue',
                  value:
                      '₱${salesProvider.totalRevenue.toStringAsFixed(0)}',
                  icon:
                      Icons.payments_outlined,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _KpiCard(
                  title: 'Orders',
                  value:
                      salesProvider.totalOrders
                          .toString(),
                  icon:
                      Icons.shopping_cart_outlined,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _KpiCard(
                  title: 'Customers',
                  value:
                      customerProvider.customers.length
                          .toString(),
                  icon:
                      Icons.people_outline,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _KpiCard(
                  title: 'Products',
                  value:
                      productProvider.products.length
                          .toString(),
                  icon:
                      Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                flex: 2,

                child: Column(
                  children: [
                    _DashboardSection(
                      title: 'Quick Actions',

                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,

                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ProductListScreen(),
                                ),
                              );
                            },

                            icon:
                                const Icon(Icons.add),

                            label:
                                const Text(
                              'Add Product',
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PurchaseOrderListScreen(),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons.receipt_long,
                            ),

                            label:
                                const Text(
                              'Create PO',
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const InventoryScreen(),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons.arrow_downward,
                            ),

                            label:
                                const Text(
                              'Stock In',
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const StockOutScreen(),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons.arrow_upward,
                            ),

                            label:
                                const Text(
                              'Stock Out',
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminSettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),

                    const SizedBox(height: 20),

                    const _DashboardSection(
                      title: 'Recent Activities',

                      child: Column(
                        children: [
                          ListTile(
                            leading:
                                Icon(
                              Icons.receipt_long,
                            ),

                            title:
                                Text(
                              'PO-003 created',
                            ),
                          ),

                          ListTile(
                            leading:
                                Icon(
                              Icons.inventory,
                            ),

                            title:
                                Text(
                              'RTX 4060 stock received',
                            ),
                          ),

                          ListTile(
                            leading:
                                Icon(
                              Icons.person_add,
                            ),

                            title:
                                Text(
                              'Staff account created',
                            ),
                          ),

                          ListTile(
                            leading:
                                Icon(
                              Icons.shopping_bag,
                            ),

                            title:
                                Text(
                              'Customer order completed',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  children: [
                    _DashboardSection(
                      title: 'Inventory Status',

                      child: Column(
                        children: [
                          ListTile(
                          title: const Text('Products'),
                          trailing: Text(
                            inventoryProvider.items.length.toString(),
                          ),
                        ),

                        ListTile(
                          title: const Text('Low Stock'),
                          trailing: Text(
                            lowStockItems.length.toString(),
                          ),
                        ),

                        ListTile(
                          title: const Text('Critical'),
                          trailing: Text(
                            criticalStockItems.length.toString(),
                          ),
                        ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _DashboardSection(
                      title: 'Sales Snapshot',

                      child: Column(
                        children: [
                          ListTile(
                            title:
                                const Text(
                              'Today',
                            ),

                            trailing:
                                Text(
                              '₱${salesProvider.todaySales.toStringAsFixed(0)}',
                            ),
                          ),

                          ListTile(
                            title:
                                const Text(
                              'Top Product',
                            ),

                            trailing:
                                Text(
                              salesProvider
                                  .topProduct,
                            ),
                          ),

                          ListTile(
                            title:
                                const Text(
                              'Units Sold',
                            ),

                            trailing:
                                Text(
                              salesProvider
                                  .totalUnitsSold
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _DashboardSection(
                      title: 'Business Insights',

                      child: Column(
                        children: [
                          ListTile(
                            leading:
                                const Icon(
                              Icons.star_outline,
                            ),

                            title:
                                const Text(
                              'Best Seller',
                            ),

                            trailing:
                                Text(
                              salesProvider
                                  .bestSellingProduct
                                  .productName,
                            ),
                          ),

                          ListTile(
                            leading:
                                const Icon(
                              Icons.attach_money,
                            ),

                            title:
                                const Text(
                              'Avg Order Value',
                            ),

                            trailing:
                                Text(
                              '₱${salesProvider.averageOrderValue.toStringAsFixed(0)}',
                            ),
                          ),

                          ListTile(
                            leading:
                                const Icon(
                              Icons.shopping_bag_outlined,
                            ),

                            title:
                                const Text(
                              'Total Units Sold',
                            ),

                            trailing:
                                Text(
                              salesProvider
                                  .totalUnitsSold
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _DashboardSection(
                      title: 'Low Stock Alerts',

                      child: stockAlertItems.isEmpty
    ? const ListTile(
        leading: Icon(Icons.check_circle_outline),
        title: Text(
          'All products have sufficient stock.',
        ),
      )
    : Column(
        children: stockAlertItems.map((item) {
          final isCritical = item.stock <= 2;

          return ListTile(
            leading: Icon(
              isCritical
                  ? Icons.error_outline
                  : Icons.warning_amber_outlined,
              color: isCritical ? Colors.red : Colors.orange,
            ),
            title: Text(item.productName),
            subtitle: Text(
              isCritical
                  ? 'Critical stock level'
                  : 'Low stock',
            ),
            trailing: Text(
              '${item.stock} left',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCritical ? Colors.red : Colors.orange,
              ),
            ),
          );
        }).toList(),
      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            Icon(icon),

            const SizedBox(
              height: 10,
            ),

            Text(
              value,

              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(title),
          ],
        ),
      ),
    );
  }
}

class _DashboardSection
    extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              title,

              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            child,
          ],
        ),
      ),
    );
  }
}
