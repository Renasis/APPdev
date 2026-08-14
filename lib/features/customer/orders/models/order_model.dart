import '../../cart/models/cart_item.dart';

class DeliveryDetails {
  final String courierName;
  final String trackingNumber;
  final String riderName;
  final String riderPhoneNumber;
  final DateTime estimatedDeliveryDate;
  final String deliveryNotes;

  const DeliveryDetails({
    required this.courierName,
    required this.trackingNumber,
    required this.riderName,
    required this.riderPhoneNumber,
    required this.estimatedDeliveryDate,
    required this.deliveryNotes,
  });
}

class OrderModel {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final List<CartItem> items;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String paymentReference;
  final DeliveryDetails? deliveryDetails;
  final DateTime orderDate;
  final String status;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentReference = '',
    this.deliveryDetails,
    required this.orderDate,
    required this.status,
  });
}
