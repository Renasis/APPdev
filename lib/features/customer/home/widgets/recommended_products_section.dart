import 'package:flutter/material.dart';

import 'recommended_product_card.dart';

class RecommendedProductsSection extends StatelessWidget {
  const RecommendedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (_, index) {
          return const RecommendedProductCard();
        },
      ),
    );
  }
}