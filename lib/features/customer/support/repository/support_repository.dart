import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../models/support_inquiry_model.dart';

class SupportRepository {
  SupportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('supportInquiries');

  Stream<List<SupportInquiryModel>> watchInquiries() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportInquiryModel(
                  id: doc.id,
                  subject: doc.data()['subject'] as String? ?? '',
                  message: doc.data()['message'] as String? ?? '',
                  category: doc.data()['category'] as String? ?? 'Other',
                  status: doc.data()['status'] as String? ?? 'Pending',
                  staffReply: doc.data()['staffReply'] as String?,
                  createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  repliedAt: (doc.data()['repliedAt'] as Timestamp?)?.toDate(),
                ))
            .toList(growable: false));
  }

  Stream<List<SupportInquiryModel>> watchCustomerInquiries(String customerId) {
    return _collection
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportInquiryModel(
                  id: doc.id,
                  subject: doc.data()['subject'] as String? ?? '',
                  message: doc.data()['message'] as String? ?? '',
                  category: doc.data()['category'] as String? ?? 'Other',
                  status: doc.data()['status'] as String? ?? 'Pending',
                  staffReply: doc.data()['staffReply'] as String?,
                  createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  repliedAt: (doc.data()['repliedAt'] as Timestamp?)?.toDate(),
                ))
            .toList(growable: false));
  }

  Future<void> createInquiry(SupportInquiryModel inquiry, String customerId) async {
    await _collection.add({
      'customerId': customerId,
      'subject': inquiry.subject,
      'message': inquiry.message,
      'category': inquiry.category,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> replyToInquiry(String inquiryId, String reply) async {
    await _collection.doc(inquiryId).update({
      'staffReply': reply,
      'status': 'In Progress',
      'repliedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveInquiry(String inquiryId) async {
    await _collection.doc(inquiryId).update({
      'status': 'Resolved',
    });
  }

  Future<void> closeInquiry(String inquiryId) async {
    await _collection.doc(inquiryId).update({
      'status': 'Closed',
    });
  }
}
