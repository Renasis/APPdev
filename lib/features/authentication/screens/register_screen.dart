import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/route_names.dart';
import '../providers/auth_provider.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptedTerms = false;

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

    if (!acceptedTerms) {
      return 'Please accept the Terms of Service to continue.';
    }

    return null;
  }

  Future<void> _createAccount() async {
    final validationError = _validate();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final registered = await authProvider.register(
      fullName: fullNameController.text,
      email: emailController.text,
      phone: phoneController.text,
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (registered) {
      final role = authProvider.role;
      if (role == UserRole.admin) {
        context.go(RouteNames.adminDashboard);
      } else if (role == UserRole.staff) {
        context.go(RouteNames.staffDashboard);
      } else {
        context.go(RouteNames.home);
      }
      return;
    }

    _showMessage(authProvider.errorMessage ?? 'Registration failed.');
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
          'Create Account',
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
                'Fill in your details to get started',
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
                hintText: 'Enter email address',
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
                hintText: 'Enter password',
                controller: passwordController,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                hintText: 'Confirm password',
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptedTerms = value ?? false;
                      });
                    },
                  ),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _createAccount,
                ),

              const SizedBox(height: 30),

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
