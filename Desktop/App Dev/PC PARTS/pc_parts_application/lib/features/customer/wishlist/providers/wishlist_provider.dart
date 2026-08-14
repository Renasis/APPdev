import 'package:flutter/material.dart';

import '../models/wishlist_item.dart';
import '../../products/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<WishlistItem> _items = [];

  List<WishlistItem> get items => _items;

  bool isInWishlist(String productId) {
    return _items.any(
      (item) => item.product.id == productId,
    );
  }

  void toggleWishlist(ProductModel product) {
    final exists = isInWishlist(product.id);

    if (exists) {
      removeFromWishlist(product.id);
    } else {
      _items.add(
        WishlistItem(
          product: product,
        ),
      );

      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _items.removeWhere(
      (item) => item.product.id == productId,
    );

    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();

    notifyListeners();
  }
}