import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/orders/models/order_model.dart';
import 'package:pc_parts_application/features/customer/orders/providers/order_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';

void main() {
  test('shipping stores delivery details and preserves them on completion', () {
    final orders = OrderProvider();
    orders.placeOrder(
      customerId: 'test-customer-id',
      customerName: 'Test Customer',
      phoneNumber: '09123456789',
      deliveryAddress: 'Test Address',
      items: [
        CartItem(
          product: const ProductModel(
            id: 'gpu-1',
            name: 'GPU',
            category: 'GPU',
            brand: 'Test',
            price: 1000,
            image: '',
            stock: 10,
            description: '',
          ),
        ),
      ],
      totalAmount: 1000,
      paymentMethod: 'Cash on Delivery',
    );

    final orderId = orders.orders.single.id;
    orders.confirmOrder(orderId);
    orders.processOrder(orderId);
    orders.shipOrder(
      orderId,
      DeliveryDetails(
        courierName: 'End PC Parts Delivery',
        trackingNumber: 'END-1001',
        riderName: 'Alex',
        riderPhoneNumber: '09170000000',
        estimatedDeliveryDate: DateTime(2026, 8, 14),
        deliveryNotes: 'Call on arrival.',
      ),
    );

    expect(orders.orders.single.status, 'Out for Delivery');
    expect(orders.orders.single.deliveryDetails!.trackingNumber, 'END-1001');

    orders.completeOrder(orderId);
    expect(orders.orders.single.deliveryDetails!.courierName,
        'End PC Parts Delivery');
  });
}
