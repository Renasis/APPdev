import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ComparisonProvider extends ChangeNotifier {
  final List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  bool isSelected(String productId) {
    return _products.any(
      (product) => product.id == productId,
    );
  }

  void toggleProduct(ProductModel product) {
    final exists = _products.any(
      (item) => item.id == product.id,
    );

    if (exists) {
      _products.removeWhere(
        (item) => item.id == product.id,
      );
    } else {
      if (_products.length < 4) {
        _products.add(product);
      }
    }

    notifyListeners();
  }

  void clearComparison() {
    _products.clear();
    notifyListeners();
  }
}