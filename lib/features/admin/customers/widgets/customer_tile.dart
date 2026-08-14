import 'package:flutter/material.dart';

import '../providers/customer_provider.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          child: Text(
            customer.name[0],
          ),
        ),

        title: Text(
          customer.name,
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(customer.email),
            Text(
              'Orders: ${customer.totalOrders}',
            ),
          ],
        ),

        trailing: Text(
          '₱${customer.totalSpent.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}