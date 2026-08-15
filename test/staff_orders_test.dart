import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/orders/providers/order_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';
import 'package:pc_parts_application/features/staff/orders/screens/staff_orders_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('staff can confirm a pending order', (tester) async {
    final orders = OrderProvider();
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
      ChangeNotifierProvider.value(
        value: orders,
        child: const MaterialApp(home: StaffOrdersScreen()),
      ),
    );

    expect(find.text('Confirm Order'), findsOneWidget);
    await tester.tap(find.text('Confirm Order'));
    await tester.pump();

    expect(orders.orders.single.status, 'Confirmed');
    expect(find.text('Process Order'), findsOneWidget);
  });
}
