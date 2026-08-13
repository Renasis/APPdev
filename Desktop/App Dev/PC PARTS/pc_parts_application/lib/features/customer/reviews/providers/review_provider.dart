import 'package:flutter/material.dart';

import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final List<ReviewModel> _reviews = [];

  List<ReviewModel> get reviews => _reviews;

  void addReview({
  required String productId,
  required String productName,
  required String customerName,
  required String comment,
  required double rating,
  required bool verifiedPurchase,
}) {
  _reviews.insert(
    0,
    ReviewModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      productId: productId,
      productName: productName,
      customerName: customerName,
      comment: comment,
      rating: rating,
      reviewDate: DateTime.now(),
      verifiedPurchase:
          verifiedPurchase,
    ),
  );

  notifyListeners();
}

  List<ReviewModel> getProductReviews(
    String productId,
  ) {
    return _reviews
        .where(
          (review) =>
              review.productId ==
              productId,
        )
        .toList();
  }

  double getAverageRating(
    String productId,
  ) {
    final reviews =
        getProductReviews(productId);

    if (reviews.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final review in reviews) {
      total += review.rating;
    }

    return total / reviews.length;
  }
}