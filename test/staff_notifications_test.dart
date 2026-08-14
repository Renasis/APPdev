import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/orders/providers/order_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';
import 'package:pc_parts_application/features/staff/notifications/providers/staff_notification_provider.dart';

void main() {
  test('adds one notification for a pending order and current low stock', () {
    final orders = OrderProvider();
    final inventory = InventoryProvider();
    final notifications = StaffNotificationProvider();

    orders.placeOrder(
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

    notifications.sync(
      orders: orders.orders,
      inventoryItems: inventory.items,
    );
    notifications.sync(
      orders: orders.orders,
      inventoryItems: inventory.items,
    );

    expect(notifications.notifications, hasLength(2));
    expect(notifications.unreadCount, 2);
    expect(
      notifications.notifications.any(
        (notification) => notification.title == 'New Customer Order',
      ),
      isTrue,
    );
    expect(
      notifications.notifications.any(
        (notification) => notification.title == 'Low Stock Alert',
      ),
      isTrue,
    );
  });

  test('removes disabled notification categories from the staff feed', () {
    final orders = OrderProvider();
    final inventory = InventoryProvider();
    final notifications = StaffNotificationProvider();

    orders.placeOrder(
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

    notifications.sync(
      orders: orders.orders,
      inventoryItems: inventory.items,
    );
    notifications.sync(
      orders: orders.orders,
      inventoryItems: inventory.items,
      newOrderAlertsEnabled: false,
      lowStockAlertsEnabled: false,
    );

    expect(notifications.notifications, isEmpty);
    expect(notifications.unreadCount, 0);
  });
}
