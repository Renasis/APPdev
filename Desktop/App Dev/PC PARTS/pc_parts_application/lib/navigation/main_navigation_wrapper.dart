import 'package:flutter/material.dart';

import '../features/customer/home/screens/home_screen.dart';
import '../features/customer/profile/screens/profile_screen.dart';
import '../features/customer/products/screens/product_catalog_screen.dart';
import '../features/customer/wishlist/screens/wishlist_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const MainNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationWrapper> createState() =>
      _MainNavigationWrapperState();
}

class _MainNavigationWrapperState
    extends State<MainNavigationWrapper> {
  late int currentIndex;

  final pages = const [
    HomeScreen(),
    ProductCatalogScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
void initState() {
  super.initState();
  currentIndex = widget.initialIndex;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),

  BottomNavigationBarItem(
    icon: Icon(Icons.store),
    label: 'Products',
  ),

  BottomNavigationBarItem(
    icon: Icon(Icons.favorite),
    label: 'Wishlist',
  ),

  BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'Profile',
  ),
],
      ),
    );
  }
}