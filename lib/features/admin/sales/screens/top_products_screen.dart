import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';

class TopProductsScreen extends StatelessWidget {
  const TopProductsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Products',
        ),
      ),

      body: Consumer<SalesProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final products =
              [...provider.sales];

          products.sort(
            (a, b) => b.quantitySold
                .compareTo(
              a.quantitySold,
            ),
          );

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),

            itemCount:
                products.length,

            itemBuilder:
                (context, index) {
              final item =
                  products[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '#${index + 1}',
                    ),
                  ),

                  title: Text(
                    item.productName,
                  ),

                  subtitle: Text(
                    '${item.quantitySold} sold',
                  ),

                  trailing: Text(
                    '₱${item.revenue.toStringAsFixed(0)}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}