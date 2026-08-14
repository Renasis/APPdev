import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/routes/route_names.dart';


class StaffAdminLoginScreen extends StatefulWidget {
  final String role;

  const StaffAdminLoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<StaffAdminLoginScreen> createState() =>
      _StaffAdminLoginScreenState();
}

class _StaffAdminLoginScreenState
    extends State<StaffAdminLoginScreen> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 40),

              const AppLogo(),

              const SizedBox(height: 30),

              Text(
                widget.role == 'admin'
                    ? 'Admin Portal'
                    : 'Staff Portal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sign in to access the shop management system.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Enter staff or admin email',
                controller: emailController,
              ),

              const SizedBox(height: 20),

              const Text(
                'PASSWORD',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              AuthTextField(
                hintText: 'Enter password',
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
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment:
                    Alignment.centerRight,

                child: TextButton(
                  onPressed: () {
                    // Firebase password recovery
                    // will be connected later.
                  },

                  child: const Text(
                    'Forgot Password?',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              PrimaryButton(
  text: 'Sign In',
  onPressed: () {

    if (widget.role == 'admin') {
      context.go(
        RouteNames.adminDashboard,
      );
    } else {
      context.go(
        RouteNames.staffDashboard,
      );
    }
  },
),

              const SizedBox(height: 30),

              Center(
                child: TextButton(
                  onPressed: () {
                    context.pop();
                  },

                  child: const Text(
                    'Back to Portal Selection',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}