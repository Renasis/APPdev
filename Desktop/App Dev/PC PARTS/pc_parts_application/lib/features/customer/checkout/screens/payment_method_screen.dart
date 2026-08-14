import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState
    extends State<PaymentMethodScreen> {
  String selectedMethod =
      'Cash on Delivery';
  final referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final checkout =
        Provider.of<CheckoutProvider>(
      context,
      listen: false,
    ).checkout;

    if (checkout != null &&
        checkout.paymentMethod.isNotEmpty) {
      selectedMethod =
          checkout.paymentMethod;
      referenceController.text = checkout.paymentReference;
    }
  }

  @override
  void dispose() {
    referenceController.dispose();
    super.dispose();
  }

  void savePaymentMethod() {
    final reference = referenceController.text.trim();
    if (selectedMethod == 'GCash' && reference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your GCash reference number.')),
      );
      return;
    }

    Provider.of<CheckoutProvider>(
      context,
      listen: false,
    ).updatePaymentMethod(
      selectedMethod,
      paymentReference: reference,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Method',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Select how you want to pay for your order.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            RadioGroup<String>(
              groupValue: selectedMethod,

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedMethod = value;
                });
              },

              child: Column(
                children: [
                  Card(
                    child: RadioListTile<String>(
                      value:
                          'Cash on Delivery',

                      title: const Text(
                        'Cash on Delivery',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        'Pay when your order is delivered.',
                      ),

                      secondary: const Icon(
                        Icons.payments_outlined,
                      ),
                    ),
                  ),

                  if (selectedMethod == 'GCash') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: referenceController,
                      decoration: const InputDecoration(
                        labelText: 'GCash Reference Number',
                        hintText: 'Enter payment reference',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Card(
                    child: RadioListTile<String>(
                      value: 'GCash',

                      title: const Text(
                        'GCash',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        'Pay using your GCash account.',
                      ),

                      secondary: const Icon(
                        Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed:
                    savePaymentMethod,

                child: const Text(
                  'Save Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
