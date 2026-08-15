import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_user_model.dart';
import 'package:pc_parts_application/core/enums/user_role.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

abstract interface class AuthService {
  Stream<AuthUserModel?> get authStateChanges;

  AuthUserModel? get currentUser;

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  });

  Future<AuthUserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> ensureTokenFresh();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthUserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_toModel);

  @override
  AuthUserModel? get currentUser => _toModel(_firebaseAuth.currentUser);

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toModel(credential.user)!;
    });
  }

  Future<void> ensureTokenFresh() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }

  @override
  Future<AuthUserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _guard(() async {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(fullName.trim());

      await user.getIdToken(true);

      return AuthUserModel(
        id: user.uid,
        fullName: fullName.trim(),
        email: user.email ?? email.trim(),
        phone: phone.trim(),
        role: UserRole.customer,
      );
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _guard(
      () => _firebaseAuth.sendPasswordResetEmail(email: email.trim()),
    );
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  AuthUserModel? _toModel(User? user) {
    if (user == null) {
      return null;
    }

    return AuthUserModel(
      id: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
    );
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}
