import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAccountService {
  StaffAccountService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('staffInvitations');

  Stream<List<Map<String, dynamic>>> watchStaffAccounts() {
    return _users
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'uid': doc.id,
            };
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> watchPendingInvitations() {
    return _invitations
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id,
            };
          }).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> fetchStaffAccounts() async {
    final snapshot = await _users
        .where('role', isEqualTo: 'staff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'uid': doc.id,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> fetchStaffAccount(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return {
      ...?doc.data(),
      'uid': doc.id,
    };
  }

  /// Creates a pending staff invitation.
  ///
  /// This does NOT create a Firebase Authentication account.
  /// The actual Firebase Auth account is created when the invited
  /// staff member completes registration.
  Future<Map<String, dynamic>> createStaffAccount({
    required String name,
    required String email,
    required String phone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      // Check whether an existing Firebase/Firestore staff invitation
      // already exists for this email.
      final existingInvitation =
          await _invitations.doc(normalizedEmail).get();

      if (existingInvitation.exists) {
        return {
          'success': false,
          'error': 'A staff invitation already exists for this email.',
        };
      }

      // Check existing user documents.
      final existingUsers = await _users
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        return {
          'success': false,
          'error': 'An account already exists for this email.',
        };
      }

      await _invitations.doc(normalizedEmail).set({
        'name': name.trim(),
        'email': normalizedEmail,
        'phone': phone.trim(),
        'role': 'staff',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'email': normalizedEmail,
      };
    } on FirebaseException catch (error) {
      return {
        'success': false,
        'error': error.message ?? 'Failed to create staff invitation.',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to create staff invitation.',
      };
    }
  }

  /// Finds a pending invitation using the staff email.
  Future<Map<String, dynamic>?> fetchPendingInvitation(
    String email,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();

    final doc = await _invitations.doc(normalizedEmail).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null || data['status'] != 'pending') {
      return null;
    }

    return {
      ...data,
      'email': normalizedEmail,
    };
  }

  /// Activates the staff invitation after Firebase Authentication
  /// has created the user's UID.
  Future<void> activateStaffAccount({
    required String uid,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final invitation = await _invitations.doc(normalizedEmail).get();

    if (!invitation.exists) {
      throw Exception('Staff invitation not found.');
    }

    final data = invitation.data();

    if (data == null ||
        data['status'] != 'pending' ||
        data['role'] != 'staff') {
      throw Exception('This staff invitation is no longer available.');
    }

    await _users.doc(uid).set({
      'name': data['name'] ?? '',
      'email': normalizedEmail,
      'phone': data['phone'] ?? '',
      'role': 'staff',
      'isActive': true,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _invitations.doc(normalizedEmail).update({
      'status': 'accepted',
      'uid': uid,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Disables the staff account inside the application.
  ///
  /// Note:
  /// This does not disable Firebase Authentication itself.
  /// The login flow will check isActive and reject disabled staff.
  Future<Map<String, dynamic>> disableStaffAccount(String uid) async {
    try {
      await _users.doc(uid).update({
        'isActive': false,
        'status': 'inactive',
      });

      return {
        'success': true,
      };
    } on FirebaseException catch (error) {
      return {
        'success': false,
        'error': error.message ?? 'Failed to disable staff account.',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to disable staff account.',
      };
    }
  }

  /// Enables the staff account inside the application.
  Future<Map<String, dynamic>> enableStaffAccount(String uid) async {
    try {
      await _users.doc(uid).update({
        'isActive': true,
        'status': 'active',
      });

      return {
        'success': true,
      };
    } on FirebaseException catch (error) {
      return {
        'success': false,
        'error': error.message ?? 'Failed to enable staff account.',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to enable staff account.',
      };
    }
  }

  /// Deletes the staff profile from Firestore.
  ///
  /// Without Cloud Functions/Admin SDK, we cannot delete the
  /// Firebase Authentication account from another user's session.
  Future<Map<String, dynamic>> deleteStaffAccount(String uid) async {
    try {
      await _users.doc(uid).delete();

      return {
        'success': true,
      };
    } on FirebaseException catch (error) {
      return {
        'success': false,
        'error': error.message ?? 'Failed to delete staff account.',
      };
    } catch (error) {
      return {
        'success': false,
        'error': 'Failed to delete staff account.',
      };
    }
  }

  Future<void> updateStaffProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _users.doc(uid).update(data);
  }
}