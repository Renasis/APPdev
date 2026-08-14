import 'package:flutter/material.dart';

import '../providers/staff_provider.dart';

class StaffTile extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const StaffTile({
    super.key,
    required this.staff,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            staff.name.isNotEmpty
                ? staff.name[0].toUpperCase()
                : '?',
          ),
        ),

        title: Text(
          staff.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(staff.email),
            Text(
              'Role: ${staff.role}',
            ),
            const SizedBox(height: 4),
            Text(
              staff.isActive
                  ? 'Active'
                  : 'Inactive',
              style: TextStyle(
                color: staff.isActive
                    ? Colors.green
                    : Colors.red,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;

              case 'toggle':
                onToggleStatus();
                break;

              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Text(
                staff.isActive
                    ? 'Deactivate'
                    : 'Activate',
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
              ),
            ),
          ],
        ),
      ),
    );
  }
}