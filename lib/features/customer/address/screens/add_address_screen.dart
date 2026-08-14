import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../providers/address_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() =>
      _AddAddressScreenState();
}

class _AddAddressScreenState
    extends State<AddAddressScreen> {
  final fullNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

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

    final phoneNumber =
        phoneController.text.trim();

    final address =
        addressController.text.trim();

    if (fullName.isEmpty ||
        phoneNumber.isEmpty ||
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

    if (phoneNumber.length != 11 ||
    !phoneNumber.startsWith('09')) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please enter a valid Philippine mobile number.',
      ),
    ),
  );

  return;
}

    final newAddress = AddressModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
    );

    context.read<AddressProvider>().addAddress(
          newAddress,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Address added successfully.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Address',
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
              'Add a delivery address for your orders.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // FULL NAME
            // =========================

            TextField(
              controller: fullNameController,
              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText:
                    'Enter recipient full name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // PHONE NUMBER
            // =========================

            TextField(
              controller: phoneController,
              keyboardType:
                  TextInputType.phone,
              textInputAction:
                  TextInputAction.next,

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

            // =========================
            // ADDRESS
            // =========================

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

            // =========================
            // SAVE
            // =========================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveAddress,

                child: const Text(
                  'Save Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
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