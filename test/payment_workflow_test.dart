import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/customer/cart/models/cart_item.dart';
import 'package:pc_parts_application/features/customer/orders/providers/order_provider.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';

CartItem _item() => CartItem(
      product: const ProductModel(
        id: '1',
        name: 'RTX 4060',
        category: 'GPU',
        brand: 'NVIDIA',
        price: 18999,
        image: '',
        stock: 10,
        description: '',
      ),
    );

void main() {
  test('GCash requires verification before an order can be confirmed', () {
    final orders = OrderProvider();
    orders.placeOrder(
      customerId: 'test-customer-id',
      customerName: 'Test Customer',
      phoneNumber: '09123456789',
      deliveryAddress: 'Test Address',
      items: [_item()],
      totalAmount: 18999,
      paymentMethod: 'GCash',
      paymentReference: 'GCASH-123',
    );

    final orderId = orders.orders.single.id;
    expect(orders.orders.single.paymentStatus, 'Awaiting Verification');

    orders.confirmOrder(orderId);
    expect(orders.orders.single.status, 'Pending');

    orders.verifyPayment(orderId);
    expect(orders.orders.single.paymentStatus, 'Verified');

    orders.confirmOrder(orderId);
    expect(orders.orders.single.status, 'Confirmed');
  });

  test('cash on delivery can be confirmed without verification', () {
    final orders = OrderProvider();
    orders.placeOrder(
      customerId: 'test-customer-id',
      customerName: 'Test Customer',
      phoneNumber: '09123456789',
      deliveryAddress: 'Test Address',
      items: [_item()],
      totalAmount: 18999,
      paymentMethod: 'Cash on Delivery',
    );

    final orderId = orders.orders.single.id;
    expect(orders.orders.single.paymentStatus, 'Payment on Delivery');

    orders.confirmOrder(orderId);
    expect(orders.orders.single.status, 'Confirmed');
  });
}
