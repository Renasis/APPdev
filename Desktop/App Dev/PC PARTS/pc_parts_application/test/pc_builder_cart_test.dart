import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/customer/cart/providers/cart_provider.dart';
import 'package:pc_parts_application/features/customer/pc_builder/providers/pc_builder_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';

ProductModel _product(String id, String category) {
  return ProductModel(
    id: id,
    name: category,
    category: category,
    brand: 'Test',
    price: 100,
    image: '',
    stock: 2,
    description: category == 'PSU' ? '650W power supply' : '',
  );
}

void main() {
  test('a complete PC build including a case adds one build bundle to cart', () {
    final builder = PcBuilderProvider();
    builder.selectCpu(_product('cpu', 'CPU'));
    builder.selectGpu(_product('gpu', 'GPU'));
    builder.selectMotherboard(_product('motherboard', 'Motherboard'));
    builder.selectRam(_product('ram', 'RAM'));
    builder.selectStorage(_product('storage', 'Storage'));
    builder.selectPsu(_product('psu', 'PSU'));
    builder.selectCase(_product('case', 'Case'));

    final cart = CartProvider();
    final added = cart.addCustomPcBuild(
      buildName: 'Custom PC Build',
      products: builder.selectedProducts,
    );

    expect(builder.isBuildComplete, isTrue);
    expect(builder.selectedProducts, hasLength(7));
    expect(added, isTrue);
    expect(cart.items, hasLength(1));
    expect(cart.totalItems, 1);
    expect(cart.items.single.isPcBuild, isTrue);
    expect(cart.items.single.buildComponents, hasLength(7));
    expect(cart.items.single.stockItems, hasLength(7));
  });
}
