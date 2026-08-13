import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/customer/cart/providers/cart_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';

void main() {
  test('cart uses current inventory instead of the product stock snapshot', () {
    final inventory = InventoryProvider();
    inventory.updateStock('1', 1);

    final cart = CartProvider()..setInventoryProvider(inventory);
    const product = ProductModel(
      id: '1',
      name: 'RTX 4060',
      category: 'GPU',
      brand: 'NVIDIA',
      price: 18999,
      image: '',
      stock: 99,
      description: '',
    );

    expect(cart.addToCart(product), isTrue);
    expect(cart.addToCart(product), isFalse);
    expect(cart.items.single.quantity, 1);

    inventory.updateStock('1', 0);

    expect(cart.stockShortages, hasLength(1));
    expect(cart.stockShortages.single.productName, 'RTX 4060');
    expect(cart.stockShortages.single.availableQuantity, 0);
    expect(cart.stockShortages.single.requestedQuantity, 1);
  });
}
