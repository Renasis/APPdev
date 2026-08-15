import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/customer/orders/models/order_model.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';

void main() {
  group('Staff Stock Out audit trail', () {
    test('successful stock out creates a Stock Out movement', () async {
      final inventory = InventoryProvider();

      final result = await inventory.deductStock('1', 3);

      expect(result, isTrue);
      expect(inventory.items.first.stock, 7);

      final movement = inventory.movements.first;
      expect(movement.type, 'Stock Out');
      expect(movement.productId, '1');
      expect(movement.quantity, 3);
      expect(movement.previousStock, 10);
      expect(movement.newStock, 7);
      expect(movement.reason, 'Manual Stock Out');
    });

    test('stock out rejects quantity greater than available stock', () async {
      final inventory = InventoryProvider();
      final initialCount = inventory.movements.length;

      final result = await inventory.deductStock('1', 999);

      expect(result, isFalse);
      expect(inventory.items.first.stock, 10);
      expect(inventory.movements.length, initialCount);
    });

    test('stock out rejects zero quantity', () async {
      final inventory = InventoryProvider();
      final initialCount = inventory.movements.length;

      final result = await inventory.deductStock('1', 0);

      expect(result, isFalse);
      expect(inventory.items.first.stock, 10);
      expect(inventory.movements.length, initialCount);
    });

    test('stock out rejects negative quantity', () async {
      final inventory = InventoryProvider();
      final initialCount = inventory.movements.length;

      final result = await inventory.deductStock('1', -5);

      expect(result, isFalse);
      expect(inventory.items.first.stock, 10);
      expect(inventory.movements.length, initialCount);
    });

    test('stock in still works and creates a Stock In movement', () async {
      final inventory = InventoryProvider();

      final result = await inventory.addStock('1', 5);

      expect(result, isTrue);
      expect(inventory.items.first.stock, 15);

      final movement = inventory.movements.first;
      expect(movement.type, 'Stock In');
      expect(movement.productId, '1');
      expect(movement.quantity, 5);
      expect(movement.previousStock, 10);
      expect(movement.newStock, 15);
    });

    test('order deduction still works and does not duplicate movements', () async {
      final inventory = InventoryProvider();

      final order = OrderModel(
        id: 'order-001',
        customerId: 'customer-1',
        customerName: 'Test Customer',
        phoneNumber: '09123456789',
        deliveryAddress: '123 Test St',
        items: [
          CartItem(
            product: ProductModel(
              id: '1',
              name: 'RTX 4060',
              brand: 'NVIDIA',
              category: 'GPU',
              price: 25000,
              image: '',
              stock: 10,
              description: 'Test GPU',
            ),
            quantity: 2,
          ),
        ],
        totalAmount: 50000,
        paymentMethod: 'Cash on Delivery',
        paymentStatus: 'Payment on Delivery',
        orderDate: DateTime.now(),
        status: 'Completed',
      );

      await inventory.syncCompletedOrders([order]);

      expect(inventory.items.first.stock, 8);

      final movement = inventory.movements.first;
      expect(movement.type, 'Stock Out');
      expect(movement.productId, '1');
      expect(movement.quantity, 2);
      expect(movement.previousStock, 10);
      expect(movement.newStock, 8);
      expect(movement.id, 'ORDER-order-001-1');

      await inventory.syncCompletedOrders([order]);

      expect(inventory.movements.where((m) => m.id == 'ORDER-order-001-1').length, 1);
    });
  });
}
