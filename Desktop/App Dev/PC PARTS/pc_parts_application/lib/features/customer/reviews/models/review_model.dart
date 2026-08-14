class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String customerName;
  final String comment;
  final double rating;
  final DateTime reviewDate;
  final bool verifiedPurchase;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.customerName,
    required this.comment,
    required this.rating,
    required this.reviewDate,
    required this.verifiedPurchase,
  });
}