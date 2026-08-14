import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';

class MonthlySalesScreen extends StatelessWidget {
  const MonthlySalesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Sales',
        ),
      ),

      body: Consumer<SalesProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    child: Column(
                      children: [
                        const Text(
                          'Monthly Revenue',
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

                Expanded(
                  child: ListView(
                    children:
                        provider.sales.map(
                      (sale) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              sale.productName,
                            ),

                            subtitle: Text(
                              '${sale.quantitySold} sold',
                            ),

                            trailing: Text(
                              '₱${sale.revenue.toStringAsFixed(0)}',
                            ),
                          ),
                        );
                      },
                    ).toList(),
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