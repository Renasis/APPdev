import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';



class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final currentOrder =
    context.watch<OrderProvider>()
        .getOrderById(order.id) ?? order;

final status = currentOrder.status;

    final canCancel =
        status == 'Pending' ||
        status == 'Confirmed';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${order.id}',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =========================
            // ORDER HEADER
            // =========================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Status: $status',
                      style: TextStyle(
                        color: _statusColor(status),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // ORDER TRACKING
            // =========================

            const Text(
              'Order Tracking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    _buildTrackingStep(
                      title: 'Order Placed',
                      icon: Icons.receipt_long,
                      completed:
                          _statusIndex(status) >= 0,
                      active:
                          _statusIndex(status) == 0,
                    ),

                    _buildTrackingStep(
                      title: 'Order Confirmed',
                      icon: Icons.check_circle_outline,
                      completed:
                          _statusIndex(status) >= 1,
                      active:
                          _statusIndex(status) == 1,
                    ),

                    _buildTrackingStep(
                      title: 'Preparing',
                      icon: Icons.inventory_2_outlined,
                      completed:
                          _statusIndex(status) >= 2,
                      active:
                          _statusIndex(status) == 2,
                    ),

                    _buildTrackingStep(
                      title: 'Out for Delivery',
                      icon: Icons.local_shipping_outlined,
                      completed:
                          _statusIndex(status) >= 3,
                      active:
                          _statusIndex(status) == 3,
                    ),

                    _buildTrackingStep(
                      title: 'Delivered',
                      icon: Icons.home_outlined,
                      completed:
                          _statusIndex(status) >= 4,
                      active:
                          _statusIndex(status) == 4,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // ORDER ITEMS
            // =========================

            const Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    ...currentOrder.items.map(
                      (item) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),

                                child: const Icon(
                                  Icons.memory,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    Text(
                                      item.displayName,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item.isPcBuild
                                          ? '${item.buildComponents.length} included components'
                                          : 'Quantity: ${item.quantity}',
                                      style: TextStyle(
                                        color: Colors
                                            .grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                '₱${item.totalPrice.toStringAsFixed(2)}',

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          'Order Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          '₱${currentOrder.totalAmount.toStringAsFixed(2)}',

                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // PAYMENT
            // =========================

            const Text(
              'Payment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.payment_outlined,
                ),

                title: const Text(
                  'Payment Method',
                ),

                subtitle: Text(
                  '${currentOrder.paymentMethod}\n${currentOrder.paymentStatus}'
                  '${currentOrder.paymentReference.isEmpty ? '' : '\nReference: ${currentOrder.paymentReference}'}',
                ),
                trailing: _PaymentStatusChip(status: currentOrder.paymentStatus),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // DELIVERY
            // =========================

            const Text(
              'Shipping & Delivery',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Delivery address'),
                      subtitle: Text(currentOrder.deliveryAddress),
                    ),
                    if (currentOrder.deliveryDetails == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Courier and tracking details will appear when the order is dispatched.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else ...[
                      const Divider(),
                      _DeliveryDetailRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Courier',
                        value: currentOrder.deliveryDetails!.courierName,
                      ),
                      _DeliveryDetailRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Tracking number',
                        value: currentOrder.deliveryDetails!.trackingNumber,
                      ),
                      _DeliveryDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Estimated delivery',
                        value: MaterialLocalizations.of(context).formatMediumDate(
                          currentOrder.deliveryDetails!.estimatedDeliveryDate,
                        ),
                      ),
                      if (currentOrder.deliveryDetails!.riderName.isNotEmpty)
                        _DeliveryDetailRow(
                          icon: Icons.person_outline,
                          label: 'Rider',
                          value: currentOrder.deliveryDetails!.riderName,
                        ),
                      if (currentOrder.deliveryDetails!.riderPhoneNumber.isNotEmpty)
                        _DeliveryDetailRow(
                          icon: Icons.phone_outlined,
                          label: 'Rider contact',
                          value: currentOrder.deliveryDetails!.riderPhoneNumber,
                        ),
                      if (currentOrder.deliveryDetails!.deliveryNotes.isNotEmpty)
                        _DeliveryDetailRow(
                          icon: Icons.notes_outlined,
                          label: 'Delivery notes',
                          value: currentOrder.deliveryDetails!.deliveryNotes,
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // CUSTOMER
            // =========================

            const Text(
              'Customer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.person_outline,
                ),

                title: Text(
                  currentOrder.customerName,
                ),

                subtitle: const Text(
                  'Customer',
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // CANCEL ORDER
            // =========================

            if (canCancel)
              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: () {
                    _showCancelDialog(context);
                  },

                  icon: const Icon(
                    Icons.cancel_outlined,
                  ),

                  label: const Text(
                    'Cancel Order',
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(
                      color: Colors.red,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),

            if (!canCancel &&
                status != 'Cancelled' &&
                status != 'Completed')
              const Padding(
                padding:
                    EdgeInsets.only(top: 10),

                child: Center(
                  child: Text(
                    'This order can no longer be cancelled.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            if (status == 'Cancelled')
              const Center(
                child: Text(
                  'This order has been cancelled.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (status == 'Completed')
              const Center(
                child: Text(
                  'This order has been completed.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================
  // CANCEL CONFIRMATION
  // =========================

  void _showCancelDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Order?',
          ),

          content: const Text(
            'Are you sure you want to cancel this order? '
            'This action cannot be undone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Keep Order',
              ),
            ),

            TextButton(
              onPressed: () {
                Provider.of<OrderProvider>(
                  context,
                  listen: false,
                ).cancelOrder(order.id);

                Navigator.pop(dialogContext);

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Order cancelled successfully.',
                    ),
                  ),
                );
              },

              child: const Text(
                'Cancel Order',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // TRACKING STEP
  // =========================

  Widget _buildTrackingStep({
    required String title,
    required IconData icon,
    required bool completed,
    required bool active,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Column(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: completed
                    ? Colors.green
                    : Colors.grey.shade200,
              ),

              child: Icon(
                completed
                    ? Icons.check
                    : icon,

                color: completed
                    ? Colors.white
                    : Colors.grey,
              ),
            ),

            if (!isLast)
              Container(
                width: 2,
                height: 35,
                color: completed
                    ? Colors.green
                    : Colors.grey.shade300,
              ),
          ],
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 10,
            ),

            child: Text(
              title,

              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    active || completed
                        ? FontWeight.bold
                        : FontWeight.normal,

                color: active
                    ? Colors.green
                    : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // STATUS INDEX
  // =========================

  int _statusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'order placed':
      case 'pending':
        return 0;

      case 'confirmed':
      case 'order confirmed':
        return 1;

      case 'preparing':
      case 'processing':
        return 2;

      case 'out for delivery':
      case 'shipped':
        return 3;

      case 'delivered':
      case 'completed':
        return 4;

      case 'cancelled':
        return -1;

      default:
        return 0;
    }
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'out for delivery':
      case 'shipped':
        return Colors.blue;

      case 'preparing':
      case 'processing':
        return Colors.orange;

      case 'confirmed':
        return Colors.blue;

      case 'pending':
      case 'placed':
      default:
        return Colors.grey;
    }
  }
}

class _DeliveryDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DeliveryDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  final String status;

  const _PaymentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Verified' => Colors.green,
      'Rejected' => Colors.red,
      'Payment on Delivery' => Colors.blue,
      _ => Colors.orange,
    };
    return Chip(
      label: Text(status),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
    );
  }
}
