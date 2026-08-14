import 'package:flutter/material.dart';

import '../models/checkout_model.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutModel? _checkout;

  CheckoutModel? get checkout => _checkout;

  void saveCheckout({
    required String fullName,
    required String phoneNumber,
    required String address,
    required String paymentMethod,
    String paymentReference = '',
    required double totalAmount,
  }) {
    _checkout = CheckoutModel(
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      totalAmount: totalAmount,
    );

    notifyListeners();
  }

  void updateShippingAddress({
    required String fullName,
    required String phoneNumber,
    required String address,
  }) {
    _checkout = CheckoutModel(
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      paymentMethod:
          _checkout?.paymentMethod ?? 'Cash on Delivery',
      paymentReference: _checkout?.paymentReference ?? '',
      totalAmount:
          _checkout?.totalAmount ?? 0,
    );

    notifyListeners();
  }

  void updatePaymentMethod(
    String paymentMethod, {
    String paymentReference = '',
  }) {
    _checkout = CheckoutModel(
      fullName: _checkout?.fullName ?? '',
      phoneNumber: _checkout?.phoneNumber ?? '',
      address: _checkout?.address ?? '',
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      totalAmount:
          _checkout?.totalAmount ?? 0,
    );

    notifyListeners();
  }

  void updateTotalAmount(double totalAmount) {
    if (_checkout == null) {
      return;
    }

    _checkout = CheckoutModel(
      fullName: _checkout!.fullName,
      phoneNumber: _checkout!.phoneNumber,
      address: _checkout!.address,
      paymentMethod: _checkout!.paymentMethod,
      paymentReference: _checkout!.paymentReference,
      totalAmount: totalAmount,
    );

    notifyListeners();
  }

  void clearCheckout() {
    _checkout = null;

    notifyListeners();
  }
}
