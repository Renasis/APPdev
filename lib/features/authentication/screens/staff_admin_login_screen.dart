import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/enums/user_role.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class StaffAdminLoginScreen extends StatefulWidget {
  final String requestedRole;

  const StaffAdminLoginScreen({
    super.key,
    required this.requestedRole,
  });

  @override
  State<StaffAdminLoginScreen> createState() => _StaffAdminLoginScreenState();
}

class _StaffAdminLoginScreenState extends State<StaffAdminLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final authProvider = context.read<AuthProvider>();

    final signedIn = await authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Sign in failed.',
          ),
        ),
      );
      return;
    }

    final role = authProvider.role;
    final expectedRole = widget.requestedRole == 'admin'
        ? UserRole.admin
        : UserRole.staff;

    if (role != expectedRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You are not authorized to access this portal.',
          ),
        ),
      );

      await authProvider.logout();
      return;
    }

    if (role == UserRole.admin) {
      context.go(RouteNames.adminDashboard);
    } else if (role == UserRole.staff) {
      context.go(RouteNames.staffDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isAdminPortal = widget.requestedRole == 'admin';

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 40),

              const AppLogo(),

              const SizedBox(height: 30),

              Text(
                isAdminPortal ? 'Admin Portal' : 'Staff Portal',
                style: const TextStyle(
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
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,

                child: TextButton(
                  onPressed: () {
                    context.push(RouteNames.forgotPassword);
                  },

                  child: const Text(
                    'Forgot Password?',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  text: 'Sign In',
                  onPressed: _signIn,
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

              if (!isAdminPortal) ...[
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () {
                      context.push(RouteNames.staffRegister);
                    },

                    child: const Text(
                      'Have a staff invitation? Create your account',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
