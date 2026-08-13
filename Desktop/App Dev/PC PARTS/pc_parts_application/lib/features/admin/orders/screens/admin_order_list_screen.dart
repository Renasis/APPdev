import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customer/orders/providers/order_provider.dart';
import '../../../customer/orders/widgets/delivery_details_dialog.dart';
import '../../inventory/providers/inventory_provider.dart';

class AdminOrderListScreen extends StatelessWidget {
  const AdminOrderListScreen({
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

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${index + 1}',
                    ),
                  ),

                  title: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      Text(
                        'Customer: ${order.customerName}',
                      ),

                      Text(
                        'Items: ${order.items.length}',
                      ),

                      Text(
                        'Payment: ${order.paymentMethod}',
                      ),

                      if (order.deliveryDetails != null)
                        Text(
                          'Delivery: ${order.deliveryDetails!.courierName} • ${order.deliveryDetails!.trackingNumber}',
                        ),

                      Text(
                        'Payment Status: ${order.paymentStatus}',
                        style: TextStyle(
                          color: _paymentColor(order.paymentStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Status: ${order.status}',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              _statusColor(
                            order.status,
                          ),
                        ),
                      ),
                    ],
                  ),

                  isThreeLine: true,

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    _showOrderActions(
                      context,
                      provider,
                      order.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderActions(
    BuildContext context,
    OrderProvider provider,
    String orderId,
  ) {
    final order =
        provider.getOrderById(orderId);

    if (order == null) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (
        sheetContext,
      ) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Customer: ${order.customerName}',
                ),

                Text(
                  'Current Status: ${order.status}',
                ),

                Text(
                  'Payment: ${order.paymentMethod} — ${order.paymentStatus}',
                ),

                if (order.paymentReference.isNotEmpty)
                  Text('Reference: ${order.paymentReference}'),

                const SizedBox(height: 20),

                if (order.paymentMethod == 'GCash' &&
                    order.paymentStatus == 'Awaiting Verification') ...[
                  _actionButton(
                    context: sheetContext,
                    label: 'Verify GCash Payment',
                    icon: Icons.verified_outlined,
                    onPressed: () {
                      provider.verifyPayment(order.id);
                      return true;
                    },
                  ),
                  _actionButton(
                    context: sheetContext,
                    label: 'Reject GCash Payment',
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      provider.rejectPayment(order.id);
                      return true;
                    },
                  ),
                ],

                if (order.status == 'Pending')
                  _actionButton(
                    context: sheetContext,
                    label: 'Confirm Order',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      provider.confirmOrder(
                        order.id,
                      );
                      return true;
                    },
                  ),

                if (order.status == 'Confirmed')
                  _actionButton(
                    context: sheetContext,
                    label: 'Process Order',
                    icon: Icons.inventory_2_outlined,
                    onPressed: () {
                      provider.processOrder(
                        order.id,
                      );
                      return true;
                    },
                  ),

                if (order.status == 'Processing')
                  _actionButton(
                    context: sheetContext,
                    label: 'Ship Order',
                    icon: Icons.local_shipping_outlined,
                    onPressed: () async {
                      final deliveryDetails =
                          await DeliveryDetailsDialog.show(sheetContext);
                      if (deliveryDetails == null) {
                        return false;
                      }
                      provider.shipOrder(order.id, deliveryDetails);
                      return true;
                    },
                  ),

                if (order.status == 'Out for Delivery')
                  _actionButton(
                    context: sheetContext,
                    label: 'Complete Order',
                    icon: Icons.check_circle,
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
                        return false;
                      }

                      provider.completeOrder(
                        order.id,
                      );
                      return true;
                    },
                  ),

                if (order.status == 'Pending' ||
                    order.status == 'Confirmed')
                  _actionButton(
                    context: sheetContext,
                    label: 'Cancel Order',
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      provider.cancelOrder(
                        order.id,
                      );
                      return true;
                    },
                  ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                        sheetContext,
                      );
                    },
                    child: const Text(
                      'Close',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required FutureOr<bool> Function() onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (await onPressed()) {
            if (!context.mounted) {
              return;
            }
            Navigator.pop(context);
          }
        },
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;

      case 'Cancelled':
        return Colors.red;

      case 'Out for Delivery':
        return Colors.blue;

      case 'Processing':
        return Colors.orange;

      case 'Confirmed':
        return Colors.teal;

      default:
        return Colors.grey;
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'Verified':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Payment on Delivery':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
