import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/review_provider.dart';
import '../../orders/providers/order_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<WriteReviewScreen> createState() =>
      _WriteReviewScreenState();
}

class _WriteReviewScreenState
    extends State<WriteReviewScreen> {
  final commentController =
      TextEditingController();

  double rating = 5;

  @override
void dispose() {
  commentController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Review ${widget.productName}',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label:
                  rating.toString(),
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),

            Text(
              '${rating.toInt()} Stars',
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  commentController,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                labelText:
                    'Review Comment',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (commentController
                      .text
                      .trim()
                      .isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a review',
                        ),
                      ),
                    );

                    return;
                  }
                  final purchased =
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).hasPurchasedProduct(
      widget.productId,
    );

if (!purchased) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    const SnackBar(
      content: Text(
        'You can only review products you have purchased.',
      ),
    ),
  );

  return;
}

                  Provider.of<ReviewProvider>(
  context,
  listen: false,
).addReview(
  productId: widget.productId,
  productName: widget.productName,
  customerName: 'Customer',
  comment: commentController.text.trim(),
  rating: rating,
  verifiedPurchase: purchased,
);

                  Navigator.pop(
                    context,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Review submitted successfully.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Submit Review',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}