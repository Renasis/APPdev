import 'package:cloud_firestore/cloud_firestore.dart';

/// Single place where Firestore collection names live so they are not spread
/// across the repositories.
class FirestoreCollections {
  const FirestoreCollections._();

  static const products = 'products';
  static const inventory = 'inventory';
  static const stockMovements = 'stock_movements';
  static const orders = 'orders';
  static const users = 'users';
}

/// Shared entry point to Firestore for the repositories.
class FirebaseService {
  const FirebaseService._();

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
