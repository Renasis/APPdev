import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pc_parts_application/features/staff/profile/screens/staff_profile_screen.dart';

void main() {
  testWidgets('shows the temporary staff profile details', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StaffProfileScreen())),
    );

    expect(find.text('Staff Profile'), findsOneWidget);
    expect(find.text('Store Operations'), findsOneWidget);
    expect(find.text('Exit Staff Portal'), findsOneWidget);
  });

  testWidgets('exits to role selection', (tester) async {
    final router = GoRouter(
      initialLocation: '/staff-profile',
      routes: [
        GoRoute(
          path: '/staff-profile',
          builder: (context, state) => const Scaffold(
            body: StaffProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const Scaffold(
            body: Text('Select Portal'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Exit Staff Portal'));
    await tester.pumpAndSettle();

    expect(find.text('Select Portal'), findsOneWidget);
  });
}
