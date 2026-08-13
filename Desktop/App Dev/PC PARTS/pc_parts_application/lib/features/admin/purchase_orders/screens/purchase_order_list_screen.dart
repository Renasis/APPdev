import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/purchase_order_provider.dart';
import '../widgets/purchase_order_tile.dart';
import 'create_purchase_order_screen.dart';
import 'purchase_order_details_screen.dart';


class PurchaseOrderListScreen
    extends StatelessWidget {
  const PurchaseOrderListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchase Orders',
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreatePurchaseOrderScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Consumer<
          PurchaseOrderProvider>(
        builder:
            (context, provider, child) {
          return ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount:
                provider.purchaseOrders.length,

            itemBuilder:
                (context, index) {
              final order =
                  provider.purchaseOrders[index];

              return PurchaseOrderTile(
                order: order,

                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PurchaseOrderDetailsScreen(
                      purchaseOrder: order,
                    ),
                  ),
                );
              },

                onEdit: () {},

                onDelete: () {
                  provider
                      .deletePurchaseOrder(
                    order.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}