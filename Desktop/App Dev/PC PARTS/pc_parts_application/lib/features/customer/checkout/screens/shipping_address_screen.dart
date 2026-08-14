import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() =>
      _ShippingAddressScreenState();
}

class _ShippingAddressScreenState
    extends State<ShippingAddressScreen> {
  final fullNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    final checkout =
        Provider.of<CheckoutProvider>(
      context,
      listen: false,
    ).checkout;

    if (checkout != null) {
      fullNameController.text =
          checkout.fullName;

      phoneController.text =
          checkout.phoneNumber;

      addressController.text =
          checkout.address;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  void saveAddress() {
    final fullName =
        fullNameController.text.trim();

    final phone =
        phoneController.text.trim();

    final address =
        addressController.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all address fields.',
          ),
        ),
      );

      return;
    }

    Provider.of<CheckoutProvider>(
      context,
      listen: false,
    ).updateShippingAddress(
      fullName: fullName,
      phoneNumber: phone,
      address: address,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shipping Address',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Enter the address where you want your order delivered.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText:
                    'Enter your full name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '09XXXXXXXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: addressController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Complete Address',
                hintText:
                    'House/Unit, Street, Barangay, Municipality/City, Province',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveAddress,

                child: const Text(
                  'Save Address',
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