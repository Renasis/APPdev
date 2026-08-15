import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/support_provider.dart';
import 'create_inquiry_screen.dart';
import 'inquiry_details_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supportProvider =
        Provider.of<SupportProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateInquiryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Inquiry'),
      ),

      body: supportProvider.inquiries.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No support inquiries yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Need help? Create an inquiry.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount:
                  supportProvider.inquiries.length,
              itemBuilder: (context, index) {
                final inquiry =
                    supportProvider.inquiries[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        _categoryIcon(
                          inquiry.category,
                        ),
                      ),
                    ),

                    title: Text(
                      inquiry.subject,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),

                        Text(
                          inquiry.category,
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _formatDate(
                            inquiry.createdAt,
                          ),
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    trailing: _statusBadge(
                      inquiry.status,
                    ),

                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (_) =>
                               InquiryDetailsScreen(
                             inquiryId: inquiry.id,
                           ),
                         ),
                       );
                     },
                  ),
                );
              },
            ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: _statusColor(status)
            .withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.blue;

      case 'Resolved':
        return Colors.green;

      case 'Closed':
        return Colors.grey;

      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Order':
        return Icons.receipt_long;

      case 'Product':
        return Icons.memory;

      case 'Payment':
        return Icons.payment;

      case 'Account':
        return Icons.person;

      case 'Technical':
        return Icons.build;

      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}