import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/supplier_provider.dart';
import '../widgets/supplier_tile.dart';

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
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Add Supplier Screen coming next.',
              ),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Edit ${supplier.name}',
                      ),
                    ),
                  );
                },

                onDelete: () {
                  provider.deleteSupplier(
                    supplier.id,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${supplier.name} deleted',
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