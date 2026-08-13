import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/staff_provider.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({
    super.key,
  });

  @override
  State<CreateStaffScreen> createState() =>
      _CreateStaffScreenState();
}

class _CreateStaffScreenState
    extends State<CreateStaffScreen> {
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  String selectedRole = 'Staff';

  final List<String> roles = [
    'Staff',
    'Manager',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void createStaff() {
    final name =
        nameController.text.trim();

    final email =
        emailController.text.trim();

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

    final provider =
        context.read<StaffProvider>();

    final nextNumber =
        provider.staff.length + 1;

    final member = StaffMember(
      id: 'ST-${nextNumber.toString().padLeft(3, '0')}',
      name: name,
      email: email,
      role: selectedRole,
      isActive: true,
    );

    provider.addStaff(member);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$name added successfully.',
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
          'Add Staff',
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
                hintText:
                    'Enter staff name',
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
                hintText:
                    'Enter staff email',
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

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: createStaff,

                icon: const Icon(
                  Icons.person_add_outlined,
                ),

                label: const Text(
                  'Create Staff',
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