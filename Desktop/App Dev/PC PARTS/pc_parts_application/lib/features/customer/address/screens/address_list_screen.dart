import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/address_provider.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';
import '../../checkout/providers/checkout_provider.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    final addresses = addressProvider.addresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),

      body: addresses.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addresses[index];

                return InkWell(
  onTap: () {
    addressProvider.setDefaultAddress(
      address.id,
    );

    context
        .read<CheckoutProvider>()
        .updateShippingAddress(
          fullName: address.fullName,
          phoneNumber: address.phoneNumber,
          address: address.address,
        );

    Navigator.pop(context);
  },

  child: Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =========================
          // NAME + DEFAULT BADGE
          // =========================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 24,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      address.phoneNumber,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              if (address.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            address.address,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 4),

          Row(
            children: [
              if (!address.isDefault)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      addressProvider
                          .setDefaultAddress(
                        address.id,
                      );

                      context
                          .read<CheckoutProvider>()
                          .updateShippingAddress(
                            fullName:
                                address.fullName,
                            phoneNumber:
                                address.phoneNumber,
                            address:
                                address.address,
                          );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Address selected.',
                          ),
                        ),
                      );

                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.check_circle_outline,
                    ),
                    label: const Text(
                      'Set Default',
                    ),
                  ),
                ),

              if (!address.isDefault)
                const SizedBox(width: 8),

              IconButton(
                tooltip: 'Edit address',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditAddressScreen(
                        address: address,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),

              IconButton(
                tooltip: 'Delete address',
                onPressed: () {
                  _showDeleteDialog(
                    context,
                    addressProvider,
                    address.id,
                    address.fullName,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
              },
            ),

      // =========================
      // ADD ADDRESS
      // =========================

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAddressScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Address',
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add a delivery address to make checkout faster and easier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: 220,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddAddressScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Add Address',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DELETE CONFIRMATION
  // =====================================================

  void _showDeleteDialog(
    BuildContext context,
    AddressProvider addressProvider,
    String addressId,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Address?',
          ),

          content: Text(
            'Are you sure you want to delete the address for "$name"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                addressProvider.deleteAddress(
                  addressId,
                );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Address deleted.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}