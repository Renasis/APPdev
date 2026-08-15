import 'dart:async';

import 'package:flutter/material.dart';

import '../../../customer/products/models/product_model.dart';
import '../../../customer/products/repository/product_repository.dart';

class AdminProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;

  AdminProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory AdminProduct.fromProduct(ProductModel product) {
    return AdminProduct(
      id: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      stock: product.stock,
    );
  }

  ProductModel toProduct() {
    return ProductModel(
      id: id,
      name: name,
      category: category,
      brand: '',
      price: price,
      image: '',
      stock: stock,
      description: '',
    );
  }
}

class AdminProductProvider extends ChangeNotifier {
  AdminProductProvider({ProductRepository? repository})
      : _repository = repository {
    if (repository == null) {
      return;
    }

    _subscription = repository.watchProducts().listen(
      _onProducts,
      onError: _onError,
    );
  }

  final ProductRepository? _repository;

  StreamSubscription<List<ProductModel>>? _subscription;

  final List<AdminProduct> _products = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<AdminProduct> get products => List.unmodifiable(_products);

  List<AdminProduct> get lowStockProducts {
    return _products
        .where((product) => product.stock > 2 && product.stock <= 5)
        .toList();
  }

  List<AdminProduct> get criticalStockProducts {
    return _products
        .where((product) => product.stock <= 2)
        .toList();
  }

  int get totalProducts => _products.length;

  int get lowStockCount => lowStockProducts.length;

  int get criticalStockCount => criticalStockProducts.length;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onProducts(List<ProductModel> products) {
    _products
      ..clear()
      ..addAll(products.map(AdminProduct.fromProduct).toList(growable: false));
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = 'Could not load products.';
    notifyListeners();
  }

  Future<void> addProduct(AdminProduct product) async {
    try {
      await _repository?.upsertProduct(product.toProduct());
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to add product.';
    }

    notifyListeners();
  }

  Future<void> updateProduct(AdminProduct updatedProduct) async {
    try {
      final existing = await _repository?.fetchProduct(updatedProduct.id);
      final base = updatedProduct.toProduct();
      final product = existing != null
          ? ProductModel(
              id: base.id,
              name: base.name,
              category: base.category,
              brand: existing.brand,
              price: base.price,
              image: existing.image,
              stock: base.stock,
              description: existing.description,
            )
          : base;

      await _repository?.upsertProduct(product);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to update product.';
    }

    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository?.deleteProduct(id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to delete product.';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
