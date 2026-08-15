import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/enums/user_role.dart';
import '../../admin/staff/services/staff_account_service.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class StaffRegisterScreen extends StatefulWidget {
  const StaffRegisterScreen({super.key});

  @override
  State<StaffRegisterScreen> createState() => _StaffRegisterScreenState();
}

class _StaffRegisterScreenState extends State<StaffRegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isCheckingInvitation = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      return 'Please fill in your name, email and password.';
    }

    if (passwordController.text != confirmPasswordController.text) {
      return 'Passwords do not match.';
    }

    if (passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  Future<void> _createAccount() async {
    final validationError = _validate();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    final normalizedEmail = emailController.text.trim().toLowerCase();
    final staffAccountService = StaffAccountService();

    setState(() {
      _isCheckingInvitation = true;
    });

    try {
      final invitation = await staffAccountService.fetchPendingInvitation(
        normalizedEmail,
      );

      if (invitation == null) {
        _showMessage(
          'No pending staff invitation was found for $normalizedEmail. '
          'Please contact your administrator.',
        );
        return;
      }

      if (invitation['status'] != 'pending') {
        _showMessage(
          'This invitation has already been used or is no longer valid.',
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();

      final registered = await authProvider.register(
        fullName: fullNameController.text.trim(),
        email: normalizedEmail,
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (registered) {
        final role = authProvider.role;

        if (role == UserRole.staff) {
          context.go(RouteNames.staffDashboard);
        } else {
          _showMessage(
            'Your account was created, but staff access could not be activated. '
            'Please contact your administrator.',
          );
        }
        return;
      }

      _showMessage(authProvider.errorMessage ?? 'Registration failed.');
    } catch (error) {
      _showMessage('Registration failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingInvitation = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isCheckingInvitation || context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Staff Registration',
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
                'Complete your staff account setup',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              const Text(
                'FULL NAME',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Enter full name',
                controller: fullNameController,
              ),

              const SizedBox(height: 20),

              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Enter the email you were invited with',
                controller: emailController,
              ),

              const SizedBox(height: 20),

              const Text(
                'PHONE NUMBER',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Enter phone number',
                controller: phoneController,
              ),

              const SizedBox(height: 20),

              const Text(
                'PASSWORD',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Create a password',
                controller: passwordController,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'CONFIRM PASSWORD',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Confirm your password',
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),

                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'You must use the exact email address your administrator invited.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  text: 'Create Staff Account',
                  onPressed: _createAccount,
                ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),

                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },

                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
