import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';

class InventoryTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onAdjust;

  const InventoryTile({
    super.key,
    required this.item,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (item.status) {
      case 'Critical':
        statusColor = Colors.red;
        break;

      case 'Low Stock':
        statusColor = Colors.orange;
        break;

      default:
        statusColor = Colors.green;
    }

    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.inventory_2_outlined,
        ),
        title: Text(item.productName),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Stock: ${item.stock}',
            ),
            Text(
              item.status,
              style: TextStyle(
                color: statusColor,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.edit,
          ),
          onPressed: onAdjust,
        ),
      ),
    );
  }
}