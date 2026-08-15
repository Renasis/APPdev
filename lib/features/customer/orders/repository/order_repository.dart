import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../cart/models/cart_item.dart';
import '../../products/models/product_model.dart';
import '../models/order_model.dart';

/// Firestore data access for customer orders.
///
/// Orders live in `orders/{orderId}`. Cart items (including PC builds and
/// their components) and delivery details are stored as nested maps on the
/// order document so an order can be read back in one request.
class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.orders);

  Stream<List<OrderModel>> watchOrders() {
    return _collection
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_toOrder).toList(growable: false));
  }

  Future<void> saveOrder(OrderModel order) {
    return _collection.doc(order.id).set({
      'customerId': order.customerId,
      'customerName': order.customerName,
      'phoneNumber': order.phoneNumber,
      'deliveryAddress': order.deliveryAddress,
      'items': order.items.map(_cartItemToMap).toList(growable: false),
      'totalAmount': order.totalAmount,
      'paymentMethod': order.paymentMethod,
      'paymentStatus': order.paymentStatus,
      'paymentReference': order.paymentReference,
      'deliveryDetails': order.deliveryDetails == null
          ? null
          : _deliveryDetailsToMap(order.deliveryDetails!),
      'orderDate': Timestamp.fromDate(order.orderDate),
      'status': order.status,
      'orderType': order.orderType,
    });
  }

  OrderModel _toOrder(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _cartItemFromMap(item as Map<String, dynamic>))
        .toList(growable: false);
    final deliveryDetails = data['deliveryDetails'] as Map<String, dynamic>?;

    return OrderModel(
      id: document.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      items: items,
      totalAmount: (data['totalAmount'] as num? ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] as String? ?? '',
      paymentStatus: data['paymentStatus'] as String? ?? '',
      paymentReference: data['paymentReference'] as String? ?? '',
      deliveryDetails: deliveryDetails == null
          ? null
          : _deliveryDetailsFromMap(deliveryDetails),
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? '',
      orderType: data['orderType'] as String? ?? 'online',
    );
  }

  Map<String, dynamic> _cartItemToMap(CartItem item) {
    return {
      'product': _productToMap(item.product),
      'quantity': item.quantity,
      'buildName': item.buildName,
      'buildComponents': item.buildComponents
          .map(_cartItemToMap)
          .toList(growable: false),
    };
  }

  CartItem _cartItemFromMap(Map<String, dynamic> data) {
    final components = (data['buildComponents'] as List<dynamic>? ?? const [])
        .map((component) => _cartItemFromMap(component as Map<String, dynamic>))
        .toList(growable: false);

    return CartItem(
      product: _productFromMap(data['product'] as Map<String, dynamic>),
      quantity: (data['quantity'] as num? ?? 1).toInt(),
      buildName: data['buildName'] as String?,
      buildComponents: components,
    );
  }

  Map<String, dynamic> _productToMap(ProductModel product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'brand': product.brand,
      'price': product.price,
      'image': product.image,
      'stock': product.stock,
      'description': product.description,
    };
  }

  ProductModel _productFromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      price: (data['price'] as num? ?? 0).toDouble(),
      image: data['image'] as String? ?? '',
      stock: (data['stock'] as num? ?? 0).toInt(),
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> _deliveryDetailsToMap(DeliveryDetails details) {
    return {
      'courierName': details.courierName,
      'trackingNumber': details.trackingNumber,
      'riderName': details.riderName,
      'riderPhoneNumber': details.riderPhoneNumber,
      'estimatedDeliveryDate': Timestamp.fromDate(
        details.estimatedDeliveryDate,
      ),
      'deliveryNotes': details.deliveryNotes,
    };
  }

  DeliveryDetails _deliveryDetailsFromMap(Map<String, dynamic> data) {
    return DeliveryDetails(
      courierName: data['courierName'] as String? ?? '',
      trackingNumber: data['trackingNumber'] as String? ?? '',
      riderName: data['riderName'] as String? ?? '',
      riderPhoneNumber: data['riderPhoneNumber'] as String? ?? '',
      estimatedDeliveryDate:
          (data['estimatedDeliveryDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      deliveryNotes: data['deliveryNotes'] as String? ?? '',
    );
  }
}
