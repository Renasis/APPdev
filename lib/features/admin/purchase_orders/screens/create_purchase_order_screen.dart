import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/purchase_order_provider.dart';
import '../../suppliers/providers/supplier_provider.dart';
import '../../products/providers/admin_product_provider.dart';
import '../../products/widgets/product_search_field.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  const CreatePurchaseOrderScreen({
    super.key,
  });

  @override
  State<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState
    extends State<CreatePurchaseOrderScreen> {
  String? selectedSupplier;

  AdminProduct? selectedProduct;

  final quantityController =
      TextEditingController(text: '1');

  final List<PurchaseOrderItem> selectedItems = [];

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void addItem() {
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
            'Enter a valid quantity.',
          ),
        ),
      );
      return;
    }

    final item = PurchaseOrderItem(
      productId: selectedProduct!.id,
      productName: selectedProduct!.name,
      unitPrice: selectedProduct!.price,
      quantity: quantity,
    );

    setState(() {
      selectedItems.add(item);
      selectedProduct = null;
      quantityController.text = '1';
    });
  }

  void createPurchaseOrder() {
    if (selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a supplier.',
          ),
        ),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one product.',
          ),
        ),
      );
      return;
    }

    final provider =
        context.read<PurchaseOrderProvider>();

    final nextNumber =
        provider.purchaseOrders.length + 1;

    final order = PurchaseOrder(
      id: 'PO-${nextNumber.toString().padLeft(3, '0')}',
      supplierName: selectedSupplier!,
      status: 'Draft',
      items: List.from(selectedItems),
    );

    provider.addPurchaseOrder(order);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Purchase Order',
        ),
      ),

      body: Consumer2<
          SupplierProvider,
          AdminProductProvider>(
        builder: (
          context,
          supplierProvider,
          productProvider,
          child,
        ) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Supplier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                   initialValue: selectedSupplier,
                  decoration: InputDecoration(
                    hintText:
                        'Select supplier',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  items: supplierProvider.suppliers
                      .map(
                        (supplier) =>
                            DropdownMenuItem<String>(
                          value: supplier.name,
                          child: Text(
                            supplier.name,
                          ),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedSupplier = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                ProductSearchField(
                  selectedProduct: selectedProduct,
                  onSelected: (product) {
                    setState(() {
                      selectedProduct = product;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: quantityController,
                  keyboardType:
                      TextInputType.number,

                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: OutlinedButton.icon(
                    onPressed: addItem,

                    icon: const Icon(
                      Icons.add,
                    ),

                    label: const Text(
                      'Add Product',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                if (selectedItems.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Center(
                      child: Text(
                        'No products added yet.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                ...selectedItems.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Card(
                      child: ListTile(
                        title: Text(
                          item.productName,
                        ),

                        subtitle: Text(
                          '${item.quantity} × ₱${item.unitPrice.toStringAsFixed(2)}',
                        ),

                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              '₱${item.total.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              onPressed: () {
                                setState(() {
                                  selectedItems
                                      .removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                if (selectedItems.isNotEmpty)
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            '₱${selectedItems.fold<double>(
                              0,
                              (
                                total,
                                item,
                              ) =>
                                  total + item.total,
                            ).toStringAsFixed(2)}',

                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    onPressed:
                        createPurchaseOrder,

                    child: const Text(
                      'Create Purchase Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}