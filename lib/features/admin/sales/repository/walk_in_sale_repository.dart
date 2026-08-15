import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../models/walk_in_sale_model.dart';

class WalkInSaleRepository {
  WalkInSaleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('walkInSales');

  Stream<List<WalkInSale>> watchSales() {
    return _collection
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WalkInSale.fromMap(doc.id, doc.data()))
            .toList(growable: false));
  }

  Future<void> saveSale(WalkInSale sale) {
    return _collection.doc(sale.id).set(sale.toMap());
  }
}
