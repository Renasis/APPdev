import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_provider.dart';
import '../widgets/customer_tile.dart';
import 'customer_details_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
        ),
      ),

      body: Consumer<CustomerProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Customers',
                            value: provider.customers.length
                                .toString(),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _StatCard(
                            title: 'Orders',
                            value: provider
                                .totalCustomerOrders
                                .toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _StatCard(
                      title: 'Customer Revenue',
                      value:
                          '₱${provider.totalCustomerRevenue.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  itemCount:
                      provider.customers.length,

                  itemBuilder:
                      (context, index) {
                    final customer =
                        provider
                            .customers[index];

                    return CustomerTile(
                      customer: customer,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomerDetailsScreen(
                              customer:
                                  customer,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            Text(title),

            const SizedBox(height: 6),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}