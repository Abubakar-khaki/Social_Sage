import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/admin_layout.dart';
import 'features/dashboard/screens/admin_dashboard_screen.dart';
import 'features/users/screens/user_management_screen.dart';
import 'features/dashboard/screens/system_logs_screen.dart';
import 'features/dashboard/screens/subscription_management_screen.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AdminLayout(
          currentRoute: state.uri.toString(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/logs',
          builder: (context, state) => const SystemLogsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SubscriptionManagementScreen(),
        ),
      ],
    ),
  ],
);

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexo Post Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
