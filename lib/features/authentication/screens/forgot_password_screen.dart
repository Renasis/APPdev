import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (emailController.text.trim().isEmpty) {
      _showMessage('Please enter your email address.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.sendPasswordResetEmail(
      emailController.text,
    );

    if (!mounted) {
      return;
    }

    if (sent) {
      _showMessage('Password reset link sent. Check your inbox.');
      context.pop();
      return;
    }

    _showMessage(authProvider.errorMessage ?? 'Could not send reset link.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                'Enter the email address for your account and we will send you '
                'a link to reset your password.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Enter email address',
                controller: emailController,
              ),

              const SizedBox(height: 30),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  text: 'Send Reset Link',
                  onPressed: _sendResetLink,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
