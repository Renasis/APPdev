import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../sales/providers/sales_provider.dart';
import '../../customers/providers/customer_provider.dart';
import '../../products/providers/admin_product_provider.dart';
import '../../purchase_orders/providers/purchase_order_provider.dart';
import '../providers/reports_provider.dart';



class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({
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

    final purchaseOrderProvider =
        context.watch<PurchaseOrderProvider>();
    
    final reportsProvider =
        context.watch<ReportsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Reports & Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _AnalyticsCard(
                  title: 'Revenue',
                  value:
                      '₱${salesProvider.totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _AnalyticsCard(
                  title: 'Orders',
                  value: salesProvider.totalOrders
                      .toString(),
                  icon:
                      Icons.shopping_cart_outlined,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _AnalyticsCard(
                  title: 'Customers',
                  value: customerProvider
                      .customers.length
                      .toString(),
                  icon:
                      Icons.people_outline,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _AnalyticsCard(
                  title: 'Products',
                  value: productProvider
                      .totalProducts
                      .toString(),
                  icon:
                      Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Sales Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Top Revenue Product',
                          value: reportsProvider.highestRevenueProduct,
                          icon: Icons.star_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Lowest Stock Product',
                          value: reportsProvider.lowestStockProduct,
                          icon: Icons.warning_amber_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Inventory Value',
                          value:
                              '₱${reportsProvider.inventoryValue.toStringAsFixed(0)}',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'PO Value',
                          value:
                              '₱${reportsProvider.totalPurchaseOrderValue.toStringAsFixed(0)}',
                          icon: Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(
                      Icons.attach_money,
                    ),
                    title: const Text(
                      'Today Sales',
                    ),
                    trailing: Text(
                      '₱${salesProvider.todaySales.toStringAsFixed(0)}',
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.star_outline,
                    ),
                    title: const Text(
                      'Best Selling Product',
                    ),
                    trailing: Text(
                      salesProvider.bestSellingProduct.productName,
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                    ),
                    title: const Text(
                      'Units Sold',
                    ),
                    trailing: Text(
                      salesProvider.totalUnitsSold.toString(),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.bar_chart,
                    ),
                    title: const Text(
                      'Average Order Value',
                    ),
                    trailing: Text(
                      '₱${salesProvider.averageOrderValue.toStringAsFixed(0)}',
                    ),
                  ),

                  
                ],
                
              ),

            ),

            
          ),
          
          

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Inventory Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(
                      Icons.inventory,
                    ),
                    title: const Text(
                      'Total Products',
                    ),
                    trailing: Text(
                      productProvider
                          .totalProducts
                          .toString(),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.warning_amber,
                    ),
                    title: const Text(
                      'Low Stock Products',
                    ),
                    trailing: Text(
                      productProvider
                          .lowStockCount
                          .toString(),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.error_outline,
                    ),
                    title: const Text(
                      'Critical Stock',
                    ),
                    trailing: Text(
                      productProvider
                          .criticalStockCount
                          .toString(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Purchase Order Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                    ),
                    title: const Text(
                      'Total Purchase Orders',
                    ),
                    trailing: Text(
                      purchaseOrderProvider
                          .purchaseOrders.length
                          .toString(),
                    ),
                  ),

                  ...purchaseOrderProvider
                      .purchaseOrders
                      .map(
                    (order) {
                      return ListTile(
                        leading: const Icon(
                          Icons.local_shipping,
                        ),
                        title: Text(
                          order.id,
                        ),
                        subtitle: Text(
                          order.status,
                        ),
                        trailing: Text(
                          '₱${order.totalAmount.toStringAsFixed(0)}',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Customer Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(
                      Icons.people,
                    ),
                    title: const Text(
                      'Total Customers',
                    ),
                    trailing: Text(
                      customerProvider
                          .customers.length
                          .toString(),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.shopping_cart,
                    ),
                    title: const Text(
                      'Customer Orders',
                    ),
                    trailing: Text(
                      customerProvider
                          .totalCustomerOrders
                          .toString(),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.attach_money,
                    ),
                    title: const Text(
                      'Customer Revenue',
                    ),
                    trailing: Text(
                      '₱${customerProvider.totalCustomerRevenue.toStringAsFixed(0)}',
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.workspace_premium,
                    ),
                    title: const Text(
                      'Top Customer',
                    ),
                    trailing: Text(
                      customerProvider
                          .customers
                          .reduce(
                            (a, b) =>
                                a.totalSpent >
                                        b.totalSpent
                                    ? a
                                    : b,
                          )
                          .name,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(title),
          ],
        ),
      ),
    );
  }
}