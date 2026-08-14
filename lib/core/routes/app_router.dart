import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/guest_prompt_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/guest_login_required_screen.dart';
import '../../features/authentication/screens/otp_screen.dart';
import '../../features/authentication/screens/role_selection_screen.dart';
import '../../features/authentication/screens/staff_admin_login_screen.dart';
import '../../features/staff/shell/screens/staff_shell_screen.dart';

import '../../navigation/main_navigation_wrapper.dart';
import '../../features/admin/shell/screens/admin_shell_screen.dart';

import '../../features/authentication/providers/auth_provider.dart';
import '../../core/enums/user_role.dart';

import 'route_names.dart';

String? _appRedirect(BuildContext context, GoRouterState state) {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  if (auth.isLoading) {
    return null;
  }

  final path = state.uri.path;

  final publicRoutes = <String>{
    RouteNames.splash,
    RouteNames.roleSelection,
    RouteNames.guestPrompt,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
    RouteNames.guestLoginRequired,
    RouteNames.otp,
  };

  final isStaffAdminLogin = path.startsWith(RouteNames.staffAdminLogin);

  if (publicRoutes.contains(path) || isStaffAdminLogin) {
    return null;
  }

  if (!auth.isLoggedIn) {
    return RouteNames.login;
  }

  if (path == RouteNames.adminDashboard && auth.role != UserRole.admin) {
    return RouteNames.splash;
  }

  if (path == RouteNames.staffDashboard && auth.role != UserRole.staff) {
    return RouteNames.splash;
  }

  return null;
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _appRedirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      GoRoute(
        path: RouteNames.guestPrompt,
        builder: (context, state) => const GuestPromptScreen(),
      ),

      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '${RouteNames.staffAdminLogin}/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'staff';
          return StaffAdminLoginScreen(
            requestedRole: role,
          );
        },
      ),

      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: RouteNames.guestLoginRequired,
        builder: (context, state) => const GuestLoginRequiredScreen(),
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) => const OtpScreen(),
      ),

      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const MainNavigationWrapper(),
      ),

      GoRoute(
        path: RouteNames.staffDashboard,
        builder: (context, state) => const StaffShellScreen(),
      ),

      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminShellScreen(),
      ),
    ],
  );
}

final GoRouter appRouter = _buildRouter();
