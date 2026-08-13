import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../screens/product_details_screen.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/comparison_provider.dart';
import '../../../admin/inventory/providers/inventory_provider.dart';



class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final availableStock =
        context.watch<InventoryProvider>().itemById(product.id)?.stock ?? 0;
    final wishlistProvider =
        Provider.of<WishlistProvider>(context);

    final comparisonProvider =
    Provider.of<ComparisonProvider>(context);

    final isCompared =
    comparisonProvider.isSelected(product.id);

    final isFavorite =
        wishlistProvider.isInWishlist(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: product,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // Product Image + Wishlist Button
              Stack(
                children: [

                  Container(
                    height: 120,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.memory,
                      size: 60,
                    ),
                  ),

                  Positioned(
  top: 4,
  right: 4,

  child: Row(
    mainAxisSize: MainAxisSize.min,

    children: [

      IconButton(
        onPressed: () {
  if (isCompared) {
    comparisonProvider.toggleProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} removed from comparison',
        ),
      ),
    );
    return;
  }

  if (comparisonProvider.products.length >= 4) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'You can compare up to 4 products only.',
        ),
      ),
    );
    return;
  }

  comparisonProvider.toggleProduct(product);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${product.name} added to comparison',
      ),
    ),
  );
},

        icon: Icon(
          Icons.compare_arrows,
          color: isCompared
              ? Colors.blue
              : Colors.grey,
        ),
      ),

      IconButton(
        onPressed: () {
          wishlistProvider.toggleWishlist(
            product,
          );
        },

        icon: Icon(
          isFavorite
              ? Icons.favorite
              : Icons.favorite_border,

          color: isFavorite
              ? Colors.red
              : Colors.grey,
        ),
      ),

    ],
  ),
),
                ],
              ),

              const SizedBox(height: 12),

SizedBox(
  height: 22,
  child: Text(
    product.name,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 5),

SizedBox(
  height: 20,
  child: Text(
    product.brand,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: Colors.grey.shade600,
      fontSize: 13,
    ),
  ),
),

const SizedBox(height: 8),

              Text(
                "₱${product.price.toStringAsFixed(2)}",

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [

                  Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: availableStock > 0
                        ? Colors.green
                        : Colors.red,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    availableStock > 0
                        ? "Available"
                        : "Out of Stock",

                    style: TextStyle(
                      fontSize: 13,
                      color: availableStock > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
