import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/comparison_provider.dart';
import '../../../admin/inventory/providers/inventory_provider.dart';

class ProductComparisonScreen extends StatelessWidget {
  const ProductComparisonScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final comparisonProvider =
        Provider.of<ComparisonProvider>(context);
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Products',
        ),
        actions: [
          IconButton(
            onPressed: () {
              comparisonProvider.clearComparison();
            },
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),

      body: comparisonProvider.products.isEmpty
          ? const Center(
              child: Text(
                'No products selected for comparison',
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            '${comparisonProvider.products.length} Products Selected',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              comparisonProvider
                                  .clearComparison();
                            },
                            child: const Text(
                              'Clear All',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal,

                    child: DataTable(
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Attribute',
                          ),
                        ),

                        ...comparisonProvider
                            .products
                            .map(
                              (product) =>
                                  DataColumn(
                                label: Text(
                                  product.name,
                                ),
                              ),
                            ),
                      ],

                      rows: [
                        DataRow(
                          cells: [
                            const DataCell(
                              Text('Brand'),
                            ),

                            ...comparisonProvider
                                .products
                                .map(
                                  (product) =>
                                      DataCell(
                                    Text(
                                      product.brand,
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        DataRow(
                          cells: [
                            const DataCell(
                              Text('Category'),
                            ),

                            ...comparisonProvider
                                .products
                                .map(
                                  (product) =>
                                      DataCell(
                                    Text(
                                      product.category,
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        DataRow(
                          cells: [
                            const DataCell(
                              Text('Price'),
                            ),

                            ...comparisonProvider
                                .products
                                .map(
                                  (product) =>
                                      DataCell(
                                    Text(
                                      '₱${product.price.toStringAsFixed(2)}',
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        DataRow(
                          cells: [
                            const DataCell(
                              Text('Stock'),
                            ),

                            ...comparisonProvider
                                .products
                                .map(
                                  (product) =>
                                      DataCell(
                                    Text(
                                      '${inventoryProvider.itemById(product.id)?.stock ?? 0}',
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        DataRow(
                          cells: [
                            const DataCell(
                              Text('Availability'),
                            ),

                            ...comparisonProvider
                                .products
                                .map(
                                  (product) =>
                                      DataCell(
                                    Text(
                                      (inventoryProvider.itemById(product.id)?.stock ?? 0) > 0
                                          ? 'In Stock'
                                          : 'Out of Stock',
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
