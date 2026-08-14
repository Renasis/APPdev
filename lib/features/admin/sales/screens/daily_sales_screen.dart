import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';

class DailySalesScreen extends StatelessWidget {
  const DailySalesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Sales',
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
                      const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Today Revenue',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        '₱${provider.todaySales.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Products Sold Today',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...provider.sales.map(
                (sale) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        sale.productName,
                      ),

                      subtitle: Text(
                        '${sale.quantitySold} units sold',
                      ),

                      trailing: Text(
                        '₱${sale.revenue.toStringAsFixed(0)}',
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}