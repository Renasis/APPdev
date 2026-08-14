import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StaffAccountService {
  StaffAccountService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<Map<String, dynamic>>> watchStaffAccounts() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<List<Map<String, dynamic>>> fetchStaffAccounts() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>?> fetchStaffAccount(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<Map<String, dynamic>> createStaffAccount({
    required String name,
    required String email,
    required String phone,
  }) async {
    final result = await _functions
        .httpsCallable('createStaffAccount')
        .call<Map<String, dynamic>>({
          'name': name,
          'email': email,
          'role': 'staff',
          'phone': phone,
        });

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> disableStaffAccount(String uid) async {
    final result = await _functions
        .httpsCallable('disableStaffAccount')
        .call<Map<String, dynamic>>({'uid': uid});

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> enableStaffAccount(String uid) async {
    final result = await _functions
        .httpsCallable('enableStaffAccount')
        .call<Map<String, dynamic>>({'uid': uid});

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> deleteStaffAccount(String uid) async {
    final result = await _functions
        .httpsCallable('deleteStaffAccount')
        .call<Map<String, dynamic>>({'uid': uid});

    return Map<String, dynamic>.from(result.data);
  }

  Future<void> updateStaffProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
