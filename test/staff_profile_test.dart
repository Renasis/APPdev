import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pc_parts_application/features/staff/profile/screens/staff_profile_screen.dart';
import 'package:pc_parts_application/features/authentication/providers/auth_provider.dart';
import 'package:pc_parts_application/features/authentication/models/auth_user_model.dart';
import 'package:pc_parts_application/features/authentication/services/auth_service.dart';
import 'package:pc_parts_application/features/authentication/services/user_service.dart';
import 'package:pc_parts_application/features/admin/staff/services/staff_account_service.dart';
import 'package:pc_parts_application/core/enums/user_role.dart';

class _FakeAuthService implements AuthService {
  @override
  Stream<AuthUserModel?> get authStateChanges => const Stream.empty();

  @override
  AuthUserModel? get currentUser => AuthUserModel(id: 'staff-1', fullName: 'Staff User', email: 'staff@example.com', phone: '09171234567');

  @override
  Future<AuthUserModel> signIn({required String email, required String password}) async => currentUser!;

  @override
  Future<AuthUserModel> register({required String fullName, required String email, required String phone, required String password}) async => currentUser!;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> ensureTokenFresh() async {}
}

class _FakeUserService implements UserService {
  const _FakeUserService();

  @override
  Future<UserRole?> fetchUserRole(String uid) async => UserRole.staff;

  @override
  Future<bool> isActive(String uid) async => true;

  @override
  Future<Map<String, dynamic>?> fetchUser(String uid) async => null;

  @override
  Stream<Map<String, dynamic>?> watchUser(String uid) async* {}

  @override
  Future<void> createUser({required String uid, required String name, required String email, required UserRole role, bool isActive = true}) async {}

  @override
  Future<void> updateUserRole(String uid, UserRole role) async {}

  @override
  Future<void> setUserActive(String uid, bool active) async {}

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {}

  @override
  Stream<List<Map<String, dynamic>>> watchCustomers() async* {}

  @override
  Future<List<Map<String, dynamic>>> fetchCustomers() async => [];
}

class _FakeStaffAccountService implements StaffAccountService {
  const _FakeStaffAccountService();

  @override
  Future<Map<String, dynamic>> createStaffAccount({required String name, required String email, required String phone}) async => {'success': true};

  @override
  Future<void> activateStaffAccount({required String uid, required String email}) async {}

  @override
  Future<Map<String, dynamic>> disableStaffAccount(String uid) async => {'success': true};

  @override
  Future<Map<String, dynamic>> enableStaffAccount(String uid) async => {'success': true};

  @override
  Future<Map<String, dynamic>> deleteStaffAccount(String uid) async => {'success': true};

  @override
  Future<void> updateStaffProfile(String uid, Map<String, dynamic> data) async {}

  @override
  Stream<List<Map<String, dynamic>>> watchStaffAccounts() => const Stream.empty();

  @override
  Future<List<Map<String, dynamic>>> fetchStaffAccounts() async => [];

  @override
  Future<Map<String, dynamic>?> fetchStaffAccount(String uid) async => null;

  @override
  Future<Map<String, dynamic>?> fetchPendingInvitation(String email) async => null;

  @override
  Stream<List<Map<String, dynamic>>> watchPendingInvitations() => const Stream.empty();
}

void main() {
  testWidgets('shows the temporary staff profile details', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(_FakeAuthService(), _FakeUserService(), _FakeStaffAccountService()),
        child: const MaterialApp(home: Scaffold(body: StaffProfileScreen())),
      ),
    );

    expect(find.text('Staff Profile'), findsOneWidget);
    expect(find.text('Store Operations'), findsOneWidget);
    expect(find.text('Exit Staff Portal'), findsOneWidget);
  });

  testWidgets('exits to role selection', (tester) async {
    final router = GoRouter(
      initialLocation: '/staff-profile',
      routes: [
        GoRoute(
          path: '/staff-profile',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => AuthProvider(_FakeAuthService(), _FakeUserService(), _FakeStaffAccountService()),
            child: const Scaffold(
              body: StaffProfileScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const Scaffold(
            body: Text('Select Portal'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Exit Staff Portal'));
    await tester.pumpAndSettle();

    expect(find.text('Select Portal'), findsOneWidget);
  });
}
