import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../models/product_model.dart';

/// Firestore data access for the product catalog.
///
/// Documents live in `products/{id}` and are added through the Firebase
/// console until a controlled seed process is introduced.
class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.products);

  Stream<List<ProductModel>> watchProducts() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map(_toProduct).toList(growable: false),
    );
  }

  Future<void> upsertProduct(ProductModel product) {
    return _collection.doc(product.id).set(_toMap(product));
  }

  Future<void> deleteProduct(String id) {
    return _collection.doc(id).delete();
  }

  ProductModel _toProduct(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return ProductModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      price: (data['price'] as num? ?? 0).toDouble(),
      image: data['image'] as String? ?? '',
      stock: (data['stock'] as num? ?? 0).toInt(),
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> _toMap(ProductModel product) {
    return {
      'name': product.name,
      'category': product.category,
      'brand': product.brand,
      'price': product.price,
      'image': product.image,
      'stock': product.stock,
      'description': product.description,
    };
  }
}
