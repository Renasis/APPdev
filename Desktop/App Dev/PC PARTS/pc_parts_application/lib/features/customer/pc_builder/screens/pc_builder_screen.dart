import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pc_builder_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/models/product_model.dart';
import '../../saved_builds/providers/saved_build_provider.dart';
import '../../saved_builds/models/saved_build_model.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';


class PcBuilderScreen extends StatelessWidget {
  const PcBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final builder = context.watch<PcBuilderProvider>();
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Builder'),
        actions: [
          IconButton(
            onPressed: builder.clearBuild,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Build',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Build Your PC',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Select compatible components for your PC build.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            _componentCard(
              context,
              title: 'CPU',
              icon: Icons.memory,
              product: builder.cpu,
              products: products,
              category: 'CPU',
              onSelect: builder.selectCpu,
              onRemove: builder.removeCpu,
            ),

            _componentCard(
              context,
              title: 'GPU',
              icon: Icons.videogame_asset_outlined,
              product: builder.gpu,
              products: products,
              category: 'GPU',
              onSelect: builder.selectGpu,
              onRemove: builder.removeGpu,
            ),

            _componentCard(
              context,
              title: 'Motherboard',
              icon: Icons.developer_board_outlined,
              product: builder.motherboard,
              products: products,
              category: 'Motherboard',
              onSelect: builder.selectMotherboard,
              onRemove: builder.removeMotherboard,
            ),

            _componentCard(
              context,
              title: 'RAM',
              icon: Icons.storage,
              product: builder.ram,
              products: products,
              category: 'RAM',
              onSelect: builder.selectRam,
              onRemove: builder.removeRam,
            ),

            _componentCard(
              context,
              title: 'Storage',
              icon: Icons.sd_storage_outlined,
              product: builder.storage,
              products: products,
              category: 'Storage',
              onSelect: builder.selectStorage,
              onRemove: builder.removeStorage,
            ),

            _componentCard(
              context,
              title: 'PSU',
              icon: Icons.power,
              product: builder.psu,
              products: products,
              category: 'PSU',
              onSelect: builder.selectPsu,
              onRemove: builder.removePsu,
            ),

            _componentCard(
              context,
              title: 'Case',
              icon: Icons.desktop_windows_outlined,
              product: builder.pcCase,
              products: products,
              category: 'Case',
              onSelect: builder.selectCase,
              onRemove: builder.removeCase,
            ),

            const SizedBox(height: 20),

            // Total Price
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₱${builder.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Build Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: builder.isBuildComplete
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    builder.isBuildComplete
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: builder.isBuildComplete
                        ? Colors.green
                        : Colors.orange,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      builder.isBuildComplete
                          ? 'Your PC build is complete.'
                          : 'Select all required components to complete your build.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _CompatibilityPanel(
              warnings: builder.compatibilityWarnings,
              isComplete: builder.isBuildComplete,
            ),

            const SizedBox(height: 20),

            SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: builder.isBuildComplete
        ? () {
            _showSaveBuildDialog(
              context,
              builder,
            );
          }
        : null,

    icon: const Icon(
      Icons.save_outlined,
    ),

    label: const Text(
      'Save Build',
    ),
  ),
  ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: builder.isBuildComplete && builder.isBuildCompatible
                    ? () => _addBuildToCart(context, builder)
                    : null,
                icon: const Icon(Icons.shopping_cart_checkout_outlined),
                label: const Text('Add Full Build to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

    void _showSaveBuildDialog(
    BuildContext context,
    PcBuilderProvider builder,
  ) {
    final controller =
        TextEditingController(
      text: 'My PC Build',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Save PC Build',
          ),

          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Build Name',
              hintText: 'Gaming Build',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final buildName =
                    controller.text.trim();

                if (buildName.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a build name.',
                      ),
                    ),
                  );

                  return;
                }

                final savedBuildProvider =
                    context.read<SavedBuildProvider>();

                final build = SavedBuildModel(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),

                  buildName: buildName,

                  cpu: builder.cpu,
                  gpu: builder.gpu,
                  motherboard:
                      builder.motherboard,
                  ram: builder.ram,
                  storage: builder.storage,
                  psu: builder.psu,
                  pcCase: builder.pcCase,

                  totalPrice:
                      builder.totalPrice,

                  createdAt: DateTime.now(),
                );

                savedBuildProvider.addBuild(
                  build,
                );

                context
                    .read<NotificationProvider>()
                    .addNotification(
                      title: 'Build Saved',
                      message:
                          '$buildName has been saved successfully.',
                    );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'PC build saved successfully.',
                    ),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addBuildToCart(BuildContext context, PcBuilderProvider builder) {
    final added = context.read<CartProvider>().addCustomPcBuild(
          buildName: 'Custom PC Build',
          products: builder.selectedProducts,
        );

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'One or more build parts are not available in the requested quantity.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full PC build added to your cart.')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  Widget _componentCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ProductModel? product,
    required List<ProductModel> products,
    required String category,
    required void Function(ProductModel) onSelect,
    required VoidCallback onRemove,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: Icon(icon),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: product == null
                  ? Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No $category selected',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₱${product.price.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
            ),

            if (product == null)
              TextButton(
                onPressed: () {
                  _showProductSelector(
                    context,
                    title,
                    category,
                    products,
                    onSelect,
                  );
                },
                child: const Text('Select'),
              )
            else
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProductSelector(
    BuildContext context,
    String title,
    String category,
    List<ProductModel> products,
    void Function(ProductModel) onSelect,
  ) {
    final categoryProducts = products
        .where(
          (product) =>
              product.category.toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select $title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: categoryProducts.isEmpty
                      ? Center(
                          child: Text(
                            'No $category products available.',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount:
                              categoryProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                categoryProducts[index];

                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.memory,
                                ),
                                title: Text(
                                  product.name,
                                ),
                                subtitle: Text(
                                  '₱${product.price.toStringAsFixed(2)}',
                                ),
                                trailing:
                                    const Icon(
                                  Icons.add,
                                ),
                                onTap: () {
                                  onSelect(product);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompatibilityPanel extends StatelessWidget {
  final List<String> warnings;
  final bool isComplete;

  const _CompatibilityPanel({
    required this.warnings,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hasWarnings = warnings.isNotEmpty;
    final color = hasWarnings ? Colors.orange : Colors.green;
    final title = hasWarnings
        ? 'Compatibility warnings'
        : isComplete
            ? 'Components appear compatible'
            : 'Compatibility check';
    final message = hasWarnings
        ? warnings.join('\n')
        : isComplete
            ? 'Your selected components have no known compatibility conflicts.'
            : 'Compatibility warnings will appear as you select components.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasWarnings ? Icons.warning_amber_outlined : Icons.verified_outlined,
            color: color.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color.shade900, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: color.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
