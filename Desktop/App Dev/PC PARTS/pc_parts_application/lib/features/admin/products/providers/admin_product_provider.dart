import 'package:flutter/material.dart';

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
}

class AdminProductProvider extends ChangeNotifier {
  final List<AdminProduct> _products = [
    AdminProduct(
      id: '1',
      name: 'RTX 4060',
      category: 'GPU',
      price: 18999,
      stock: 10,
    ),
    AdminProduct(
      id: '2',
      name: 'Ryzen 7 7800X3D',
      category: 'CPU',
      price: 19999,
      stock: 5,
    ),
  ];

  List<AdminProduct> get products => _products;

  // Products with low stock (5 or below)
  List<AdminProduct> get lowStockProducts {
    return _products
        .where((product) => product.stock <= 5)
        .toList();
  }

  // Products with critical stock (2 or below)
  List<AdminProduct> get criticalStockProducts {
    return _products
        .where((product) => product.stock <= 2)
        .toList();
  }

  // Total number of products
  int get totalProducts {
    return _products.length;
  }

  // Number of low-stock products
  int get lowStockCount {
    return lowStockProducts.length;
  }

  // Number of critically-stocked products
  int get criticalStockCount {
    return criticalStockProducts.length;
  }

  void addProduct(
    AdminProduct product,
  ) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(
    AdminProduct updatedProduct,
  ) {
    final index = _products.indexWhere(
      (product) => product.id == updatedProduct.id,
    );

    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(
    String id,
  ) {
    _products.removeWhere(
      (product) => product.id == id,
    );

    notifyListeners();
  }
}