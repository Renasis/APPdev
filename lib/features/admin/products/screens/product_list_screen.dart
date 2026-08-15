import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_product_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../widgets/product_tile.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';



class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Management',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddProductScreen(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
        ),
      ),

      body: Consumer2<AdminProductProvider, InventoryProvider>(
        builder: (context, provider, inventoryProvider, child) {
          if (provider.products.isEmpty) {
            return const Center(
              child: Text(
                'No products found.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount:
                provider.products.length,

            itemBuilder:
                (context, index) {
              final product =
                  provider.products[index];
              final inventoryItem = inventoryProvider.itemById(product.id);
              final currentStock = inventoryItem?.stock ?? product.stock;

              return ProductTile(
                product: product,
                stock: currentStock,

                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductScreen(
                        product: AdminProduct(
                          id: product.id,
                          name: product.name,
                          category: product.category,
                          price: product.price,
                          stock: currentStock,
                        ),
                      ),
                    ),
                  );
                },

                onDelete: () async {
                  provider.deleteProduct(
                    product.id,
                  );
                  await inventoryProvider.removeInventoryItem(product.id);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${product.name} deleted',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
