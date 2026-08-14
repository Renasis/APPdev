import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../widgets/inventory_tile.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
        ),
        actions: [
          IconButton(
            tooltip: 'Stock In',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showStockInDialog(context),
          ),
        ],
      ),
      body: Consumer<
          InventoryProvider>(
        builder:
            (context, provider, child) {
          return ListView.builder(
            padding:
                const EdgeInsets.all(12),
            itemCount:
                provider.items.length,
            itemBuilder:
                (context, index) {
              final item =
                  provider.items[index];

              return InventoryTile(
                item: item,
                onAdjust: () {
                  final controller =
                      TextEditingController(
                    text: item.stock.toString(),
                  );

                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text(
                          'Adjust Stock',
                        ),

                        content: TextField(
                          controller: controller,
                          keyboardType:
                              TextInputType.number,
                          decoration:
                              const InputDecoration(
                            labelText: 'New Stock',
                          ),
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            child: const Text(
                              'Cancel',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              final newStock =
                                  int.tryParse(
                                controller.text,
                              );

                              if (newStock != null) {
                                provider.updateStock(
                                  item.id,
                                  newStock,
                                );
                              }

                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            child: const Text(
                              'Save',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showStockInDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    InventoryItem? selectedItem;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Stock In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<InventoryItem>(
                decoration: const InputDecoration(labelText: 'Product'),
                items: context.read<InventoryProvider>().items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text('${item.productName} (${item.stock} in stock)'),
                      ),
                    )
                    .toList(),
                onChanged: (item) => setState(() => selectedItem = item),
              ),
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
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (selectedItem == null || quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a product and enter a valid quantity.')),
                  );
                  return;
                }

                context.read<InventoryProvider>().addStock(
                      selectedItem!.id,
                      quantity,
                      notes: notesController.text.trim(),
                    );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${selectedItem!.productName}: $quantity unit(s) added.')),
                );
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
}
