import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),

      body: Consumer<SalesProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Sales Report',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Overview of sales performance and product sales.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // ==============================
                // SUMMARY CARDS
                // ==============================

                Wrap(
                  spacing: 16,
                  runSpacing: 16,

                  children: [
                    _ReportCard(
                      title: 'Total Revenue',
                      value:
                          '₱${provider.totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.payments_outlined,
                    ),

                    _ReportCard(
                      title: 'Total Orders',
                      value:
                          provider.totalOrders.toString(),
                      icon: Icons.shopping_cart_outlined,
                    ),

                    _ReportCard(
                      title: 'Units Sold',
                      value:
                          provider.totalUnitsSold.toString(),
                      icon: Icons.inventory_2_outlined,
                    ),

                    _ReportCard(
                      title: 'Average Order Value',
                      value:
                          '₱${provider.averageOrderValue.toStringAsFixed(2)}',
                      icon: Icons.analytics_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ==============================
                // SALES SUMMARY
                // ==============================

                _ReportSection(
                  title: 'Sales Summary',

                  child: Column(
                    children: [
                      _ReportRow(
                        label: 'Today Sales',
                        value:
                            '₱${provider.todaySales.toStringAsFixed(2)}',
                      ),

                      _ReportRow(
                        label: 'Total Revenue',
                        value:
                            '₱${provider.totalRevenue.toStringAsFixed(2)}',
                      ),

                      _ReportRow(
                        label: 'Total Orders',
                        value:
                            provider.totalOrders.toString(),
                      ),

                      _ReportRow(
                        label: 'Total Units Sold',
                        value:
                            provider.totalUnitsSold.toString(),
                      ),

                      _ReportRow(
                        label: 'Top Product',
                        value:
                            provider.topProduct,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==============================
                // PRODUCT SALES
                // ==============================

                _ReportSection(
                  title: 'Product Sales',

                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Product',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              'Units',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              'Revenue',
                              textAlign:
                                  TextAlign.right,
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      ...provider.sales.map(
                        (sale) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 12,
                            ),

                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    sale.productName,
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    sale.quantitySold
                                        .toString(),
                                    textAlign:
                                        TextAlign.center,
                                  ),
                                ),

                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₱${sale.revenue.toStringAsFixed(2)}',
                                    textAlign:
                                        TextAlign.right,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==============================
                // BEST SELLER
                // ==============================

                _ReportSection(
                  title: 'Best Selling Product',

                  child: ListTile(
                    contentPadding:
                        EdgeInsets.zero,

                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.star,
                      ),
                    ),

                    title: Text(
                      provider
                          .bestSellingProduct
                          .productName,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      '${provider.bestSellingProduct.quantitySold} units sold',
                    ),

                    trailing: Text(
                      '₱${provider.bestSellingProduct.revenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ========================================
// REPORT CARD
// ========================================

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 250,

      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Row(
            children: [
              CircleAvatar(
                child: Icon(icon),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// REPORT SECTION
// ========================================

class _ReportSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ReportSection({
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }
}

// ========================================
// REPORT ROW
// ========================================

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}