import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_product_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  final nameController =
      TextEditingController();

  final categoryController =
      TextEditingController();

  final priceController =
      TextEditingController();

  final stockController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    if (nameController.text.isEmpty ||
        categoryController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty) {
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final stock = int.parse(stockController.text);
    final product = AdminProduct(
            id: id,
            name: nameController.text,
            category:
                categoryController.text,
            price: double.parse(
              priceController.text,
            ),
            stock: stock,
          );

    context.read<AdminProductProvider>().addProduct(product);
    await context.read<InventoryProvider>().addInventoryItem(
          id: id,
          productName: product.name,
          stock: stock,
        );

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Product',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              controller: priceController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: 'Price',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: stockController,
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
                onPressed: saveProduct,
                child: const Text(
                  'Save Product',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
