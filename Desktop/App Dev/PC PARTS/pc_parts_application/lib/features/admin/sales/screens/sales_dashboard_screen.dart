import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';
import '../widgets/sales_stat_card.dart';
import 'daily_sales_screen.dart';
import 'monthly_sales_screen.dart';
import 'revenue_report_screen.dart';
import 'top_products_screen.dart';
import 'sales_report_screen.dart';


class SalesDashboardScreen extends StatelessWidget {
  const SalesDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Dashboard',
        ),
      ),

      body: Consumer<SalesProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,

                  children: [
                    SalesStatCard(
                      title:
                          "Today's Sales",
                      value:
                          '₱${provider.todaySales.toStringAsFixed(0)}',
                      icon:
                          Icons.attach_money,
                      color: Colors.green,
                    ),

                    SalesStatCard(
                      title:
                          'Total Revenue',
                      value:
                          '₱${provider.totalRevenue.toStringAsFixed(0)}',
                      icon:
                          Icons.bar_chart,
                      color: Colors.blue,
                    ),

                    SalesStatCard(
                      title: 'Orders',
                      value:
                          provider.totalOrders
                              .toString(),
                      icon:
                          Icons.shopping_cart,
                      color: Colors.orange,
                    ),

                    SalesStatCard(
                      title:
                          'Top Product',
                      value:
                          provider.topProduct,
                      icon:
                          Icons.star_outline,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Top Selling Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.today,
                        ),

                        label: const Text(
                          'Daily Sales',
                        ),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DailySalesScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.calendar_month,
                        ),

                        label: const Text(
                          'Monthly Sales',
                        ),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MonthlySalesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.receipt_long,
                        ),
                        label: const Text(
                          'Revenue Report',
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RevenueReportScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.leaderboard,
                        ),
                        label: const Text(
                          'Top Products',
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TopProductsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.assessment_outlined,
                    ),
                    label: const Text(
                      'Sales Report',
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SalesReportScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                ...provider.sales.map(
                  (sale) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.inventory_2,
                        ),

                        title: Text(
                          sale.productName,
                        ),

                        subtitle: Text(
                          '${sale.quantitySold} sold',
                        ),

                        trailing: Text(
                          '₱${sale.revenue.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}