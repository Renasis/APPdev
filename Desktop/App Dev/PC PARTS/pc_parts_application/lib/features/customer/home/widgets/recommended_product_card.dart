import 'package:flutter/material.dart';

class RecommendedProductCard extends StatelessWidget {
  const RecommendedProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Icon(
                Icons.memory,
                size: 70,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'RTX 4060',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('₱18,999'),
          ],
        ),
      ),
    );
  }
}