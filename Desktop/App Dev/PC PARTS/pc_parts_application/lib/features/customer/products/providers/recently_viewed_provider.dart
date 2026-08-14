import 'package:flutter/material.dart';

import '../models/product_model.dart';

class RecentlyViewedProvider
    extends ChangeNotifier {
  final List<ProductModel>
      _recentlyViewed = [];

  List<ProductModel>
      get recentlyViewed =>
          _recentlyViewed;

  void addProduct(
    ProductModel product,
  ) {
    _recentlyViewed.removeWhere(
      (item) => item.id == product.id,
    );

    _recentlyViewed.insert(
      0,
      product,
    );

    if (_recentlyViewed.length > 10) {
      _recentlyViewed.removeLast();
    }

    notifyListeners();
  }

  void clearHistory() {
    _recentlyViewed.clear();
    notifyListeners();
  }
}