import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../address/providers/address_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../providers/checkout_provider.dart';
import 'order_success_screen.dart';
import 'payment_method_screen.dart';
import '../../address/screens/address_list_screen.dart';
import '../../notifications/providers/notification_provider.dart';


class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final checkoutProvider = Provider.of<CheckoutProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    final checkout = checkoutProvider.checkout;
    final defaultAddress = addressProvider.defaultAddress;

    final displayName =
        checkout?.fullName.isNotEmpty == true
            ? checkout!.fullName
            : defaultAddress?.fullName ?? 'No delivery address';

    final displayAddress =
    checkout?.address.isNotEmpty == true
        ? '${checkout!.address}\n${checkout.phoneNumber}'
        : defaultAddress != null
            ? '${defaultAddress.address}\n${defaultAddress.phoneNumber}'
            : 'Add your delivery address';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartProvider.items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =========================
                  // DELIVERY ADDRESS
                  // =========================

                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                      ),
                      title: Text(displayName),
                      subtitle: Text(displayAddress),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AddressListScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // PAYMENT METHOD
                  // =========================

                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.payment_outlined,
                      ),
                      title: Text(
                        checkout?.paymentMethod ??
                            'Select payment method',
                      ),
                      subtitle: const Text(
                        'Choose how you want to pay',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PaymentMethodScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // ORDER SUMMARY
                  // =========================

                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...cartProvider.items.map(
                            (item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} × ${item.quantity}',
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '₱${item.totalPrice.toStringAsFixed(2)}',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₱${cartProvider.totalAmount.toStringAsFixed(2)}',
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // PLACE ORDER
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final shortages = cartProvider.stockShortages;
                        if (shortages.isNotEmpty) {
                          final details = shortages
                              .map(
                                (shortage) =>
                                    '${shortage.productName}: ${shortage.availableQuantity} available, ${shortage.requestedQuantity} requested',
                              )
                              .join('\n');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Some items are no longer available:\n$details',
                              ),
                            ),
                          );
                          return;
                        }

                        final selectedName =
                            checkout?.fullName.isNotEmpty ==
                                    true
                                ? checkout!.fullName
                                : defaultAddress
                                        ?.fullName ??
                                    '';

                        final selectedPhone =
                            checkout?.phoneNumber
                                        .isNotEmpty ==
                                    true
                                ? checkout!.phoneNumber
                                : defaultAddress
                                        ?.phoneNumber ??
                                    '';

                        final selectedAddress =
                            checkout?.address.isNotEmpty ==
                                    true
                                ? checkout!.address
                                : defaultAddress
                                        ?.address ??
                                    '';

                        if (selectedName.isEmpty ||
                            selectedPhone.isEmpty ||
                            selectedAddress.isEmpty) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please add a delivery address',
                              ),
                            ),
                          );
                          return;
                        }

                        if (checkout == null ||
                            checkout.paymentMethod
                                .trim()
                                .isEmpty) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a payment method',
                              ),
                            ),
                          );
                          return;
                        }

                        Provider.of<OrderProvider>(
  context,
  listen: false,
).placeOrder(
  customerName: selectedName,
  phoneNumber: selectedPhone,
  deliveryAddress: selectedAddress,
  items: List.from(
    cartProvider.items,
  ),
  totalAmount:
      cartProvider.totalAmount,
  paymentMethod:
      checkout.paymentMethod,
  paymentReference: checkout.paymentReference,
);

Provider.of<NotificationProvider>(
  context,
  listen: false,
).addNotification(
  title: 'Order Placed Successfully',
  message:
      'Your order has been received and is now pending confirmation.',
);

cartProvider.clearCart();

checkoutProvider.clearCheckout();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OrderSuccessScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
