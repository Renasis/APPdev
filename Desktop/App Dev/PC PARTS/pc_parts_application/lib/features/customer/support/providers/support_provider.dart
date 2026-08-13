import 'package:flutter/material.dart';

import '../models/support_inquiry_model.dart';



class SupportProvider extends ChangeNotifier {
  final List<SupportInquiryModel> _inquiries = [];

  List<SupportInquiryModel> get inquiries => _inquiries;

  void createInquiry({
    required String subject,
    required String message,
    required String category,
  }) {
    final inquiry = SupportInquiryModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      subject: subject,
      message: message,
      category: category,
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    _inquiries.insert(0, inquiry);

    notifyListeners();
  }

  void updateInquiryStatus(
    String inquiryId,
    String status,
  ) {
    final index = _inquiries.indexWhere(
      (inquiry) => inquiry.id == inquiryId,
    );

    if (index == -1) {
      return;
    }

    final inquiry = _inquiries[index];

    _inquiries[index] = SupportInquiryModel(
      id: inquiry.id,
      subject: inquiry.subject,
      message: inquiry.message,
      category: inquiry.category,
      status: status,
      staffReply: inquiry.staffReply,
      createdAt: inquiry.createdAt,
      repliedAt: inquiry.repliedAt,
    );

    notifyListeners();
  }

  void addStaffReply({
    required String inquiryId,
    required String reply,
  }) {
    final index = _inquiries.indexWhere(
      (inquiry) => inquiry.id == inquiryId,
    );

    if (index == -1) {
      return;
    }

    final inquiry = _inquiries[index];

    _inquiries[index] = SupportInquiryModel(
      id: inquiry.id,
      subject: inquiry.subject,
      message: inquiry.message,
      category: inquiry.category,
      status: 'In Progress',
      staffReply: reply,
      createdAt: inquiry.createdAt,
      repliedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void closeInquiry(String inquiryId) {
    updateInquiryStatus(
      inquiryId,
      'Closed',
    );
  }

  void clearInquiries() {
    _inquiries.clear();

    notifyListeners();
  }
}