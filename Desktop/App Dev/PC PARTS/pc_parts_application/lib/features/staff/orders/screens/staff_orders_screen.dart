import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customer/orders/models/order_model.dart';
import '../../../customer/orders/providers/order_provider.dart';
import '../../../customer/orders/widgets/delivery_details_dialog.dart';

class StaffOrdersScreen extends StatelessWidget {
  const StaffOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    if (orders.isEmpty) {
      return const Center(
        child: Text('No customer orders found.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _StaffOrderCard(order: orders[index]),
    );
  }
}

class _StaffOrderCard extends StatelessWidget {
  final OrderModel order;

  const _StaffOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text('Customer: ${order.customerName}'),
            Text('Items: ${order.items.length}'),
            Text('Payment: ${order.paymentMethod}'),
            Text('Payment Status: ${order.paymentStatus}'),
            if (order.deliveryDetails != null)
              Text(
                'Delivery: ${order.deliveryDetails!.courierName} • ${order.deliveryDetails!.trackingNumber}',
              ),
            const SizedBox(height: 6),
            Text(
              'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _action(context),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();

    switch (order.status) {
      case 'Pending':
        if (order.paymentMethod == 'GCash' &&
            order.paymentStatus != 'Verified') {
          return const Text(
            'Awaiting Admin payment verification.',
            style: TextStyle(color: Colors.orange),
          );
        }
        return _ActionButton(
          label: 'Confirm Order',
          icon: Icons.check_circle_outline,
          onPressed: () => orderProvider.confirmOrder(order.id),
        );
      case 'Confirmed':
        return _ActionButton(
          label: 'Process Order',
          icon: Icons.inventory_2_outlined,
          onPressed: () => orderProvider.processOrder(order.id),
        );
      case 'Processing':
        return _ActionButton(
          label: 'Mark Out for Delivery',
          icon: Icons.local_shipping_outlined,
          onPressed: () async {
            final deliveryDetails = await DeliveryDetailsDialog.show(context);
            if (deliveryDetails != null) {
              orderProvider.shipOrder(order.id, deliveryDetails);
            }
          },
        );
      case 'Out for Delivery':
        return const Text(
          'Awaiting Admin completion.',
          style: TextStyle(color: Colors.blueGrey),
        );
      case 'Completed':
        return const Text(
          'Order completed.',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        );
      case 'Cancelled':
        return const Text(
          'Order cancelled.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(status));
  }
}
