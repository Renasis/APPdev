import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/customer/products/providers/product_provider.dart';
import 'package:pc_parts_application/features/staff/inventory/staff_inventory_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows live inventory items and their stock status', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InventoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: StaffInventoryScreen())),
      ),
    );

    expect(find.text('RTX 4060'), findsOneWidget);
    expect(find.text('Ryzen 7 7800X3D'), findsOneWidget);
    expect(find.text('Current stock: 10'), findsOneWidget);
    expect(find.text('Current stock: 3'), findsOneWidget);
    expect(find.text('In Stock'), findsWidgets);
    expect(find.text('Low Stock'), findsOneWidget);
  });

  testWidgets('shows stock in and stock out action buttons', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InventoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: StaffInventoryScreen())),
      ),
    );

    expect(find.byIcon(Icons.add_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.remove_circle_outline), findsWidgets);
    expect(find.byTooltip('Stock In'), findsWidgets);
    expect(find.byTooltip('Stock Out'), findsWidgets);
  });

  testWidgets('stock in button is present for each inventory item', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InventoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: StaffInventoryScreen())),
      ),
    );

    expect(find.byTooltip('Stock In'), findsWidgets);
  });

  testWidgets('stock out button is present for each inventory item', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InventoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: StaffInventoryScreen())),
      ),
    );

    expect(find.byTooltip('Stock Out'), findsWidgets);
  });
}
