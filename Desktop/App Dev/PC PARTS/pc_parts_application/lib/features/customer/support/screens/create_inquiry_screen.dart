import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/support_provider.dart';
import '../../notifications/providers/notification_provider.dart';


class CreateInquiryScreen extends StatefulWidget {
  const CreateInquiryScreen({super.key});

  @override
  State<CreateInquiryScreen> createState() =>
      _CreateInquiryScreenState();
}

class _CreateInquiryScreenState
    extends State<CreateInquiryScreen> {
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  String selectedCategory = 'Order';

  final List<String> categories = [
    'Order',
    'Product',
    'Payment',
    'Account',
    'Technical',
    'Other',
  ];

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void submitInquiry() {
    final subject =
        subjectController.text.trim();

    final message =
        messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all fields',
          ),
        ),
      );

      return;
    }

    Provider.of<SupportProvider>(
      context,
      listen: false,
    ).createInquiry(
      subject: subject,
      message: message,
      category: selectedCategory,
    );
    Provider.of<NotificationProvider>(
  context,
  listen: false,
).addNotification(
  title: 'Support Inquiry Submitted',
  message:
      'Your $selectedCategory inquiry has been submitted successfully.',
);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Inquiry submitted successfully',
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
          'New Inquiry',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Submit your concern and our support staff will assist you.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,

              decoration:
                  const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.category_outlined),
              ),

              items: categories.map(
                (category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Subject',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: subjectController,

              decoration:
                  const InputDecoration(
                labelText: 'Subject',
                hintText:
                    'Enter your concern',
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.subject),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Message',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: messageController,

              maxLines: 7,

              decoration:
                  const InputDecoration(
                labelText: 'Message',
                hintText:
                    'Describe your concern...',
                border:
                    OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: submitInquiry,

                icon: const Icon(
                  Icons.send,
                ),

                label: const Text(
                  'Submit Inquiry',
                ),

                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
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