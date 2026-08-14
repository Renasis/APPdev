import 'package:flutter/material.dart';

import '../providers/purchase_order_provider.dart';

class PurchaseOrderTile extends StatelessWidget {
  final PurchaseOrder order;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PurchaseOrderTile({
    super.key,
    required this.order,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        onTap: onTap,

        leading: const CircleAvatar(
          child: Icon(
            Icons.receipt_long,
          ),
        ),

        title: Text(
          order.id,
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              order.supplierName,
            ),

            Text(
              'Status: ${order.status}',
            ),

            Text(
              '₱${order.totalAmount.toStringAsFixed(2)}',
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: onEdit,
            ),

            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}