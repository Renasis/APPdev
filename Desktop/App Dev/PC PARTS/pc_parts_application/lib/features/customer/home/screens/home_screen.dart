import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../products/providers/product_provider.dart';
import '../../products/screens/product_catalog_screen.dart';
import '../../products/widgets/product_card.dart';
import '../../products/providers/recently_viewed_provider.dart';
import '../../products/screens/search_screen.dart';
import '../../pc_builder/screens/pc_builder_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final recentlyViewed =
       context.watch<RecentlyViewedProvider>().recentlyViewed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: const [
        Text(
          'End PC Parts',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 4),

        Text(
          'Build your dream PC',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      ],
    ),

    Consumer<CartProvider>(
      builder:
          (context, cartProvider, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 30,
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CartScreen(),
                  ),
                );
              },
            ),

            if (cartProvider.totalItems > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.all(5),

                  decoration:
                      const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),

                  child: Text(
                    '${cartProvider.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  ],
),
              const SizedBox(height: 25),

              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const SearchScreen(),
    ),
  );
},
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 15),
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Search PC Components...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryChip(context, 'CPU'),
                    _categoryChip(context, 'GPU'),
                    _categoryChip(context, 'RAM'),
                    _categoryChip(context, 'Motherboard'),
                    _categoryChip(context, 'Storage'),
                    _categoryChip(context, 'PSU'),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              Container(
                height: 170,
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF4657C8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'PC Parts Sale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Up to 30% off selected components',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PcBuilderScreen(),
    ),
  );
},
                child: Ink(
                  width: 280,
                  height: 140,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      Spacer(),
                      Text(
                        'PC Builder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a compatible PC build',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended Products',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openCatalog(context),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No products are available yet.'),
                  ),
                )
              else
                SizedBox(
                  height: 290,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 220,
                        child: ProductCard(
                          product: products[index],
                        ),
                      );
                    },
                  ),
                ),
                            if (recentlyViewed.isNotEmpty) ...[
                const SizedBox(height: 30),

                const Text(
                  'Recently Viewed Products',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 290,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentlyViewed.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 220,
                        child: ProductCard(
                          product: recentlyViewed[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(BuildContext context, String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        label: Text(category),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Browse $category products in Products.'),
            ),
          );

          _openCatalog(context);
        },
      ),
    );
  }

  void _openCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductCatalogScreen(),
      ),
    );
  }
}