import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../../../navigation/main_navigation_wrapper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        Provider.of<CartProvider>(context);

    final items = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: () {
                _showClearCartDialog(
                  context,
                  cartProvider,
                );
              },
            ),
        ],
      ),

      body: items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),

                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              // Product Image
                              Container(
                                width: 85,
                                height: 85,

                                decoration: BoxDecoration(
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

                              const SizedBox(width: 12),

                              // Product Information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item.displayName,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item.isPcBuild
                                          ? '${item.buildComponents.length} selected components'
                                          : item.product.brand,
                                      style: TextStyle(
                                        color: Colors
                                            .grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      '₱${item.product.price.toStringAsFixed(2)}',

                                      style:
                                          const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    if (item.isPcBuild)
                                      TextButton.icon(
                                        onPressed: () => _showBuildComponents(context, item),
                                        icon: const Icon(Icons.list_alt_outlined),
                                        label: const Text('View components'),
                                      )
                                    else
                                      Row(
                                      children: [
                                        // Decrease
                                        IconButton(
                                          onPressed:
                                              item.quantity >
                                                      1
                                                  ? () {
                                                      cartProvider
                                                          .decreaseQuantity(
                                                        item.product
                                                            .id,
                                                      );
                                                    }
                                                  : null,

                                          icon: const Icon(
                                            Icons.remove,
                                          ),
                                        ),

                                        Container(
                                          width: 35,
                                          alignment:
                                              Alignment.center,

                                          child: Text(
                                            '${item.quantity}',

                                            style:
                                                const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),

                                        // Increase
                                        IconButton(
                                          onPressed:
                                              item.quantity <
                                                      cartProvider.availableStockFor(
                                                    item.product.id,
                                                  )
                                                  ? () {
                                                      cartProvider
                                                          .increaseQuantity(
                                                        item.product
                                                            .id,
                                                      );
                                                    }
                                                  : null,

                                          icon: const Icon(
                                            Icons.add,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Remove
                              IconButton(
                                tooltip:
                                    'Remove item',

                                onPressed: () {
                                  _showRemoveItemDialog(
                                    context,
                                    cartProvider,
                                    item.product.id,
                                    item.displayName,
                                  );
                                },

                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Cart Summary
                _buildCartSummary(
                  context,
                  cartProvider,
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add some PC components to your cart before checking out.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
  onPressed: () {
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const MainNavigationWrapper(
          initialIndex: 1,
        ),
  ),
);
  },

  icon: const Icon(
    Icons.shopping_bag_outlined,
  ),

  label: const Text(
    'Browse Products',
  ),
),
          ],
        ),
      ),
    );
  }

  void _showBuildComponents(BuildContext context, CartItem item) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...item.buildComponents.map(
                  (component) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(component.product.name),
                    trailing: Text(
                      '₱${component.totalPrice.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),

        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                Text(
                  '${cartProvider.totalItems}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '₱${cartProvider.totalAmount.toStringAsFixed(2)}',

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CheckoutScreen(),
                    ),
                  );
                },

                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    CartProvider cartProvider,
    String productId,
    String productName,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Item?',
          ),

          content: Text(
            'Remove "$productName" from your cart?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                cartProvider.removeFromCart(
                  productId,
                );

                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear Cart?',
          ),

          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                cartProvider.clearCart();

                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Clear Cart',
              ),
            ),
          ],
        );
      },
    );
  }
}
