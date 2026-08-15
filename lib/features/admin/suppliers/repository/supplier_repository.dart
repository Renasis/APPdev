import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../models/supplier.dart';

class SupplierRepository {
  SupplierRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.suppliers);

  Stream<List<Supplier>> watchSuppliers() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map(Supplier.fromFirestore).toList(growable: false),
    );
  }

  Future<void> createSupplier(Supplier supplier) {
    return _collection.doc(supplier.id).set(supplier.toFirestore());
  }

  Future<void> updateSupplier(Supplier supplier) {
    return _collection.doc(supplier.id).update(supplier.toFirestore());
  }

  Future<void> deleteSupplier(String id) {
    return _collection.doc(id).delete();
  }
}
