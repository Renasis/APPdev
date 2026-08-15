import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/inventory/providers/inventory_provider.dart';
import '../../customer/products/providers/product_provider.dart';
import '../../customer/products/models/product_model.dart';

class StaffInventoryScreen extends StatelessWidget {
  const StaffInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final products = context.watch<ProductProvider>().products;
    final lowStockCount =
        inventory.items.where((item) => item.stock > 2 && item.stock <= 5).length;
    final criticalCount =
        inventory.items.where((item) => item.stock <= 2).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Perform stock operations. Product catalog changes are managed by Admin.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddInventoryDialog(context, products),
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Add Inventory'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _SummaryChip(label: 'Products', value: inventory.items.length),
            _SummaryChip(label: 'Low Stock', value: lowStockCount),
            _SummaryChip(label: 'Critical', value: criticalCount),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: inventory.items.isEmpty
              ? const Center(child: Text('No inventory items found.'))
              : ListView.separated(
                  itemCount: inventory.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _InventoryActionCard(
                    item: inventory.items[index],
                    onStockIn: () => _showStockInDialog(context, inventory.items[index]),
                    onStockOut: () => _showStockOutDialog(context, inventory.items[index]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showStockInDialog(BuildContext context, InventoryItem item) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Stock In — ${item.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current stock: ${item.stock}'),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity to add'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[STAFF STOCK IN] Dialog submit started');
                final quantity = int.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  debugPrint('[STAFF STOCK IN] Validation failed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid quantity greater than 0.')),
                  );
                  return;
                }

                debugPrint('[STAFF STOCK IN] Calling addStock for ${item.id} qty=$quantity');
                final success = await context.read<InventoryProvider>().addStock(
                      item.id,
                      quantity,
                      notes: notesController.text.trim(),
                    );
                debugPrint('[STAFF STOCK IN] addStock completed: success=$success');

                if (!context.mounted) {
                  debugPrint('[STAFF STOCK IN] Context not mounted after addStock');
                  return;
                }

                debugPrint('[STAFF STOCK IN] Popping dialog');
                Navigator.pop(dialogContext);

                if (success) {
                  debugPrint('[STAFF STOCK IN] Showing success snackbar');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.productName}: $quantity unit(s) added.')),
                  );
                } else {
                  debugPrint('[STAFF STOCK IN] Showing failure snackbar');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add stock. Please try again.')),
                  );
                }
              },
              child: const Text('Add Stock'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      quantityController.dispose();
      notesController.dispose();
    });
  }

  void _showStockOutDialog(BuildContext context, InventoryItem item) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Stock Out — ${item.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available stock: ${item.stock}'),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity to remove'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid quantity greater than 0.')),
                  );
                  return;
                }

                if (quantity > item.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient stock. Available quantity: ${item.stock}')),
                  );
                  return;
                }

                final success = await context.read<InventoryProvider>().deductStock(
                      item.id,
                      quantity,
                    );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.productName}: $quantity unit(s) removed.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to remove stock.')),
                  );
                }
              },
              child: const Text('Remove Stock'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      quantityController.dispose();
      notesController.dispose();
    });
  }

  void _showAddInventoryDialog(BuildContext context, List<ProductModel> products) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    ProductModel? selectedProduct;
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Inventory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search products...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final matchesSearch = searchQuery.isEmpty ||
                        product.name.toLowerCase().contains(searchQuery) ||
                        product.category.toLowerCase().contains(searchQuery);
                    final alreadyInInventory = context.read<InventoryProvider>().items.any((item) => item.id == product.id);

                    if (!matchesSearch) return const SizedBox.shrink();
                    if (alreadyInInventory) return const SizedBox.shrink();

                    return ListTile(
                      dense: true,
                      title: Text(product.name),
                      subtitle: Text(product.category),
                      onTap: () {
                        setState(() {
                          selectedProduct = product;
                        });
                      },
                      trailing: selectedProduct?.id == product.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    );
                  },
                ),
              ),
              if (selectedProduct != null) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(selectedProduct!.name),
                  onDeleted: () {
                    setState(() {
                      selectedProduct = null;
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Initial Stock Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[STAFF ADD INVENTORY] Dialog submit started');
                if (selectedProduct == null) {
                  debugPrint('[STAFF ADD INVENTORY] Validation failed: no product selected');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a product.')),
                  );
                  return;
                }

                final quantity = int.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  debugPrint('[STAFF ADD INVENTORY] Validation failed: invalid quantity');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid quantity greater than 0.')),
                  );
                  return;
                }

                debugPrint('[STAFF ADD INVENTORY] Calling createInventoryRecord for ${selectedProduct!.id} qty=$quantity');
                final success = await context.read<InventoryProvider>().createInventoryRecord(
                      productId: selectedProduct!.id,
                      productName: selectedProduct!.name,
                      initialStock: quantity,
                      notes: notesController.text.trim(),
                    );
                debugPrint('[STAFF ADD INVENTORY] createInventoryRecord completed: success=$success');

                if (!context.mounted) {
                  debugPrint('[STAFF ADD INVENTORY] Context not mounted after createInventoryRecord');
                  return;
                }

                debugPrint('[STAFF ADD INVENTORY] Popping dialog');
                Navigator.pop(dialogContext);

                if (success) {
                  debugPrint('[STAFF ADD INVENTORY] Showing success snackbar');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${selectedProduct!.name}: $quantity unit(s) added to inventory.')),
                  );
                } else {
                  debugPrint('[STAFF ADD INVENTORY] Showing failure snackbar');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to create inventory record. Please try again.')),
                  );
                }
              },
              child: const Text('Add Inventory'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      quantityController.dispose();
      notesController.dispose();
    });
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _InventoryActionCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;

  const _InventoryActionCard({
    required this.item,
    required this.onStockIn,
    required this.onStockOut,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      'Critical' => Colors.red,
      'Low Stock' => Colors.orange,
      _ => Colors.green,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.inventory_2_outlined, color: color),
        ),
        title: Text(item.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current stock: ${item.stock}'),
            Text(
              item.status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Stock In',
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: onStockIn,
            ),
            IconButton(
              tooltip: 'Stock Out',
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: onStockOut,
            ),
          ],
        ),
      ),
    );
  }
}
