import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pc_parts_application/core/enums/user_role.dart';
import 'package:pc_parts_application/core/services/firebase_service.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  Stream<Map<String, dynamic>?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data();
  }

  Future<UserRole?> fetchUserRole(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final data = doc.data();
      if (data == null) return null;

      final role = data['role'] as String?;
      if (role == null) return null;

      return UserRole.values.firstWhere(
        (e) => e.name == role,
        orElse: () => UserRole.customer,
      );
    } on FirebaseException {
      return null;
    }
  }

  Future<bool> isActive(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final data = doc.data();
      if (data == null) return false;

      final isActive = data['isActive'];
      if (isActive is bool) return isActive;

      return false;
    } on FirebaseException {
      return false;
    }
  }

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
    bool isActive = true,
  }) async {
    await _users.doc(uid).set({
      'name': name,
      'email': email,
      'role': role.name,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _users.doc(uid).update({'role': role.name});
  }

  Future<void> setUserActive(String uid, bool active) async {
    await _users.doc(uid).update({'isActive': active});
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Stream<List<Map<String, dynamic>>> watchCustomers() {
    return _users
        .where('role', isEqualTo: 'customer')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'uid': doc.id,
            };
          }).toList(growable: false),
        );
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final snapshot = await _users
        .where('role', isEqualTo: 'customer')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'uid': doc.id,
      };
    }).toList();
  }
}
