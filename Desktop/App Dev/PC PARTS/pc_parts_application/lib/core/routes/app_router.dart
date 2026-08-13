import 'package:go_router/go_router.dart';

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



import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
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
    final role =
        state.pathParameters['role']!;

    return StaffAdminLoginScreen(
      role: role,
    );
  },
),

    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    
    GoRoute(
      path: RouteNames.guestLoginRequired,
      builder: (context, state) =>const GuestLoginRequiredScreen(),
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
      builder: (context, state) =>
          const StaffShellScreen(),
    ),

    GoRoute(
      path: RouteNames.adminDashboard,
      builder: (context, state) =>
          const AdminShellScreen(),
    ),

    GoRoute(
      path: '/admin-shell',
      builder: (context, state) =>
          const AdminShellScreen(),
    ),



  ],
);
