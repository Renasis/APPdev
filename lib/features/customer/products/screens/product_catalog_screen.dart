import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_comparison_screen.dart';


class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState
    extends State<ProductCatalogScreen> {
  String searchQuery = '';

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'CPU',
    'GPU',
    'RAM',
    'Storage',
    'Motherboard',
    'PSU',
    'Case',
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context);

    List<ProductModel> products =
        productProvider.searchProducts(searchQuery);

    if (selectedCategory != 'All') {
      products = products.where((product) {
        return product.category == selectedCategory;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false,
  title: const Text('Products'),

  actions: [
    IconButton(
      icon: const Icon(
        Icons.compare_arrows,
      ),

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ProductComparisonScreen(),
          ),
        );
      },
    ),
  ],
),

      body: Column(
        children: [

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },

              decoration: InputDecoration(
                hintText: 'Search PC Components',

                prefixIcon:
                    const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          // Category Filters
          SizedBox(
            height: 50,

            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,

              itemCount:
                  categories.length,

              itemBuilder:
                  (context, index) {

                final category =
                    categories[index];

                final isSelected =
                    category ==
                        selectedCategory;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),

                  child: ChoiceChip(
                    label: Text(category),

                    selected: isSelected,

                    onSelected: (_) {
                      setState(() {
                        selectedCategory =
                            category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.all(10),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
              ),

              itemCount: products.length,

              itemBuilder:
                  (context, index) {

                return ProductCard(
                  product:
                      products[index],
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}
