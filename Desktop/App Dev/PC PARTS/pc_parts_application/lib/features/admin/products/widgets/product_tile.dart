import 'package:flutter/material.dart';

import '../providers/admin_product_provider.dart';

class ProductTile extends StatelessWidget {
  final AdminProduct product;
  final int stock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductTile({
    super.key,
    required this.product,
    required this.stock,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.inventory_2_outlined,
          ),
        ),

        title: Text(
          product.name,
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              product.category,
            ),

            Text(
              'Stock: $stock',
            ),

            Text(
              '₱${product.price.toStringAsFixed(2)}',
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
              ),
            ),

            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
