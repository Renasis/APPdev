import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/saved_build_provider.dart';
import '../../pc_builder/providers/pc_builder_provider.dart';
import '../../pc_builder/screens/pc_builder_screen.dart';




class SavedBuildsScreen extends StatelessWidget {
  const SavedBuildsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedBuildProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Builds'),
      ),

      body: provider.savedBuilds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.computer_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No saved builds yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Create a PC build and save it here.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.savedBuilds.length,
              itemBuilder: (context, index) {
                final build = provider.savedBuilds[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Build Header
                        Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(
                                Icons.computer,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    build.buildName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Created ${_formatDate(build.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                _confirmDelete(
                                  context,
                                  provider,
                                  build.id,
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 25),

                        // Components
                        _componentRow(
  'CPU',
  build.cpu?.name ?? 'Not selected',
),

_componentRow(
  'GPU',
  build.gpu?.name ?? 'Not selected',
),

_componentRow(
  'Motherboard',
  build.motherboard?.name ?? 'Not selected',
),

_componentRow(
  'RAM',
  build.ram?.name ?? 'Not selected',
),

_componentRow(
  'Storage',
  build.storage?.name ?? 'Not selected',
),

_componentRow(
  'PSU',
  build.psu?.name ?? 'Not selected',
),
_componentRow(
  'Case',
  build.pcCase?.name ?? 'Not selected',
),

                        const SizedBox(height: 15),

                        // Total Price
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(
                                '₱${build.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
  final pcBuilderProvider =
      context.read<PcBuilderProvider>();

  pcBuilderProvider.loadBuild(
    cpu: build.cpu,
    gpu: build.gpu,
    motherboard: build.motherboard,
    ram: build.ram,
    storage: build.storage,
    psu: build.psu,
    pcCase: build.pcCase,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PcBuilderScreen(),
    ),
  );
},
    icon: const Icon(Icons.upload),
    label: const Text('Load Build'),
  ),
),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _componentRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _confirmDelete(
    BuildContext context,
    SavedBuildProvider provider,
    String buildId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Saved Build?',
          ),
          content: const Text(
            'This build will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                provider.removeBuild(buildId);
                Navigator.pop(dialogContext);
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
