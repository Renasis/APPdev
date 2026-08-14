import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../../products/screens/product_details_screen.dart';
import '../providers/wishlist_provider.dart';
import '../../../admin/inventory/providers/inventory_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider =
        context.watch<WishlistProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    final items = wishlistProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),

      body: items.isEmpty
          ? const _EmptyWishlist()
          : ListView.separated(
              padding: const EdgeInsets.all(16),

              itemCount: items.length,

              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),

              itemBuilder: (context, index) {
                final product =
                    items[index].product;

                final availableStock =
                    inventoryProvider.itemById(product.id)?.stock ?? 0;
                final isOutOfStock = availableStock <= 0;

                return Card(
                  clipBehavior: Clip.antiAlias,

                  child: InkWell(
                    // =========================
                    // OPEN PRODUCT DETAILS
                    // =========================
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(
                            product: product,
                          ),
                        ),
                      );
                    },

                    child: Padding(
                      padding:
                          const EdgeInsets.all(14),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // =========================
                          // PRODUCT IMAGE
                          // =========================

                          Container(
                            height: 82,
                            width: 82,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.grey.shade100,

                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),

                            child: const Icon(
                              Icons.memory,
                              size: 40,
                            ),
                          ),

                          const SizedBox(width: 14),

                          // =========================
                          // PRODUCT INFORMATION
                          // =========================

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                // Product Name + Remove
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,

                                        maxLines: 2,

                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),

                                    // Remove from Wishlist
                                    IconButton(
                                      tooltip:
                                          'Remove from wishlist',

                                      onPressed: () {
                                        wishlistProvider
                                            .removeFromWishlist(
                                          product.id,
                                        );

                                        ScaffoldMessenger
                                                .of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(
                                              '${product.name} removed from wishlist',
                                            ),
                                          ),
                                        );
                                      },

                                      icon:
                                          const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),

                                // =========================
                                // BRAND
                                // =========================

                                Text(
                                  product.brand,

                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                // =========================
                                // PRICE
                                // =========================

                                Text(
                                  '₱${product.price.toStringAsFixed(2)}',

                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                // =========================
                                // STOCK
                                // =========================

                                Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .inventory_2_outlined,

                                      size: 18,

                                      color:
                                          isOutOfStock
                                              ? Colors.red
                                              : Colors.green,
                                    ),

                                    const SizedBox(
                                      width: 6,
                                    ),

                                    Text(
                                      isOutOfStock
                                          ? 'Out of stock'
                                          : '$availableStock available',

                                      style: TextStyle(
                                        color:
                                            isOutOfStock
                                                ? Colors.red
                                                : Colors.green,

                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                // =========================
                                // ADD TO CART
                                // =========================

                                SizedBox(
                                  width:
                                      double.infinity,

                                  child:
                                      FilledButton.icon(
                                    onPressed:
                                        isOutOfStock
                                            ? null
                                            : () {
                                                context
                                                    .read<
                                                        CartProvider>()
                                                    .addToCart(
                                                      product,
                                                    );

                                                ScaffoldMessenger
                                                        .of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content:
                                                        Text(
                                                      '${product.name} added to cart',
                                                    ),
                                                  ),
                                                );
                                              },

                                    icon:
                                        const Icon(
                                      Icons
                                          .shopping_cart_outlined,
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =====================================================
// EMPTY WISHLIST
// =====================================================

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.favorite_border,

              size: 88,

              color:
                  Colors.grey.shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Your wishlist is empty',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Save PC parts you like so you can find them easily later.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
