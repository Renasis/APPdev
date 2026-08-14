import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class EditProfileScreen
    extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  bool _initialized = false;

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_initialized) return;

  final customer =
      Provider.of<ProfileProvider>(
    context,
    listen: false,
  ).customer;

  nameController.text =
      customer.fullName;

  emailController.text =
      customer.email;

  phoneController.text =
      customer.phoneNumber;

  _initialized = true;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Edit Profile'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Full Name',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  phoneController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Phone Number',
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  Provider.of<
                      ProfileProvider>(
                    context,
                    listen: false,
                  ).updateProfile(
                    fullName:
                        nameController.text,
                    email:
                        emailController.text,
                    phoneNumber:
                        phoneController.text,
                  );

                  Navigator.pop(context);
                },

                child: const Text(
                  'Save Changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
void dispose() {
  nameController.dispose();
  emailController.dispose();
  phoneController.dispose();
  super.dispose();
}
}