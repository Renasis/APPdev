import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../providers/address_provider.dart';

class EditAddressScreen extends StatefulWidget {
  final AddressModel address;

  const EditAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<EditAddressScreen> createState() =>
      _EditAddressScreenState();
}

class _EditAddressScreenState
    extends State<EditAddressScreen> {
  late final TextEditingController
      fullNameController;

  late final TextEditingController
      phoneController;

  late final TextEditingController
      addressController;

  @override
  void initState() {
    super.initState();

    fullNameController =
        TextEditingController(
      text: widget.address.fullName,
    );

    phoneController =
        TextEditingController(
      text: widget.address.phoneNumber,
    );

    addressController =
        TextEditingController(
      text: widget.address.address,
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  void saveChanges() {
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

    final updatedAddress = AddressModel(
      id: widget.address.id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      isDefault:
          widget.address.isDefault,
    );

    context
        .read<AddressProvider>()
        .updateAddress(
          updatedAddress,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Address updated successfully.',
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
          'Edit Address',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Edit Delivery Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Update your saved delivery address.',
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
            // SAVE CHANGES
            // =========================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveChanges,

                child: const Text(
                  'Save Changes',
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