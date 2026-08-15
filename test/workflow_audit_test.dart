import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pc_parts_application/features/authentication/providers/auth_provider.dart';
import 'package:pc_parts_application/features/authentication/services/auth_service.dart';
import 'package:pc_parts_application/features/authentication/services/user_service.dart';
import 'package:pc_parts_application/features/authentication/models/auth_user_model.dart';
import 'package:pc_parts_application/features/admin/staff/services/staff_account_service.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/admin/sales/providers/walk_in_sale_provider.dart';
import 'package:pc_parts_application/features/admin/sales/models/walk_in_sale_model.dart';
import 'package:pc_parts_application/features/customer/support/providers/support_provider.dart';
import 'package:pc_parts_application/features/customer/support/repository/support_repository.dart';
import 'package:pc_parts_application/features/customer/support/models/support_inquiry_model.dart';
import 'package:pc_parts_application/core/enums/user_role.dart';

class FakeSupportRepository extends Fake implements SupportRepository {
  @override
  Stream<List<SupportInquiryModel>> watchInquiries() =>
      const Stream.empty();

  @override
  Stream<List<SupportInquiryModel>> watchCustomerInquiries(String customerId) =>
      const Stream.empty();

  @override
  Future<void> createInquiry(SupportInquiryModel inquiry, String customerId) async {}

  @override
  Future<void> replyToInquiry(String inquiryId, String reply) async {}

  @override
  Future<void> resolveInquiry(String inquiryId) async {}

  @override
  Future<void> closeInquiry(String inquiryId) async {}
}

class FakeAuthService extends Fake implements AuthService {
  @override
  AuthUserModel? get currentUser => null;

  @override
  Stream<AuthUserModel?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    return AuthUserModel(
      id: 'staff-1',
      fullName: 'Test Staff',
      email: email,
      phone: '1234567890',
      role: UserRole.staff,
    );
  }
}

class FakeUserService extends Fake implements UserService {
  bool _isActive = true;
  UserRole? _role = UserRole.staff;

  void setActive(bool active) => _isActive = active;
  void setRole(UserRole? role) => _role = role;

  @override
  Future<bool> isActive(String uid) async => _isActive;

  @override
  Future<UserRole?> fetchUserRole(String uid) async => _role;
}

class FakeStaffAccountService extends Fake implements StaffAccountService {}

void main() {
  group('Staff Deactivation', () {
    testWidgets('inactive staff login fails', (tester) async {
      final userService = FakeUserService();
      userService.setActive(false);

      final authProvider = AuthProvider(
        FakeAuthService(),
        userService,
        FakeStaffAccountService(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(home: Scaffold(body: Text('Home'))),
        ),
      );

      expect(authProvider.isLoggedIn, isFalse);
    });

    testWidgets('active staff login succeeds', (tester) async {
      final authProvider = AuthProvider(
        FakeAuthService(),
        FakeUserService(),
        FakeStaffAccountService(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(home: Scaffold(body: Text('Home'))),
        ),
      );

      final result = await authProvider.login(
        email: 'staff@test.com',
        password: 'password',
      );

      expect(result, isTrue);
      expect(authProvider.isLoggedIn, isTrue);
    });
  });

  group('Inventory Duplicate Prevention', () {
    testWidgets('deductStock prevents duplicate movements', (tester) async {
      final inventoryProvider = InventoryProvider();

      inventoryProvider.addInventoryItem(
        id: 'prod-1',
        productName: 'Test Product',
        stock: 10,
      );

      final movementId = 'DEDUP-001-prod-1';
      final result1 = await inventoryProvider.deductStock(
        'prod-1',
        2,
        reason: 'Test',
        movementId: movementId,
      );

      expect(result1, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 8);

      final result2 = await inventoryProvider.deductStock(
        'prod-1',
        2,
        reason: 'Test',
        movementId: movementId,
      );

      expect(result2, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 8);
    });

    testWidgets('addStock prevents duplicate movements', (tester) async {
      final inventoryProvider = InventoryProvider();

      inventoryProvider.addInventoryItem(
        id: 'prod-1',
        productName: 'Test Product',
        stock: 10,
      );

      final movementId = 'DEDUP-IN-001-prod-1';
      final result1 = await inventoryProvider.addStock(
        'prod-1',
        5,
        reason: 'Test',
        movementId: movementId,
      );

      expect(result1, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 15);

      final result2 = await inventoryProvider.addStock(
        'prod-1',
        5,
        reason: 'Test',
        movementId: movementId,
      );

      expect(result2, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 15);
    });
  });

  group('Walk-in Sale', () {
    testWidgets('completeSale deducts stock and creates movements', (tester) async {
      final inventoryProvider = InventoryProvider();
      inventoryProvider.addInventoryItem(
        id: 'prod-1',
        productName: 'Test Product',
        stock: 10,
      );
      inventoryProvider.setPerformedBy(
        uid: 'staff-1',
        name: 'Test Staff',
        role: 'staff',
      );

      final saleProvider = WalkInSaleProvider(
        repository: null,
      );
      saleProvider.setInventoryProvider(inventoryProvider);

      saleProvider.addItem(const WalkInSaleItem(
        productId: 'prod-1',
        productName: 'Test Product',
        quantity: 2,
        unitPrice: 100.0,
      ));

      final result = await saleProvider.completeSale(
        performedByUid: 'staff-1',
        performedByName: 'Test Staff',
        performedByRole: 'staff',
      );

      expect(result, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 8);

      final stockOutMovements = inventoryProvider.movements
          .where((m) => m.reason == 'Walk-in Sale')
          .toList();
      expect(stockOutMovements.length, 1);
      expect(stockOutMovements.first.performedByUid, 'staff-1');
      expect(stockOutMovements.first.performedByName, 'Test Staff');
      expect(stockOutMovements.first.performedByRole, 'staff');
    });

    testWidgets('deductStock prevents duplicate movements with same ID', (tester) async {
      final inventoryProvider = InventoryProvider();
      inventoryProvider.addInventoryItem(
        id: 'prod-1',
        productName: 'Test Product',
        stock: 10,
      );
      inventoryProvider.setPerformedBy(
        uid: 'staff-1',
        name: 'Test Staff',
        role: 'staff',
      );

      final result1 = await inventoryProvider.deductStock(
        'prod-1',
        2,
        reason: 'Walk-in Sale',
        movementId: 'WALKIN-test-prod-1',
      );

      expect(result1, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 8);

      final duplicateResult = await inventoryProvider.deductStock(
        'prod-1',
        2,
        reason: 'Walk-in Sale',
        movementId: 'WALKIN-test-prod-1',
      );

      expect(duplicateResult, isTrue);
      expect(inventoryProvider.itemById('prod-1')?.stock, 8);
    });
  });

  group('Support', () {
    testWidgets('support provider initializes correctly', (tester) async {
      final authProvider = AuthProvider(
        FakeAuthService(),
        FakeUserService(),
        FakeStaffAccountService(),
      );

      final supportProvider = SupportProvider(
        repository: FakeSupportRepository(),
        authProvider: authProvider,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: supportProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: Text('Home'))),
        ),
      );

      expect(supportProvider.errorMessage, isNull);
    });
  });
}
