import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/orders/providers/order_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';
import 'package:pc_parts_application/features/staff/dashboard/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows live order and inventory counts', (tester) async {
    final orders = OrderProvider();
    final inventory = InventoryProvider();

    orders.placeOrder(
      customerId: 'test-customer-id',
      customerName: 'Test Customer',
      phoneNumber: '09123456789',
      deliveryAddress: 'Test Address',
      items: [
        CartItem(
          product: const ProductModel(
            id: '1',
            name: 'RTX 4060',
            category: 'GPU',
            brand: 'Test Brand',
            price: 100,
            image: '',
            stock: 10,
            description: '',
          ),
        ),
      ],
      totalAmount: 100,
      paymentMethod: 'Cash on Delivery',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: orders),
          ChangeNotifierProvider.value(value: inventory),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    expect(find.text('Today Orders'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(3));
    expect(find.text('0'), findsOneWidget);
  });
}
