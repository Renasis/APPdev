import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/supplier_provider.dart';
import '../widgets/supplier_tile.dart';
import 'add_supplier_screen.dart';
import 'edit_supplier_screen.dart';

class SupplierListScreen extends StatelessWidget {
  const SupplierListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suppliers',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddSupplierScreen(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
        ),
      ),

      body: Consumer<SupplierProvider>(
        builder:
            (context, provider, child) {
          if (provider.suppliers.isEmpty) {
            return const Center(
              child: Text(
                'No suppliers found.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount:
                provider.suppliers.length,

            itemBuilder:
                (context, index) {
              final supplier =
                  provider.suppliers[index];

              return SupplierTile(
                supplier: supplier,

                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditSupplierScreen(
                                supplier: supplier,
                              ),
                            ),
                          );
                        },

                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Delete Supplier?'),
                                content: Text(
                                  'Are you sure you want to delete ${supplier.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, true);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed != true) {
                            return;
                          }

                          provider.deleteSupplier(supplier.id);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${supplier.name} deleted')),
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