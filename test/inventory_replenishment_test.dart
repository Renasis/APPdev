import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/admin/inventory/providers/inventory_provider.dart';
import 'package:pc_parts_application/features/admin/notifications/providers/notification_provider.dart'
    as admin_notifications;

void main() {
  test('stock-in resolves a critical alert and records a Stock In movement', () async {
    final notifications = admin_notifications.NotificationProvider();
    final inventory = InventoryProvider();
    await inventory.setNotificationProvider(notifications);

    await inventory.updateStock('2', 2);

    expect(inventory.items[1].stock, 2);
    expect(notifications.unreadCount, 1);
    expect(notifications.notifications.single.id, 'critical-stock-2');

    final added = await inventory.addStock(
      '2',
      4,
      reason: 'Purchase Order Received',
      notes: 'Received from PO-002.',
    );

    expect(added, isTrue);
    expect(inventory.items[1].stock, 6);
    expect(notifications.notifications, isEmpty);
    expect(notifications.unreadCount, 0);

    final movement = inventory.movements.first;
    expect(movement.type, 'Stock In');
    expect(movement.productId, '2');
    expect(movement.quantity, 4);
    expect(movement.previousStock, 2);
    expect(movement.newStock, 6);
    expect(movement.reason, 'Purchase Order Received');
  });
}
