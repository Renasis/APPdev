import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_product_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

class EditProductScreen extends StatefulWidget {
  final AdminProduct product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
      text: widget.product.name,
    );

    categoryController =
        TextEditingController(
      text: widget.product.category,
    );

    priceController =
        TextEditingController(
      text:
          widget.product.price.toString(),
    );

    stockController =
        TextEditingController(
      text:
          widget.product.stock.toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  void updateProduct() {
    final updatedProduct = AdminProduct(
            id: widget.product.id,
            name: nameController.text,
            category:
                categoryController.text,
            price: double.parse(
              priceController.text,
            ),
            stock: int.parse(
              stockController.text,
            ),
          );

    context.read<AdminProductProvider>().updateProduct(updatedProduct);
    final inventoryProvider = context.read<InventoryProvider>();
    inventoryProvider.updateInventoryItemName(
      updatedProduct.id,
      updatedProduct.name,
    );
    inventoryProvider.updateStock(updatedProduct.id, updatedProduct.stock);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Edit Product'),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Product Name',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  categoryController,
              decoration:
                  const InputDecoration(
                labelText: 'Category',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  priceController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: 'Price',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  stockController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: 'Stock',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    updateProduct,
                child: const Text(
                  'Update Product',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
