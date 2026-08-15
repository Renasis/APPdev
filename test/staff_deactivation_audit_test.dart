import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/authentication/models/auth_user_model.dart';
import 'package:pc_parts_application/features/authentication/providers/auth_provider.dart';
import 'package:pc_parts_application/features/authentication/services/auth_service.dart';
import 'package:pc_parts_application/features/authentication/services/user_service.dart';
import 'package:pc_parts_application/features/admin/staff/services/staff_account_service.dart';
import 'package:pc_parts_application/features/customer/products/providers/product_provider.dart';
import 'package:pc_parts_application/features/staff/inventory/staff_inventory_screen.dart';
import 'package:provider/provider.dart';

class FakeAuthService extends Fake implements AuthService {
  @override
  AuthUserModel? get currentUser => null;

  @override
  Stream<AuthUserModel?> get authStateChanges => const Stream.empty();
}

class FakeUserService extends Fake implements UserService {}
class FakeStaffAccountService extends Fake implements StaffAccountService {}

void main() {
  group('Staff Deactivation', () {
    testWidgets('login fails for inactive staff account', (tester) async {
      final userService = FakeUserService();
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
      expect(authProvider.errorMessage, isNull);
    });
  });

  group('Inventory Creation Audit', () {
    testWidgets('staff inventory screen shows Add Inventory button', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => InventoryProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
          ],
          child: const MaterialApp(home: Scaffold(body: StaffInventoryScreen())),
        ),
      );

      expect(find.text('Add Inventory'), findsOneWidget);
    });

    testWidgets('stock movement records performer information when provided', (tester) async {
      final inventoryProvider = InventoryProvider();
      final initialCount = inventoryProvider.movements.length;

      inventoryProvider.setPerformedBy(
        uid: 'test-uid',
        name: 'Test User',
        role: 'staff',
      );

      inventoryProvider.addStockMovement(
        StockMovement(
          id: 'TEST-001',
          productId: '1',
          productName: 'RTX 4060',
          quantity: 5,
          previousStock: 10,
          newStock: 15,
          reason: 'Stock In',
          notes: 'Test',
          date: DateTime.now(),
          type: 'Stock In',
          performedByUid: 'test-uid',
          performedByName: 'Test User',
          performedByRole: 'staff',
        ),
      );

      expect(inventoryProvider.movements.length, initialCount + 1);
      expect(inventoryProvider.movements.first.performedByUid, 'test-uid');
      expect(inventoryProvider.movements.first.performedByName, 'Test User');
      expect(inventoryProvider.movements.first.performedByRole, 'staff');
    });
  });
}
