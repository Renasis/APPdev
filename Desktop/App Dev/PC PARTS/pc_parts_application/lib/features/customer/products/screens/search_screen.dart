import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final products =
        context.watch<ProductProvider>().products;

    final filteredProducts =
        products.where((product) {
      return product.name
              .toLowerCase()
              .contains(
                searchQuery.toLowerCase(),
              ) ||
          product.brand
              .toLowerCase()
              .contains(
                searchQuery.toLowerCase(),
              );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Products',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText:
                    'Search PC Components...',
                prefixIcon:
                    const Icon(Icons.search),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found.',
                      ),
                    )
                  : GridView.builder(
                      itemCount:
                          filteredProducts.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                      ),

                      itemBuilder:
                          (context, index) {
                        return ProductCard(
                          product:
                              filteredProducts[
                                  index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}