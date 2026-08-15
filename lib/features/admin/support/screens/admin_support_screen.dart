import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customer/support/providers/support_provider.dart';
import '../../../customer/support/screens/inquiry_details_screen.dart';
import '../../../authentication/providers/auth_provider.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SupportProvider>().loadAllInquiries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support / Inquiries'),
      ),
      body: Consumer2<SupportProvider, AuthProvider>(
        builder: (context, supportProvider, authProvider, child) {
          if (supportProvider.isLoading && supportProvider.allInquiries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final inquiries = supportProvider.allInquiries;

          if (inquiries.isEmpty) {
            return const Center(
              child: Text('No support inquiries found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: inquiries.length,
            itemBuilder: (context, index) {
              final inquiry = inquiries[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      _categoryIcon(inquiry.category),
                    ),
                  ),
                  title: Text(
                    inquiry.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${inquiry.customerId}'),
                      Text(inquiry.category),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(inquiry.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: _statusBadge(inquiry.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InquiryDetailsScreen(
                          inquiryId: inquiry.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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
        color: _statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
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
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
