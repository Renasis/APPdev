import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';

class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Revenue Report',
        ),
      ),

      body: Consumer<SalesProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return ListView(
            padding:
                const EdgeInsets.all(16),

            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      const Text(
                        'Total Revenue',
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        '₱${provider.totalRevenue.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.today,
                  ),
                  title: const Text(
                    'Today Sales',
                  ),
                  trailing: Text(
                    '₱${provider.todaySales.toStringAsFixed(2)}',
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.shopping_cart,
                  ),
                  title: const Text(
                    'Total Orders',
                  ),
                  trailing: Text(
                    provider.totalOrders
                        .toString(),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.star,
                  ),
                  title: const Text(
                    'Top Product',
                  ),
                  trailing: Text(
                    provider.topProduct,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}