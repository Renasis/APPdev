import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customer/orders/providers/order_provider.dart';
import '../../../customer/orders/models/order_model.dart';
import '../../../customer/orders/widgets/delivery_details_dialog.dart';
import '../../inventory/providers/inventory_provider.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
      ),
      body: Consumer<OrderProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.orders.isEmpty) {
            return const Center(
              child: Text(
                'No customer orders found.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.orders.length,
            itemBuilder: (
              context,
              index,
            ) {
              final order = provider.orders[index];

              return _OrderCard(
                order: order,
                provider: provider,
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderProvider provider;

  const _OrderCard({
    required this.order,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                _StatusChip(
                  status: order.status,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Customer: ${order.customerName}',
            ),

            Text(
              'Phone: ${order.phoneNumber}',
            ),

            Text(
              'Address: ${order.deliveryAddress}',
            ),

            const SizedBox(height: 8),

            Text(
              'Payment: ${order.paymentMethod}',
            ),

            if (order.deliveryDetails != null)
              Text(
                'Delivery: ${order.deliveryDetails!.courierName} • ${order.deliveryDetails!.trackingNumber}',
              ),

            const SizedBox(height: 8),

            Text(
              'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Items',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...order.items.map(
              (item) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  child: Text(
                    '${item.product.name} × ${item.quantity}',
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
  ) {
    switch (order.status) {
      case 'Pending':
        return ElevatedButton.icon(
          onPressed: () {
            provider.confirmOrder(order.id);
          },
          icon: const Icon(
            Icons.check,
          ),
          label: const Text(
            'Confirm Order',
          ),
        );

      case 'Confirmed':
        return ElevatedButton.icon(
          onPressed: () {
            provider.processOrder(order.id);
          },
          icon: const Icon(
            Icons.inventory_2_outlined,
          ),
          label: const Text(
            'Process Order',
          ),
        );

      case 'Processing':
        return ElevatedButton.icon(
          onPressed: () async {
            final deliveryDetails = await DeliveryDetailsDialog.show(context);
            if (deliveryDetails != null) {
              provider.shipOrder(order.id, deliveryDetails);
            }
          },
          icon: const Icon(
            Icons.local_shipping_outlined,
          ),
          label: const Text(
            'Ship Order',
          ),
        );

      case 'Out for Delivery':
        return ElevatedButton.icon(
          onPressed: () {
            final shortages = context
                .read<InventoryProvider>()
                .stockShortagesForOrder(order);

            if (shortages.isNotEmpty) {
              final details = shortages
                  .map(
                    (shortage) =>
                        '${shortage.productName}: ${shortage.availableQuantity} available, ${shortage.requestedQuantity} required',
                  )
                  .join('\n');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cannot complete order: insufficient stock.\n$details',
                  ),
                ),
              );
              return;
            }

            provider.completeOrder(order.id);
          },
          icon: const Icon(
            Icons.check_circle_outline,
          ),
          label: const Text(
            'Complete Order',
          ),
        );

      case 'Completed':
        return const Text(
          'Order completed',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        );

      case 'Cancelled':
        return const Text(
          'Order cancelled',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status),
    );
  }
}
