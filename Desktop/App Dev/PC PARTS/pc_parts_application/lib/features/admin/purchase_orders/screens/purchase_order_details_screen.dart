import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/purchase_order_provider.dart';
import '../../inventory/providers/inventory_provider.dart';





class PurchaseOrderDetailsScreen extends StatelessWidget {
  final PurchaseOrder purchaseOrder;

  const PurchaseOrderDetailsScreen({
    super.key,
    required this.purchaseOrder,
  });

  String? _nextStatus(String status) {
    const transitions = {
      'Draft': 'Submitted',
      'Submitted': 'Approved',
      'Approved': 'Ordered',
      'Ordered': 'Received',
      'Received': 'Completed',
    };

    return transitions[status];
  }

  String _actionLabel(String status) {
    switch (status) {
      case 'Draft':
        return 'Submit Purchase Order';

      case 'Submitted':
        return 'Approve Purchase Order';

      case 'Approved':
        return 'Mark as Ordered';

      case 'Ordered':
        return 'Mark as Received';

      case 'Received':
        return 'Complete Purchase Order';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextStatus =
        _nextStatus(purchaseOrder.status);

    final actionLabel =
        _actionLabel(purchaseOrder.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchase Order Details',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              purchaseOrder.id,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Purchase Order',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(
                children: [
                  _InfoRow(
                    label: 'Supplier',
                    value:
                        purchaseOrder.supplierName,
                  ),

                  const Divider(
                    height: 24,
                  ),

                  _InfoRow(
                    label: 'Status',
                    value:
                        purchaseOrder.status,
                  ),

                  const Divider(
                    height: 24,
                  ),

                  _InfoRow(
                    label: 'Total Amount',
                    value:
                        '₱${purchaseOrder.totalAmount.toStringAsFixed(2)}',
                    valueBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(
                children: [
                  if (purchaseOrder.items.isEmpty)
                    const Text(
                      'No products in this purchase order.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                  ...purchaseOrder.items.map(
                    (item) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                                Text(
                                  '₱${item.total.toStringAsFixed(2)}',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              '${item.quantity} × ₱${item.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Purchase Order Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Current status: ${purchaseOrder.status}',
                      style: TextStyle(
                        color:
                            Colors.blue.shade900,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (nextStatus != null) ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: () {
                    if (purchaseOrder.status == 'Ordered') {
                      final inventoryProvider =
                          context.read<InventoryProvider>();

                      for (final item in purchaseOrder.items) {
                        inventoryProvider.addStock(
                          item.productId,
                          item.quantity,
                          reason: 'Purchase Order Received',
                          notes: 'Received from ${purchaseOrder.id}.',
                        );
                      }
                    }

                    context
                        .read<PurchaseOrderProvider>()
                        .updateStatus(
                          purchaseOrder.id,
                          nextStatus,
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Purchase order ${purchaseOrder.id} is now $nextStatus.',
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  },

                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: valueBold
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize:
                  valueBold ? 17 : 15,
            ),
          ),
        ),
      ],
    );
  }
}
