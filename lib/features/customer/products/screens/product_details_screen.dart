import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../reviews/screens/reviews_screen.dart';
import '../providers/comparison_provider.dart';
import '../../reviews/providers/review_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../../admin/inventory/providers/inventory_provider.dart';



class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<RecentlyViewedProvider>().addProduct(
        widget.product,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final availableStock =
        context.watch<InventoryProvider>().itemById(product.id)?.stock ?? 0;


    final cartProvider =
        Provider.of<CartProvider>(context);

    final wishlistProvider =
        Provider.of<WishlistProvider>(context);

    final isInWishlist =
        wishlistProvider.isInWishlist(product.id);

    final isOutOfStock =
        availableStock <= 0;
    
    final comparisonProvider =
        Provider.of<ComparisonProvider>(context);

    final isCompared =
        comparisonProvider.isSelected(product.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
  IconButton(
    onPressed: () {
      wishlistProvider.toggleWishlist(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInWishlist
                ? '${product.name} removed from wishlist'
                : '${product.name} added to wishlist',
          ),
        ),
      );
    },
    icon: Icon(
      isInWishlist
          ? Icons.favorite
          : Icons.favorite_border,
      color: isInWishlist ? Colors.red : null,
    ),
  ),

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
      color: isCompared ? Colors.blue : null,
    ),
  ),

    IconButton(
  onPressed: () {
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CartScreen(),
  ),
);
  },
  icon: const Icon(
    Icons.shopping_cart_outlined,
  ),
),
],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // Product Image
            Container(
              height: 250,
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: const Icon(
                Icons.memory,
                size: 100,
              ),
            ),

            const SizedBox(height: 20),

            // Product Name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Brand
            Text(
              product.brand,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 15),

            // Price
            Text(
              '₱${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

Consumer<ReviewProvider>(
  builder: (context, reviewProvider, child) {

    final reviews =
        reviewProvider.getProductReviews(
      product.id,
    );

    final rating =
        reviewProvider.getAverageRating(
      product.id,
    );

    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 20,
        ),

        const SizedBox(width: 5),

        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          '(${reviews.length} Reviews)',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  },
),

            const SizedBox(height: 25),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              product.description,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            // Stock
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: isOutOfStock
                      ? Colors.red
                      : Colors.green,
                ),

                const SizedBox(width: 10),

                Text(
                  isOutOfStock
                      ? 'Out of Stock'
                      : '$availableStock Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isOutOfStock
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Quantity
            if (!isOutOfStock) ...[
              const Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () {
                            setState(() {
                              quantity--;
                            });
                          }
                        : null,
                    icon: const Icon(
                      Icons.remove,
                    ),
                  ),

                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed:
                        quantity < availableStock
                            ? () {
                                setState(() {
                                  quantity++;
                                });
                              }
                            : null,
                    icon: const Icon(
                      Icons.add,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    'Max: $availableStock',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],

            // Total
            if (!isOutOfStock)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '₱${(product.price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewsScreen(
            productId: product.id,
            productName: product.name,
          ),
        ),
      );
    },
    icon: const Icon(
      Icons.star_outline,
    ),
    label: const Text(
      'View Reviews',
    ),
  ),
),

            const SizedBox(height: 15),

            // Add To Cart
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: isOutOfStock
                    ? null
                    : () {
                        final added = cartProvider.addToCartWithQuantity(
                          product,
                          quantity,
                        );

                        if (!added) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This product is no longer available in the requested quantity.'),
                            ),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$quantity × ${product.name} added to cart',
                            ),
                          ),
                        );
                      },

                icon: const Icon(
                  Icons.shopping_cart,
                ),

                label: Text(
                  isOutOfStock
                      ? 'Out of Stock'
                      : 'Add to Cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
