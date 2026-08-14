import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/stock_movement_tile.dart';

class StockMovementScreen extends StatelessWidget {
  const StockMovementScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Movement History',
        ),
      ),

      body: Consumer<InventoryProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.movements.isEmpty) {
            return const Center(
              child: Text(
                'No stock movements found.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount:
                provider.movements.length,

            itemBuilder:
                (context, index) {
              final movement =
                  provider.movements[index];

              return StockMovementTile(
                movement: movement,
              );
            },
          );
        },
      ),
    );
  }
}