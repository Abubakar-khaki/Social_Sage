import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../pages/onboarding/welcome_screen.dart';
import '../../pages/onboarding/security_setup_screen.dart';
import '../../pages/shell/app_shell.dart';
import '../../pages/home/home_page.dart';
import '../../pages/post_creator/post_creator_page.dart';
import '../../pages/scheduler/scheduler_page.dart';
import '../../pages/analytics/analytics_page.dart';
import '../../pages/library/library_page.dart';
import '../../pages/inbox/inbox_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../data/services/storage_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  redirect: (context, state) {
    final isSetup = StorageService.isSetupComplete;
    final loc = state.uri.toString();
    // If already set up and trying onboarding, redirect to home
    if (isSetup && (loc == '/onboarding' || loc == '/security-setup')) {
      return '/home';
    }
    // If not set up and trying to access app, redirect to onboarding
    if (!isSetup && loc != '/onboarding' && loc != '/security-setup') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    // ── Onboarding ──
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/security-setup',
      builder: (context, state) {
        final username = state.extra as String? ?? '';
        return SecuritySetupScreen(username: username);
      },
    ),

    // ── Main App Shell ──
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/scheduler',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SchedulerPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/inbox',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const InboxPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),

    // ── Full-screen pages ──
    GoRoute(
      path: '/post-creator',
      builder: (context, state) => const PostCreatorPage(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsPage(),
    ),
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryPage(),
    ),
  ],
);
