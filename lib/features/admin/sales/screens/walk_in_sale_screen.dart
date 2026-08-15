import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/walk_in_sale_provider.dart';
import '../../../customer/products/providers/product_provider.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../models/walk_in_sale_model.dart';

class WalkInSaleScreen extends StatefulWidget {
  const WalkInSaleScreen({super.key});

  @override
  State<WalkInSaleScreen> createState() => _WalkInSaleScreenState();
}

class _WalkInSaleScreenState extends State<WalkInSaleScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  String _selectedProductId = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts(String query, ProductProvider productProvider) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchResults = productProvider.products
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .map((p) => p.id)
          .toList();
      if (_searchResults.isNotEmpty) {
        _selectedProductId = _searchResults.first;
      }
    });
  }

  Future<void> _addToSale(WalkInSaleProvider saleProvider, ProductProvider productProvider) async {
    if (_selectedProductId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product.')),
      );
      return;
    }

    final product = productProvider.products.firstWhere((p) => p.id == _selectedProductId);
    final quantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add ${product.name}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (quantity == null || quantity <= 0) {
      return;
    }

    saleProvider.addItem(WalkInSaleItem(
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.price,
    ));

    _searchController.clear();
    setState(() {
      _searchResults = [];
      _selectedProductId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk-In Sale'),
      ),
      body: Consumer3<WalkInSaleProvider, ProductProvider, AuthProvider>(
        builder: (context, saleProvider, productProvider, authProvider, child) {
          final auth = authProvider.currentUser;

          if (auth == null) {
            return const Center(child: Text('Please log in to process walk-in sales.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search products...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _searchProducts(value, productProvider),
                    ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.products.firstWhere((p) => p.id == _searchResults[index]);
                            return ListTile(
                              dense: true,
                              title: Text(product.name),
                              subtitle: Text('₱${product.price.toStringAsFixed(2)}'),
                              trailing: _selectedProductId == product.id
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() => _selectedProductId = product.id);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: saleProvider.setCustomerName,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Contact Number',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: saleProvider.setContactNumber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: saleProvider.paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          saleProvider.setPaymentMethod(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: saleProvider.items.isEmpty
                    ? const Center(child: Text('No items added yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: saleProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = saleProvider.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text('${item.quantity} × ₱${item.unitPrice.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('₱${item.subtotal.toStringAsFixed(2)}'),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => saleProvider.removeItem(item.productId),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₱${saleProvider.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saleProvider.isLoading
                            ? null
                            : () async {
                                final success = await saleProvider.completeSale(
                                  performedByUid: auth.id,
                                  performedByName: auth.fullName,
                                  performedByRole: 'staff',
                                );

                                if (!mounted) return;

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(saleProvider.successMessage ?? 'Sale completed')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(saleProvider.errorMessage ?? 'Sale failed')),
                                  );
                                }
                              },
                        child: saleProvider.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Complete Sale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
