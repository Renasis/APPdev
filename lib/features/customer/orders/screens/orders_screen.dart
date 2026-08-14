import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider =
        Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
        ),
      ),

      body: orderProvider.orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Your orders will appear here.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )

          : ListView.builder(
              padding:
                  const EdgeInsets.all(12),

              itemCount:
                  orderProvider.orders.length,

              itemBuilder:
                  (context, index) {

                final order =
                    orderProvider.orders[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(12),

                    onTap: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsScreen(
                            order: order,
                          ),
                        ),
                      );

                    },

                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // Order Header
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              const Text(
                                'Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(
                                '#${order.id}',

                                style: TextStyle(
                                  color:
                                      Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),

                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // Total
                          Text(
                            '₱${order.totalAmount.toStringAsFixed(2)}',

                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // Payment Method
                          Row(
                            children: [

                              const Icon(
                                Icons.payment,
                                size: 18,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Text(
                                order.paymentMethod,
                              ),

                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          // Order Date
                          Row(
                            children: [

                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Text(
                                _formatDate(
                                  order.orderDate,
                                ),
                              ),

                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // Status + Arrow
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      _statusColor(
                                    order.status,
                                  ).withValues(
                                    alpha: 0.1,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),

                                child: Text(
                                  order.status,

                                  style: TextStyle(
                                    color:
                                        _statusColor(
                                      order.status,
                                    ),

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),

                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {

    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {

    switch (status) {

      case 'Completed':
        return Colors.green;

      case 'Processing':
        return Colors.orange;

      case 'Confirmed':
        return Colors.blue;

      case 'Cancelled':
        return Colors.red;

      case 'Pending':
      default:
        return Colors.orange;
    }
  }
}