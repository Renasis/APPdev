import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final List<ProductModel> _products = [
    const ProductModel(
      id: '1',
      name: 'RTX 4060',
      category: 'GPU',
      brand: 'NVIDIA',
      price: 18999,
      image: 'assets/images/rtx4060.png',
      stock: 10,
      description:
          'NVIDIA GeForce RTX 4060 graphics card suitable for gaming and productivity.',
    ),

    const ProductModel(
      id: '2',
      name: 'Ryzen 7 7800X3D',
      category: 'CPU',
      brand: 'AMD',
      price: 19999,
      image: 'assets/images/ryzen7800x3d.png',
      stock: 5,
      description:
          'High performance AMD processor optimized for gaming.',
    ),

    const ProductModel(
      id: '3',
      name: 'Corsair Vengeance 16GB RAM',
      category: 'RAM',
      brand: 'Corsair',
      price: 3499,
      image: 'assets/images/ram.png',
      stock: 20,
      description:
          '16GB DDR5 memory module for modern PC builds.',
    ),

    const ProductModel(
      id: '4',
      name: 'MSI B650 Motherboard',
      category: 'Motherboard',
      brand: 'MSI',
      price: 8999,
      image: 'assets/images/motherboard.png',
      stock: 8,
      description:
          'AM5 motherboard supporting Ryzen processors.',
    ),

    const ProductModel(
      id: '5',
      name: 'Samsung 1TB SSD',
      category: 'Storage',
      brand: 'Samsung',
      price: 4599,
      image: 'assets/images/ssd.png',
      stock: 15,
      description:
          'Fast NVMe SSD for operating system and games.',
    ),

    ProductModel(
  id: 'psu-001',
  name: 'Corsair CX650',
  category: 'PSU',
  brand: 'Corsair',
  price: 3500.00,
  image: '',
  stock: 10,
  description: '650W 80 Plus Bronze power supply for gaming PCs.',
),
    const ProductModel(
      id: 'case-001',
      name: 'NZXT H5 Flow Case',
      category: 'Case',
      brand: 'NZXT',
      price: 4999,
      image: '',
      stock: 10,
      description: 'Mid-tower ATX case with high-airflow front panel.',
    ),
  ];

  List<ProductModel> get products => _products;

  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') {
      return _products;
    }

    return _products
        .where((product) => product.category == category)
        .toList();
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      return product.name
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          product.brand
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          product.category
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();
  }
}
