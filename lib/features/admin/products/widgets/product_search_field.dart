import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../products/providers/admin_product_provider.dart';

class ProductSearchField extends StatefulWidget {
  final AdminProduct? selectedProduct;
  final ValueChanged<AdminProduct?> onSelected;
  final String hintText;

  const ProductSearchField({
    super.key,
    this.selectedProduct,
    required this.onSelected,
    this.hintText = 'Search products...',
  });

  @override
  State<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<ProductSearchField> {
  final TextEditingController _searchController = TextEditingController();
  List<AdminProduct> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedProduct != null) {
      _searchController.text = widget.selectedProduct!.name;
    }
  }

  @override
  void didUpdateWidget(covariant ProductSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProduct != oldWidget.selectedProduct &&
        widget.selectedProduct != null) {
      _searchController.text = widget.selectedProduct!.name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    final products = context.read<AdminProductProvider>().products;
    final lowerQuery = query.toLowerCase();

    setState(() {
      _isSearching = query.isNotEmpty;
      _results = products.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AdminProductProvider>().products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _search('');
                      widget.onSelected(null);
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _search,
        ),
        if (_isSearching) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final product = _results[index];
                return ListTile(
                  dense: true,
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.category} · ₱${product.price.toStringAsFixed(2)}',
                  ),
                  onTap: () {
                    setState(() {
                      _searchController.text = product.name;
                      _isSearching = false;
                      _results = [];
                    });
                    widget.onSelected(product);
                  },
                );
              },
            ),
          ),
        ] else if (widget.selectedProduct != null) ...[
          const SizedBox(height: 8),
          Chip(
            label: Text(widget.selectedProduct!.name),
            onDeleted: () {
              _searchController.clear();
              widget.onSelected(null);
            },
          ),
        ],
      ],
    );
  }
}
