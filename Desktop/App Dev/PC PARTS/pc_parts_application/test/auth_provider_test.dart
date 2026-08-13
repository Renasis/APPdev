import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/authentication/models/auth_user_model.dart';
import 'package:pc_parts_application/features/authentication/providers/auth_provider.dart';
import 'package:pc_parts_application/features/authentication/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.failWith});

  final String? failWith;

  final _controller = StreamController<AuthUserModel?>.broadcast();

  AuthUserModel? _user;
  String? resetEmail;

  @override
  Stream<AuthUserModel?> get authStateChanges => _controller.stream;

  @override
  AuthUserModel? get currentUser => _user;

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    return _authenticate(
      AuthUserModel(id: 'uid-1', fullName: 'Josh', email: email, phone: ''),
    );
  }

  @override
  Future<AuthUserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _authenticate(
      AuthUserModel(
        id: 'uid-1',
        fullName: fullName,
        email: email,
        phone: phone,
      ),
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (failWith != null) {
      throw AuthException(failWith!);
    }
    resetEmail = email;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  AuthUserModel _authenticate(AuthUserModel user) {
    if (failWith != null) {
      throw AuthException(failWith!);
    }

    _user = user;
    _controller.add(user);
    return user;
  }
}

void main() {
  test('a successful sign in leaves guest mode with the user loaded', () async {
    final provider = AuthProvider(_FakeAuthService());

    expect(
      await provider.login(email: 'josh@example.com', password: 'secret'),
      isTrue,
    );
    expect(provider.isLoggedIn, isTrue);
    expect(provider.isGuest, isFalse);
    expect(provider.isLoading, isFalse);
    expect(provider.currentUser?.email, 'josh@example.com');
    expect(provider.errorMessage, isNull);
  });

  test('registration keeps the phone number Firebase does not store', () async {
    final provider = AuthProvider(_FakeAuthService());

    await provider.register(
      fullName: 'Josh',
      email: 'josh@example.com',
      phone: '09171234567',
      password: 'secret',
    );

    expect(provider.currentUser?.phone, '09171234567');
  });

  test('a failed sign in exposes the error and stays a guest', () async {
    final provider = AuthProvider(
      _FakeAuthService(failWith: 'Incorrect email or password.'),
    );

    expect(
      await provider.login(email: 'josh@example.com', password: 'nope'),
      isFalse,
    );
    expect(provider.isLoggedIn, isFalse);
    expect(provider.isGuest, isTrue);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, 'Incorrect email or password.');
  });

  test('logging out clears the session', () async {
    final provider = AuthProvider(_FakeAuthService());
    await provider.login(email: 'josh@example.com', password: 'secret');

    await provider.logout();

    expect(provider.isLoggedIn, isFalse);
    expect(provider.isGuest, isTrue);
    expect(provider.currentUser, isNull);
  });
}
