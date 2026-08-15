import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../repository/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  /// Without a [repository] the provider keeps serving the built-in demo
  /// catalog, which is what the widget tests rely on. With one, the catalog
  /// comes from Firestore instead.
  ProductProvider({ProductRepository? repository}) : _repository = repository {
    if (repository == null) {
      return;
    }

    _products.clear();
    _isLoading = true;
    _subscription = repository.watchProducts().listen(
      _onProducts,
      onError: _onError,
    );
  }

  final ProductRepository? _repository;

  StreamSubscription<List<ProductModel>>? _subscription;

  bool _isLoading = false;

  String? _errorMessage;

  final List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> saveProduct(ProductModel product) async {
    await _repository?.upsertProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _repository?.deleteProduct(id);
  }

  void _onProducts(List<ProductModel> products) {
    _products
      ..clear()
      ..addAll(products);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = 'Could not load products.';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') {
      return _products;
    }

    return _products
        .where((product) => product.category == category)
        .toList();
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      return product.name
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          product.brand
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          product.category
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();
  }
}
