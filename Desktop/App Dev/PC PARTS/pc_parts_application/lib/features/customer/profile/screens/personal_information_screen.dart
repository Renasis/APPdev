import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class PersonalInformationScreen
    extends StatelessWidget {
  const PersonalInformationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider =
        Provider.of<ProfileProvider>(context);

    final customer =
        profileProvider.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _infoTile(
              'Full Name',
              customer.fullName,
            ),

            _infoTile(
              'Email',
              customer.email,
            ),

            _infoTile(
              'Phone Number',
              customer.phoneNumber,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EditProfileScreen(),
                    ),
                  );
                },

                child: const Text(
                  'Edit Profile',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    String title,
    String value,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),

      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}