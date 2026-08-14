import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/admin/inventory/repository/inventory_repository.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/orders/models/order_model.dart';
import 'package:pc_parts_application/features/customer/orders/providers/order_provider.dart';
import 'package:pc_parts_application/features/customer/orders/repository/order_repository.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';
import 'package:pc_parts_application/features/customer/products/providers/product_provider.dart';
import 'package:pc_parts_application/features/customer/products/repository/product_repository.dart';

const _gpu = ProductModel(
  id: 'gpu-1',
  name: 'RTX 4060',
  category: 'GPU',
  brand: 'NVIDIA',
  price: 18999,
  image: 'assets/images/rtx4060.png',
  stock: 10,
  description: 'Graphics card.',
);

void main() {
  test('a product survives a Firestore round trip', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = ProductRepository(firestore: firestore);

    await repository.upsertProduct(_gpu);
    final products = await repository.watchProducts().first;

    expect(products, hasLength(1));
    expect(products.single.id, 'gpu-1');
    expect(products.single.name, 'RTX 4060');
    expect(products.single.price, 18999);
    expect(products.single.stock, 10);
  });

  test(
    'a product provider backed by Firestore ignores the demo catalog',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = ProductRepository(firestore: firestore);
      final provider = ProductProvider(repository: repository);

      expect(provider.products, isEmpty);

      await repository.upsertProduct(_gpu);
      await Future<void>.delayed(Duration.zero);

      expect(provider.products.single.name, 'RTX 4060');
      expect(provider.getProductsByCategory('GPU'), hasLength(1));
      expect(provider.getProductsByCategory('CPU'), isEmpty);
    },
  );

  test('stock changes are written to Firestore with a movement', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = InventoryRepository(firestore: firestore);
    final provider = InventoryProvider(repository: repository);

    provider.addInventoryItem(id: 'gpu-1', productName: 'RTX 4060', stock: 4);
    await Future<void>.delayed(Duration.zero);

    expect(provider.addStock('gpu-1', 6), isTrue);
    await Future<void>.delayed(Duration.zero);

    final items = await repository.watchItems().first;
    expect(items.single.stock, 10);

    final movements = await repository.watchMovements().first;
    expect(movements.single.type, 'Stock In');
    expect(movements.single.newStock, 10);
  });

  test(
    'an order round trips with its build components and delivery details',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = OrderRepository(firestore: firestore);
      final provider = OrderProvider(repository: repository);

      provider.placeOrder(
        customerName: 'Josh',
        phoneNumber: '09171234567',
        deliveryAddress: 'Manila',
        items: [
          CartItem(product: _gpu, quantity: 2),
          CartItem.pcBuild(
            id: 'build-1',
            buildName: 'Starter Build',
            components: const [_gpu],
          ),
        ],
        totalAmount: 56997,
        paymentMethod: 'Cash on Delivery',
      );

      await Future<void>.delayed(Duration.zero);

      final orders = await repository.watchOrders().first;
      expect(orders, hasLength(1));

      final order = orders.single;
      expect(order.customerName, 'Josh');
      expect(order.status, 'Pending');
      expect(order.paymentStatus, 'Payment on Delivery');
      expect(order.items, hasLength(2));
      expect(order.items.first.quantity, 2);
      expect(order.items.last.isPcBuild, isTrue);
      expect(order.items.last.buildComponents.single.product.id, 'gpu-1');

      provider.shipOrder(
        order.id,
        DeliveryDetails(
          courierName: 'LBC',
          trackingNumber: 'TRK-1',
          riderName: 'Rider',
          riderPhoneNumber: '09170000000',
          estimatedDeliveryDate: DateTime(2026, 1, 1),
          deliveryNotes: 'Leave at gate',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      // shipOrder only applies to processing orders, so the stored order is
      // still the pending one until it moves through the workflow.
      expect((await repository.watchOrders().first).single.status, 'Pending');

      provider.confirmOrder(order.id);
      provider.processOrder(order.id);
      provider.shipOrder(
        order.id,
        DeliveryDetails(
          courierName: 'LBC',
          trackingNumber: 'TRK-1',
          riderName: 'Rider',
          riderPhoneNumber: '09170000000',
          estimatedDeliveryDate: DateTime(2026, 1, 1),
          deliveryNotes: 'Leave at gate',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final shipped = (await repository.watchOrders().first).single;
      expect(shipped.status, 'Out for Delivery');
      expect(shipped.deliveryDetails?.trackingNumber, 'TRK-1');
      expect(
        shipped.deliveryDetails?.estimatedDeliveryDate,
        DateTime(2026, 1, 1),
      );
    },
  );

  test('completed orders are only deducted once across a restart', () async {
    final firestore = FakeFirebaseFirestore();
    final inventoryRepository = InventoryRepository(firestore: firestore);
    final orderRepository = OrderRepository(firestore: firestore);

    final inventory = InventoryProvider(repository: inventoryRepository);
    inventory.addInventoryItem(id: 'gpu-1', productName: 'RTX 4060', stock: 10);
    await Future<void>.delayed(Duration.zero);

    final order = OrderModel(
      id: 'order-1',
      customerName: 'Josh',
      phoneNumber: '09171234567',
      deliveryAddress: 'Manila',
      items: [CartItem(product: _gpu, quantity: 3)],
      totalAmount: 56997,
      paymentMethod: 'Cash on Delivery',
      paymentStatus: 'Payment on Delivery',
      orderDate: DateTime(2026, 1, 1),
      status: 'Completed',
    );
    await orderRepository.saveOrder(order);

    inventory.syncCompletedOrders([order]);
    await Future<void>.delayed(Duration.zero);

    expect((await inventoryRepository.watchItems().first).single.stock, 7);

    // A fresh provider stands in for an app restart: the persisted movement
    // must stop the same order from being deducted a second time.
    final restarted = InventoryProvider(repository: inventoryRepository);
    await Future<void>.delayed(Duration.zero);

    restarted.syncCompletedOrders([order]);
    await Future<void>.delayed(Duration.zero);

    expect((await inventoryRepository.watchItems().first).single.stock, 7);
  });
}
