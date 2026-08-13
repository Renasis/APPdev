import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../../cart/models/cart_item.dart';
import '../../notifications/providers/notification_provider.dart'
    as customer_notifications;

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  final Set<String> _notifiedOrderStatuses = <String>{};

  customer_notifications.NotificationProvider? _notificationProvider;

  List<OrderModel> get orders => _orders;

  void setNotificationProvider(
    customer_notifications.NotificationProvider provider,
  ) {
    _notificationProvider = provider;
  }

  // =========================
  // PLACE ORDER
  // =========================

  void placeOrder({
    required String customerName,
    required String phoneNumber,
    required String deliveryAddress,
    required List<CartItem> items,
    required double totalAmount,
    required String paymentMethod,
    String paymentReference = '',
  }) {
    final order = OrderModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      customerName: customerName,

      phoneNumber: phoneNumber,

      deliveryAddress: deliveryAddress,

      items: List<CartItem>.from(items),

      totalAmount: totalAmount,

      paymentMethod: paymentMethod,

      paymentStatus: paymentMethod == 'Cash on Delivery'
          ? 'Payment on Delivery'
          : 'Awaiting Verification',

      paymentReference: paymentReference,

      orderDate: DateTime.now(),

      status: 'Pending',
    );

    _orders.insert(0, order);

    notifyListeners();
  }

  // =========================
  // GET ORDER BY ID
  // =========================

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere(
        (order) => order.id == orderId,
      );
    } catch (_) {
      return null;
    }
  }

  // =========================
  // UPDATE ORDER STATUS
  // =========================

  void updateOrderStatus(
    String orderId,
    String newStatus,
  ) {
    final index = _orders.indexWhere(
      (order) => order.id == orderId,
    );

    if (index == -1) {
      return;
    }

    final currentOrder = _orders[index];

    if (currentOrder.status == newStatus) {
      return;
    }

    final updatedOrder = OrderModel(
      id: currentOrder.id,

      customerName:
          currentOrder.customerName,

      phoneNumber:
          currentOrder.phoneNumber,

      deliveryAddress:
          currentOrder.deliveryAddress,

      items: List<CartItem>.from(
        currentOrder.items,
      ),

      totalAmount:
          currentOrder.totalAmount,

      paymentMethod:
          currentOrder.paymentMethod,

      paymentStatus: currentOrder.paymentStatus,

      paymentReference: currentOrder.paymentReference,

      deliveryDetails: currentOrder.deliveryDetails,

      orderDate:
          currentOrder.orderDate,

      status: newStatus,
    );

    _orders[index] = updatedOrder;

    _addStatusNotification(updatedOrder);

    notifyListeners();
  }

  void _addStatusNotification(OrderModel order) {
    const notificationTitles = {
      'Confirmed': 'Order Confirmed',
      'Processing': 'Order Processing',
      'Out for Delivery': 'Order Out for Delivery',
      'Completed': 'Order Completed',
      'Cancelled': 'Order Cancelled',
    };

    final title = notificationTitles[order.status];
    final notificationProvider = _notificationProvider;
    if (title == null || notificationProvider == null) {
      return;
    }

    final notificationKey = '${order.id}:${order.status}';
    if (!_notifiedOrderStatuses.add(notificationKey)) {
      return;
    }

    notificationProvider.addNotification(
      title: title,
      message: 'Your order #${order.id} is now ${order.status}.',
    );
  }

  // =========================
  // STATUS ACTIONS
  // =========================

  void confirmOrder(String orderId) {
    final order = getOrderById(orderId);
    if (order == null ||
        (order.paymentMethod == 'GCash' && order.paymentStatus != 'Verified')) {
      return;
    }
    updateOrderStatus(
      orderId,
      'Confirmed',
    );
  }

  void verifyPayment(String orderId) {
    _updatePaymentStatus(orderId, 'Verified');
  }

  void rejectPayment(String orderId) {
    _updatePaymentStatus(orderId, 'Rejected');
  }

  void _updatePaymentStatus(String orderId, String paymentStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || _orders[index].paymentStatus == paymentStatus) {
      return;
    }

    final order = _orders[index];
    _orders[index] = OrderModel(
      id: order.id,
      customerName: order.customerName,
      phoneNumber: order.phoneNumber,
      deliveryAddress: order.deliveryAddress,
      items: List<CartItem>.from(order.items),
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      paymentStatus: paymentStatus,
      paymentReference: order.paymentReference,
      deliveryDetails: order.deliveryDetails,
      orderDate: order.orderDate,
      status: order.status,
    );

    final notificationProvider = _notificationProvider;
    if (notificationProvider != null) {
      notificationProvider.addNotification(
        title: paymentStatus == 'Verified'
            ? 'Payment Verified'
            : 'Payment Rejected',
        message: 'Payment for order #${order.id} is $paymentStatus.',
      );
    }
    notifyListeners();
  }

  void processOrder(String orderId) {
    updateOrderStatus(
      orderId,
      'Processing',
    );
  }

  void completeOrder(String orderId) {
    updateOrderStatus(
      orderId,
      'Completed',
    );
  }

  void shipOrder(String orderId, DeliveryDetails deliveryDetails) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || _orders[index].status != 'Processing') {
      return;
    }

    final order = _orders[index];
    final shippedOrder = OrderModel(
      id: order.id,
      customerName: order.customerName,
      phoneNumber: order.phoneNumber,
      deliveryAddress: order.deliveryAddress,
      items: List<CartItem>.from(order.items),
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      paymentReference: order.paymentReference,
      deliveryDetails: deliveryDetails,
      orderDate: order.orderDate,
      status: 'Out for Delivery',
    );

    _orders[index] = shippedOrder;
    _addStatusNotification(shippedOrder);
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere(
      (order) => order.id == orderId,
    );

    if (index == -1) {
      return;
    }

    final currentOrder = _orders[index];

    if (currentOrder.status !=
            'Pending' &&
        currentOrder.status !=
            'Confirmed') {
      return;
    }

    updateOrderStatus(
      orderId,
      'Cancelled',
    );
  }
// =========================
// PURCHASE CHECK
// =========================

bool hasPurchasedProduct(
  String productId,
) {
  for (final order in _orders) {
    if (order.status != 'Completed') {
      continue;
    }

    for (final item in order.items.expand((item) => item.stockItems)) {
      if (item.product.id == productId) {
        return true;
      }
    }
  }

  return false;
}
}
