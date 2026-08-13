import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/staff_provider.dart';

class EditStaffScreen extends StatefulWidget {
  final StaffMember staff;

  const EditStaffScreen({
    super.key,
    required this.staff,
  });

  @override
  State<EditStaffScreen> createState() =>
      _EditStaffScreenState();
}

class _EditStaffScreenState
    extends State<EditStaffScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  late String selectedRole;
  late bool isActive;

  final List<String> roles = [
    'Staff',
    'Manager',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.staff.name,
    );

    emailController = TextEditingController(
      text: widget.staff.email,
    );

    selectedRole = widget.staff.role;
    isActive = widget.staff.isActive;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void updateStaff() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all fields.',
          ),
        ),
      );
      return;
    }

    final updatedStaff = StaffMember(
      id: widget.staff.id,
      name: name,
      email: email,
      role: selectedRole,
      isActive: isActive,
    );

    context.read<StaffProvider>().updateStaff(
      updatedStaff,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$name updated successfully.',
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
          'Edit Staff',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Staff Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              items: roles.map(
                (role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                },
              ).toList(),

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedRole = value;
                });
              },
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Active Staff',
              ),
              subtitle: Text(
                isActive
                    ? 'Staff member is active'
                    : 'Staff member is inactive',
              ),
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: updateStaff,

                icon: const Icon(
                  Icons.save_outlined,
                ),

                label: const Text(
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