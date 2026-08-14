import 'package:flutter/material.dart';

class PurchaseOrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  PurchaseOrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;
}

class PurchaseOrder {
  final String id;
  final String supplierName;
  final String status;
  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    required this.id,
    required this.supplierName,
    required this.status,
    required this.items,
  });

  double get totalAmount {
    return items.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }
}

class PurchaseOrderProvider extends ChangeNotifier {
  final List<PurchaseOrder> _purchaseOrders = [
    PurchaseOrder(
      id: 'PO-001',
      supplierName: 'TechSource PH',
      status: 'Draft',
      items: [
        PurchaseOrderItem(
          productId: '1',
          productName: 'RTX 4060',
          unitPrice: 18999,
          quantity: 2,
        ),
      ],
    ),

    PurchaseOrder(
      id: 'PO-002',
      supplierName: 'PC Express Supplier',
      status: 'Ordered',
      items: [
        PurchaseOrderItem(
          productId: '2',
          productName: 'Ryzen 7 7800X3D',
          unitPrice: 19999,
          quantity: 6,
        ),
      ],
    ),
  ];

  List<PurchaseOrder> get purchaseOrders =>
      _purchaseOrders;

  void addPurchaseOrder(
    PurchaseOrder order,
  ) {
    _purchaseOrders.add(order);
    notifyListeners();
  }

  void updateStatus(
  String id,
  String newStatus,
) {
  final index = _purchaseOrders.indexWhere(
    (order) => order.id == id,
  );

  if (index == -1) {
    return;
  }

  final currentStatus =
      _purchaseOrders[index].status;

  const allowedTransitions = {
    'Draft': 'Submitted',
    'Submitted': 'Approved',
    'Approved': 'Ordered',
    'Ordered': 'Received',
    'Received': 'Completed',
  };

  if (allowedTransitions[currentStatus] !=
      newStatus) {
    return;
  }

  final order = _purchaseOrders[index];

  _purchaseOrders[index] = PurchaseOrder(
    id: order.id,
    supplierName: order.supplierName,
    status: newStatus,
    items: order.items,
  );

  notifyListeners();
}

  void deletePurchaseOrder(
    String id,
  ) {
    _purchaseOrders.removeWhere(
      (order) => order.id == id,
    );

    notifyListeners();
  }
}