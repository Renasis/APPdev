import 'package:flutter/material.dart';

import '../models/order_model.dart';

class DeliveryDetailsDialog extends StatefulWidget {
  const DeliveryDetailsDialog({super.key});

  static Future<DeliveryDetails?> show(BuildContext context) {
    return showDialog<DeliveryDetails>(
      context: context,
      builder: (_) => const DeliveryDetailsDialog(),
    );
  }

  @override
  State<DeliveryDetailsDialog> createState() => _DeliveryDetailsDialogState();
}

class _DeliveryDetailsDialogState extends State<DeliveryDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _riderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _estimatedDate;

  @override
  void initState() {
    super.initState();
    _estimatedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _courierController.dispose();
    _trackingController.dispose();
    _riderController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectEstimatedDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _estimatedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null && mounted) {
      setState(() => _estimatedDate = selected);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      DeliveryDetails(
        courierName: _courierController.text.trim(),
        trackingNumber: _trackingController.text.trim(),
        riderName: _riderController.text.trim(),
        riderPhoneNumber: _phoneController.text.trim(),
        estimatedDeliveryDate: _estimatedDate,
        deliveryNotes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delivery Details'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _courierController,
                  decoration: const InputDecoration(
                    labelText: 'Courier or delivery service',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the courier or delivery service.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _trackingController,
                  decoration: const InputDecoration(labelText: 'Tracking number'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a tracking number.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _riderController,
                  decoration: const InputDecoration(
                    labelText: 'Rider name (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Rider contact number (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Estimated delivery date'),
                  subtitle: Text(
                    MaterialLocalizations.of(context).formatMediumDate(_estimatedDate),
                  ),
                  onTap: _selectEstimatedDate,
                ),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Delivery notes (optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text('Mark Out for Delivery'),
        ),
      ],
    );
  }
}
