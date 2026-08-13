import 'package:flutter/material.dart';

import '../providers/customer_provider.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Details',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    child: Text(
                      customer.name[0],
                      style:
                          const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    customer.name,
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(customer.email),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.phone),
              title:
                  const Text('Phone'),
              subtitle:
                  Text(customer.phone),
            ),
          ),

          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.shopping_bag),
              title: const Text(
                'Total Orders',
              ),
              trailing: Text(
                customer.totalOrders
                    .toString(),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.payments),
              title: const Text(
                'Total Spending',
              ),
              trailing: Text(
                '₱${customer.totalSpent.toStringAsFixed(2)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}