import '../../products/models/product_model.dart';

class WishlistItem {
  final ProductModel product;
  final DateTime addedAt;

  WishlistItem({
    required this.product,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}