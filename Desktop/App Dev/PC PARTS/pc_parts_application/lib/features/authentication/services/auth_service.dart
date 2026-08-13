class AuthService {
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    return true;
  }
}