import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/firebase_service.dart';
import '../providers/inventory_provider.dart';

/// Firestore data access for stock levels and stock movements.
///
/// Stock lives in `inventory/{productId}` and the audit trail in
/// `stock_movements/{movementId}`.
class InventoryRepository {
  InventoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection(FirestoreCollections.inventory);

  CollectionReference<Map<String, dynamic>> get _movements =>
      _firestore.collection(FirestoreCollections.stockMovements);

  Stream<List<InventoryItem>> watchItems() {
    return _items.snapshots().map(
      (snapshot) => snapshot.docs.map(_toItem).toList(growable: false),
    );
  }

  Stream<List<StockMovement>> watchMovements() {
    return _movements
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_toMovement).toList(growable: false),
        );
  }

  Future<void> saveItem(InventoryItem item) {
    debugPrint('[REPOSITORY] saveItem started: id=${item.id}');
    return _items.doc(item.id).set({
      'productName': item.productName,
      'stock': item.stock,
    }).then((_) {
      debugPrint('[REPOSITORY] saveItem completed: id=${item.id}');
    }).catchError((error) {
      debugPrint('[REPOSITORY] saveItem FAILED: id=${item.id} error=$error');
      throw error;
    });
  }

  Future<void> deleteItem(String id) {
    debugPrint('[REPOSITORY] deleteItem started: id=$id');
    return _items.doc(id).delete().then((_) {
      debugPrint('[REPOSITORY] deleteItem completed: id=$id');
    }).catchError((error) {
      debugPrint('[REPOSITORY] deleteItem FAILED: id=$id error=$error');
      throw error;
    });
  }

  Future<void> saveMovement(StockMovement movement) {
    debugPrint('[REPOSITORY] saveMovement started: id=${movement.id}');
    return _movements.doc(movement.id).set({
      'productId': movement.productId,
      'productName': movement.productName,
      'quantity': movement.quantity,
      'previousStock': movement.previousStock,
      'newStock': movement.newStock,
      'reason': movement.reason,
      'notes': movement.notes,
      'date': Timestamp.fromDate(movement.date),
      'type': movement.type,
      'performedByUid': movement.performedByUid,
      'performedByName': movement.performedByName,
      'performedByRole': movement.performedByRole,
    }).then((_) {
      debugPrint('[REPOSITORY] saveMovement completed: id=${movement.id}');
    }).catchError((error) {
      debugPrint('[REPOSITORY] saveMovement FAILED: id=${movement.id} error=$error');
      throw error;
    });
  }

  InventoryItem _toItem(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    return InventoryItem(
      id: document.id,
      productName: data['productName'] as String? ?? '',
      stock: (data['stock'] as num? ?? 0).toInt(),
    );
  }

  StockMovement _toMovement(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return StockMovement(
      id: document.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: (data['quantity'] as num? ?? 0).toInt(),
      previousStock: (data['previousStock'] as num? ?? 0).toInt(),
      newStock: (data['newStock'] as num? ?? 0).toInt(),
      reason: data['reason'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] as String? ?? '',
      performedByUid: data['performedByUid'] as String? ?? '',
      performedByName: data['performedByName'] as String? ?? '',
      performedByRole: data['performedByRole'] as String? ?? '',
    );
  }
}
