import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/firebase_service.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  Stream<List<Map<String, dynamic>>> watchNotificationsForUser(String recipientUid) {
    return _collection
        .where('recipientUid', isEqualTo: recipientUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                'id': doc.id,
              };
            }).toList(growable: false));
  }

  Future<void> addNotification(Map<String, dynamic> data) async {
    debugPrint('[NOTIFICATION REPO] addNotification started');
    await _collection.add(data);
    debugPrint('[NOTIFICATION REPO] addNotification completed');
  }

  Future<void> updateNotification(String id, Map<String, dynamic> data) async {
    debugPrint('[NOTIFICATION REPO] updateNotification started: id=$id');
    await _collection.doc(id).update(data);
    debugPrint('[NOTIFICATION REPO] updateNotification completed');
  }

  Future<void> setNotification(String id, Map<String, dynamic> data) async {
    debugPrint('[NOTIFICATION REPO] setNotification started: id=$id');
    await _collection.doc(id).set(data);
    debugPrint('[NOTIFICATION REPO] setNotification completed');
  }

  Future<void> deleteNotification(String id) async {
    debugPrint('[NOTIFICATION REPO] deleteNotification started: id=$id');
    await _collection.doc(id).delete();
    debugPrint('[NOTIFICATION REPO] deleteNotification completed');
  }

  Future<void> clearNotificationsForUser(String recipientUid) async {
    final snapshot = await _collection
        .where('recipientUid', isEqualTo: recipientUid)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
