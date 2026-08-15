class SupportInquiryModel {
  final String id;
  final String customerId;
  final String subject;
  final String message;
  final String category;
  final String status;
  final String? staffReply;
  final DateTime createdAt;
  final DateTime? repliedAt;

  SupportInquiryModel({
    required this.id,
    this.customerId = '',
    required this.subject,
    required this.message,
    required this.category,
    required this.status,
    this.staffReply,
    required this.createdAt,
    this.repliedAt,
  });
}