import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({
    super.key,
  });

  @override
  State<StockOutScreen> createState() =>
      _StockOutScreenState();
}

class _StockOutScreenState
    extends State<StockOutScreen> {
  final searchController =
      TextEditingController();

  final quantityController =
      TextEditingController(text: '0');

  final notesController =
      TextEditingController();

  InventoryItem? selectedProduct;

  String selectedReason =
      'Damaged / Defective';

  final List<String> reasons = [
    'Damaged / Defective',
    'Stock Adjustment',
    'Customer Return',
    'Internal Use',
    'Write-off',
  ];

  @override
  void dispose() {
    searchController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.dispose();
  }

  List<InventoryItem> getFilteredProducts(
    InventoryProvider provider,
  ) {
    final query =
        searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return provider.items;
    }

    return provider.items.where(
      (item) {
        return item.productName
            .toLowerCase()
            .contains(query);
      },
    ).toList();
  }

  Future<void> recordStockOut() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a product.',
          ),
        ),
      );

      return;
    }

    final quantity =
        int.tryParse(quantityController.text);

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid quantity to deduct.',
          ),
        ),
      );

      return;
    }

    final provider =
        context.read<InventoryProvider>();

    final previousStock =
        selectedProduct!.stock;

    final success = await provider.deductStock(
      selectedProduct!.id,
      quantity,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient stock. Available: $previousStock',
          ),
        ),
      );

      return;
    }

    final newStock =
        previousStock - quantity;

    final movement = StockMovement(
      id: 'SM-${DateTime.now().millisecondsSinceEpoch}',
      productId: selectedProduct!.id,
      productName: selectedProduct!.productName,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      reason: selectedReason,
      notes: notesController.text.trim(),
      date: DateTime.now(),
      type: 'Stock Out',
      performedByUid: '',
      performedByName: '',
      performedByRole: '',
    );

    provider.addStockMovement(
      movement,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedProduct!.productName}: $quantity unit(s) deducted.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Out',
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 12),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: recordStockOut,
                icon: const Icon(
                  Icons.save_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Record',
                ),
              ),
            ),
          ),
        ],
      ),

      body: Consumer<InventoryProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final filteredProducts =
              getFilteredProducts(provider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // INFORMATION BANNER
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red.shade700,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Record manual stock deduction (not from a sale)',
                          style: TextStyle(
                            color:
                                Colors.red.shade800,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // PRODUCT
                const Text(
                  'Product',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: searchController,

                  onChanged: (_) {
                    setState(() {});
                  },

                  decoration: InputDecoration(
                    hintText:
                        'Search product by name or SKU...',

                    prefixIcon: const Icon(
                      Icons.search,
                    ),

                    suffixIcon:
                        selectedProduct != null
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedProduct =
                                        null;
                                    searchController
                                        .clear();
                                  });
                                },
                              )
                            : null,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (selectedProduct == null &&
                    searchController.text
                        .isNotEmpty)
                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    child: filteredProducts.isEmpty
                        ? const Padding(
                            padding:
                                EdgeInsets.all(16),
                            child: Text(
                              'No products found.',
                            ),
                          )
                        : Column(
                            children:
                                filteredProducts.map(
                              (product) {
                                return ListTile(
                                  title: Text(
                                    product.productName,
                                  ),

                                  subtitle: Text(
                                    'Current stock: ${product.stock}',
                                  ),

                                  onTap: () {
                                    setState(() {
                                      selectedProduct =
                                          product;

                                      searchController
                                              .text =
                                          product
                                              .productName;

                                      searchController
                                              .selection =
                                          TextSelection
                                              .fromPosition(
                                        TextPosition(
                                          offset:
                                              searchController
                                                  .text
                                                  .length,
                                        ),
                                      );
                                    });
                                  },
                                );
                              },
                            ).toList(),
                          ),
                  ),

                if (selectedProduct != null) ...[
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color:
                              Colors.blue.shade700,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                selectedProduct!
                                    .productName,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Current Stock: ${selectedProduct!.stock}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // QUANTITY
                const Text(
                  'Quantity to Deduct',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      quantityController,

                  keyboardType:
                      TextInputType.number,

                  onChanged: (_) {
                    setState(() {});
                  },

                  decoration: InputDecoration(
                    hintText: '0',

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (selectedProduct != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 8,
                    ),

                    child: _StockPreview(
                      currentStock:
                          selectedProduct!.stock,
                      quantity: int.tryParse(
                            quantityController
                                .text,
                          ) ??
                          0,
                    ),
                  ),

                const SizedBox(height: 24),

                // REASON
                const Text(
                  'Reason',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                ...reasons.map(
                  (reason) {
                    final isSelected =
                        selectedReason ==
                            reason;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),

                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

                        onTap: () {
                          setState(() {
                            selectedReason =
                                reason;
                          });
                        },

                        child: Container(
                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .grey.shade50,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),

                            border: Border.all(
                              color: isSelected
                                  ? Colors
                                      .grey
                                      .shade800
                                  : Colors
                                      .grey
                                      .shade300,
                            ),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons
                                        .radio_button_checked
                                    : Icons
                                        .radio_button_off,

                                color: isSelected
                                    ? Colors
                                        .grey
                                        .shade900
                                    : Colors
                                        .grey
                                        .shade400,
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Text(
                                reason,
                                style:
                                    TextStyle(
                                  color: isSelected
                                      ? Colors
                                          .grey
                                          .shade900
                                      : Colors
                                          .grey
                                          .shade600,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight
                                              .w500
                                          : FontWeight
                                              .normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // NOTES
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: notesController,

                  maxLines: 3,

                  decoration: InputDecoration(
                    hintText: 'Add notes...',

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed: recordStockOut,

                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),

                    label: const Text(
                      'Record Stock Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StockPreview extends StatelessWidget {
  final int currentStock;
  final int quantity;

  const _StockPreview({
    required this.currentStock,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final remaining =
        currentStock - quantity;

    final isInvalid =
        quantity > currentStock ||
        quantity <= 0;

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: isInvalid
            ? Colors.red.shade50
            : Colors.green.shade50,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          const Text(
            'Remaining Stock',
          ),

          Text(
            remaining < 0
                ? 'Insufficient Stock'
                : '$remaining',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isInvalid
                  ? Colors.red.shade700
                  : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}