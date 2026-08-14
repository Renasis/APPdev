import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:pc_parts_application/core/routes/route_names.dart';
import 'package:pc_parts_application/features/authentication/providers/auth_provider.dart';
import 'package:pc_parts_application/core/enums/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAuth());
  }

  Future<void> _resolveAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final destination = _destinationFor(auth);
    if (!mounted) return;
    context.go(destination);
  }

  String _destinationFor(AuthProvider auth) {
    if (!auth.isLoggedIn || auth.role == null) {
      return RouteNames.roleSelection;
    }

    final role = auth.role!;
    if (role == UserRole.admin) {
      return RouteNames.adminDashboard;
    } else if (role == UserRole.staff) {
      return RouteNames.staffDashboard;
    } else if (role == UserRole.customer) {
      return RouteNames.home;
    }

    return RouteNames.roleSelection;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'END PC PARTS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
