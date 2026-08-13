import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/review_provider.dart';
import '../widgets/review_card.dart';
import 'write_review_screen.dart';

class ReviewsScreen extends StatelessWidget {
  final String productId;
  final String productName;

  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final reviewProvider =
        Provider.of<ReviewProvider>(context);

    final reviews =
        reviewProvider.getProductReviews(
      productId,
    );

    final averageRating =
        reviewProvider.getAverageRating(
      productId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$productName Reviews',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WriteReviewScreen(
                    productId: productId,
                    productName: productName,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.rate_review,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      averageRating
                          .toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 32,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${reviews.length} Reviews',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: reviews.isEmpty
                  ? const Center(
                      child: Text(
                        'No reviews yet',
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          reviews.length,
                      itemBuilder:
                          (context, index) {
                        return ReviewCard(
                          review:
                              reviews[index],
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