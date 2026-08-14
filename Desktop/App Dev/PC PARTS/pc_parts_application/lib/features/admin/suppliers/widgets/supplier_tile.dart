import 'package:flutter/material.dart';

import '../providers/supplier_provider.dart';

class SupplierTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupplierTile({
    super.key,
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          supplier.name,
        ),
        subtitle: Text(
          supplier.contactPerson,
        ),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}