import 'package:flutter/material.dart';

import '../providers/inventory_provider.dart';

class StockMovementTile extends StatelessWidget {
  final StockMovement movement;

  const StockMovementTile({
    super.key,
    required this.movement,
  });

  @override
  Widget build(BuildContext context) {
    final isStockIn =
        movement.type == 'Stock In';

    final color =
        isStockIn ? Colors.green : Colors.red;

    final icon =
        isStockIn
            ? Icons.add_circle_outline
            : Icons.remove_circle_outline;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              color.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 6,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '${movement.type} • ${movement.quantity} unit(s)',
              ),
              const SizedBox(height: 4),
              Text(
                'Reason: ${movement.reason}',
              ),
              const SizedBox(height: 4),
              Text(
                'Stock: ${movement.previousStock} → ${movement.newStock}',
              ),
              if (movement.performedByName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'By: ${movement.performedByName} (${movement.performedByRole})',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
              if (movement.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Notes: ${movement.notes}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}