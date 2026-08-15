import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/guest_prompt_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/staff_register_screen.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/guest_login_required_screen.dart';
import '../../features/authentication/screens/otp_screen.dart';
import '../../features/authentication/screens/role_selection_screen.dart';
import '../../features/authentication/screens/staff_admin_login_screen.dart';
import '../../features/staff/shell/screens/staff_shell_screen.dart';
import '../../features/admin/sales/screens/walk_in_sale_screen.dart';
import '../../features/customer/support/screens/support_screen.dart';
import '../../features/customer/support/screens/create_inquiry_screen.dart';
import '../../features/customer/support/screens/inquiry_details_screen.dart';

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

  if (path == RouteNames.walkInSale && auth.role != UserRole.admin && auth.role != UserRole.staff) {
    return RouteNames.splash;
  }

  if (auth.currentUser != null && !auth.currentUser!.isActive) {
    if (path == RouteNames.staffDashboard || path == RouteNames.walkInSale) {
      return RouteNames.roleSelection;
    }
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
        path: RouteNames.staffRegister,
        builder: (context, state) => const StaffRegisterScreen(),
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

      GoRoute(
        path: RouteNames.walkInSale,
        builder: (context, state) => const WalkInSaleScreen(),
      ),

      GoRoute(
        path: RouteNames.support,
        builder: (context, state) => const SupportScreen(),
      ),

      GoRoute(
        path: '${RouteNames.support}/create',
        builder: (context, state) => const CreateInquiryScreen(),
      ),

      GoRoute(
        path: '${RouteNames.support}/:inquiryId',
        builder: (context, state) {
          final inquiryId = state.pathParameters['inquiryId'] ?? '';
          return InquiryDetailsScreen(inquiryId: inquiryId);
        },
      ),
    ],
  );
}

final GoRouter appRouter = _buildRouter();
