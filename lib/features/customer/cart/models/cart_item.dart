import '../../products/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  final String? buildName;
  final List<CartItem> buildComponents;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.buildName,
    List<CartItem> buildComponents = const [],
  }) : buildComponents = List.unmodifiable(buildComponents);

  factory CartItem.pcBuild({
    required String id,
    required String buildName,
    required List<ProductModel> components,
  }) {
    final componentItems = components
        .map((product) => CartItem(product: product))
        .toList(growable: false);
    final total = componentItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    return CartItem(
      product: ProductModel(
        id: id,
        name: buildName,
        category: 'Custom PC Build',
        brand: 'End PC Parts',
        price: total,
        image: '',
        stock: 1,
        description: 'Custom PC build containing ${componentItems.length} components.',
      ),
      buildName: buildName,
      buildComponents: componentItems,
    );
  }

  bool get isPcBuild => buildName != null;

  String get displayName => buildName ?? product.name;

  double get totalPrice => product.price * quantity;

  /// Physical products whose inventory must be validated and deducted.
  List<CartItem> get stockItems {
    if (!isPcBuild) {
      return [this];
    }

    return buildComponents
        .map(
          (component) => CartItem(
            product: component.product,
            quantity: component.quantity * quantity,
          ),
        )
        .toList(growable: false);
  }
}
