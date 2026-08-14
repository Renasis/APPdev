import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/inventory/providers/inventory_provider.dart';

class StaffInventoryScreen extends StatelessWidget {
  const StaffInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final lowStockCount =
        inventory.items.where((item) => item.stock > 2 && item.stock <= 5).length;
    final criticalCount =
        inventory.items.where((item) => item.stock <= 2).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'View live stock levels. Stock changes are managed by Admin.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _SummaryChip(label: 'Products', value: inventory.items.length),
            _SummaryChip(label: 'Low Stock', value: lowStockCount),
            _SummaryChip(label: 'Critical', value: criticalCount),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: inventory.items.isEmpty
              ? const Center(child: Text('No inventory items found.'))
              : ListView.separated(
                  itemCount: inventory.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _InventoryItemCard(item: inventory.items[index]),
                ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;

  const _InventoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      'Critical' => Colors.red,
      'Low Stock' => Colors.orange,
      _ => Colors.green,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.inventory_2_outlined, color: color),
        ),
        title: Text(item.productName),
        subtitle: Text('Current stock: ${item.stock}'),
        trailing: Chip(
          label: Text(item.status),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}
