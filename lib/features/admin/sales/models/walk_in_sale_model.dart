class WalkInSaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const WalkInSaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory WalkInSaleItem.fromMap(Map<String, dynamic> data) {
    return WalkInSaleItem(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: (data['quantity'] as num? ?? 0).toInt(),
      unitPrice: (data['unitPrice'] as num? ?? 0).toDouble(),
    );
  }
}

class WalkInSale {
  final String id;
  final String customerName;
  final String contactNumber;
  final List<WalkInSaleItem> items;
  final double totalAmount;
  final String paymentMethod;
  final String performedByUid;
  final String performedByName;
  final String performedByRole;
  final DateTime saleDate;
  final String status;

  const WalkInSale({
    required this.id,
    required this.customerName,
    required this.contactNumber,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.performedByUid,
    required this.performedByName,
    required this.performedByRole,
    required this.saleDate,
    this.status = 'Completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'contactNumber': contactNumber,
      'items': items.map((item) => item.toMap()).toList(growable: false),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'performedByUid': performedByUid,
      'performedByName': performedByName,
      'performedByRole': performedByRole,
      'saleDate': saleDate.toIso8601String(),
      'status': status,
    };
  }

  factory WalkInSale.fromMap(String id, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => WalkInSaleItem.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);

    return WalkInSale(
      id: id,
      customerName: data['customerName'] as String? ?? '',
      contactNumber: data['contactNumber'] as String? ?? '',
      items: items,
      totalAmount: (data['totalAmount'] as num? ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] as String? ?? '',
      performedByUid: data['performedByUid'] as String? ?? '',
      performedByName: data['performedByName'] as String? ?? '',
      performedByRole: data['performedByRole'] as String? ?? '',
      saleDate: DateTime.tryParse(data['saleDate'] as String? ?? '') ?? DateTime.now(),
      status: data['status'] as String? ?? 'Completed',
    );
  }
}
