import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';

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

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }

  factory PurchaseOrderItem.fromFirestore(Map<String, dynamic> data) {
    return PurchaseOrderItem(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      unitPrice: (data['unitPrice'] as num? ?? 0).toDouble(),
      quantity: (data['quantity'] as num? ?? 0).toInt(),
    );
  }
}

class PurchaseOrder {
  final String id;
  final String supplierName;
  final String status;
  final List<PurchaseOrderItem> items;
  final DateTime createdAt;

  PurchaseOrder({
    required this.id,
    required this.supplierName,
    required this.status,
    required this.items,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalAmount {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplierName': supplierName,
      'status': status,
      'items': items.map((item) => item.toFirestore()).toList(growable: false),
      'createdAt': Timestamp.fromDate(createdAt),
      'totalAmount': totalAmount,
    };
  }

  factory PurchaseOrder.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => PurchaseOrderItem.fromFirestore(item as Map<String, dynamic>))
        .toList(growable: false);

    return PurchaseOrder(
      id: document.id,
      supplierName: data['supplierName'] as String? ?? '',
      status: data['status'] as String? ?? 'Draft',
      items: items,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class PurchaseOrderRepository {
  PurchaseOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.purchaseOrders);

  Stream<List<PurchaseOrder>> watchPurchaseOrders() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(PurchaseOrder.fromFirestore).toList(growable: false),
        );
  }

  Future<void> createPurchaseOrder(PurchaseOrder order) {
    return _collection.doc(order.id).set(order.toFirestore());
  }

  Future<void> updatePurchaseOrderStatus(String id, String status) {
    return _collection.doc(id).update({'status': status});
  }

  Future<void> deletePurchaseOrder(String id) {
    return _collection.doc(id).delete();
  }
}
