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
                              onPressed: () async {
                                final newStock =
                                    int.tryParse(
                                  controller.text,
                                );

                                if (newStock != null) {
                                  await provider.updateStock(
                                    item.id,
                                    newStock,
                                  );
                                }

                                if (!context.mounted) {
                                  return;
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
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Stock In'),
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
                  itemCount: context.read<InventoryProvider>().items.length,
                  itemBuilder: (context, index) {
                    final item = context.read<InventoryProvider>().items[index];
                    final matchesSearch = searchQuery.isEmpty ||
                        item.productName.toLowerCase().contains(searchQuery);
                    if (!matchesSearch) return const SizedBox.shrink();
                    return ListTile(
                      dense: true,
                      title: Text(item.productName),
                      subtitle: Text('${item.stock} in stock'),
                      trailing: selectedItem?.id == item.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedItem = item;
                        });
                      },
                    );
                  },
                ),
              ),
              if (selectedItem != null) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(selectedItem!.productName),
                  onDeleted: () {
                    setState(() {
                      selectedItem = null;
                    });
                  },
                ),
              ],
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
                debugPrint('[ADMIN STOCK IN] Dialog submit started');
                final quantity = int.tryParse(quantityController.text);
                if (selectedItem == null || quantity == null || quantity <= 0) {
                  debugPrint('[ADMIN STOCK IN] Validation failed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a product and enter a valid quantity.')),
                  );
                  return;
                }

                debugPrint('[ADMIN STOCK IN] Calling addStock for ${selectedItem!.id} qty=$quantity');
                final success = await context.read<InventoryProvider>().addStock(
                      selectedItem!.id,
                      quantity,
                      notes: notesController.text.trim(),
                    );
                debugPrint('[ADMIN STOCK IN] addStock completed: success=$success');

                if (!context.mounted) {
                  debugPrint('[ADMIN STOCK IN] Context not mounted after addStock');
                  return;
                }

                debugPrint('[ADMIN STOCK IN] Popping dialog');
                Navigator.pop(dialogContext);

                if (success) {
                  debugPrint('[ADMIN STOCK IN] Showing success snackbar');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${selectedItem!.productName}: $quantity unit(s) added.')),
                  );
                } else {
                  debugPrint('[ADMIN STOCK IN] Showing failure snackbar');
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
}
