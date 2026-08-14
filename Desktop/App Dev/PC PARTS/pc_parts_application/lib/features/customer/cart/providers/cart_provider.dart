import 'package:flutter/material.dart';

import '../../../admin/inventory/providers/inventory_provider.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item.dart';

class CartStockShortage {
  final String productName;
  final int availableQuantity;
  final int requestedQuantity;

  const CartStockShortage({
    required this.productName,
    required this.availableQuantity,
    required this.requestedQuantity,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  InventoryProvider? _inventoryProvider;

  List<CartItem> get items => _items;

  void setInventoryProvider(InventoryProvider inventoryProvider) {
    _inventoryProvider = inventoryProvider;
  }

  int availableStockFor(String productId) {
    return _inventoryProvider?.itemById(productId)?.stock ?? 0;
  }

  List<CartStockShortage> get stockShortages {
    final requestedById = <String, int>{};
    final productNames = <String, String>{};

    for (final item in _items.expand((item) => item.stockItems)) {
      requestedById[item.product.id] =
          (requestedById[item.product.id] ?? 0) + item.quantity;
      productNames[item.product.id] = item.product.name;
    }

    return requestedById.entries
        .where((entry) => availableStockFor(entry.key) < entry.value)
        .map(
          (entry) => CartStockShortage(
            productName: productNames[entry.key] ?? entry.key,
            availableQuantity: availableStockFor(entry.key),
            requestedQuantity: entry.value,
          ),
        )
        .toList(growable: false);
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  bool addToCart(ProductModel product) {
    if (!_canAddProduct(product, 1)) {
      return false;
    }

    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    notifyListeners();
    return true;
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  bool increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1 || _items[index].isPcBuild) {
      return false;
    }

    final item = _items[index];
    if (!_canAddProduct(item.product, 1)) {
      return false;
    }

    item.quantity++;
    notifyListeners();
    return true;
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1 || _items[index].isPcBuild) {
      return;
    }

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  bool addToCartWithQuantity(ProductModel product, int quantity) {
    if (quantity <= 0 || !_canAddProduct(product, quantity)) {
      return false;
    }

    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
    return true;
  }

  /// Adds one customer-facing PC build while retaining components for stock.
  bool addCustomPcBuild({
    required String buildName,
    required List<ProductModel> products,
  }) {
    final quantitiesById = <String, int>{};
    final productsById = <String, ProductModel>{};
    for (final product in products) {
      quantitiesById[product.id] = (quantitiesById[product.id] ?? 0) + 1;
      productsById[product.id] = product;
    }

    for (final entry in quantitiesById.entries) {
      if (!_canAddProduct(productsById[entry.key]!, entry.value)) {
        return false;
      }
    }

    _items.add(
      CartItem.pcBuild(
        id: 'pc-build-${DateTime.now().microsecondsSinceEpoch}',
        buildName: buildName,
        components: products,
      ),
    );
    notifyListeners();
    return true;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount =>
      _items.fold(0, (total, item) => total + item.totalPrice);

  bool _canAddProduct(ProductModel product, int quantity) {
    final cartQuantity = _items
        .expand((item) => item.stockItems)
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (total, item) => total + item.quantity);
    return cartQuantity + quantity <= availableStockFor(product.id);
  }
}
