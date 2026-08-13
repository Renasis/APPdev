class CheckoutModel {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String paymentMethod;
  final String paymentReference;
  final double totalAmount;

  CheckoutModel({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.paymentMethod,
    this.paymentReference = '',
    required this.totalAmount,
  });
}
