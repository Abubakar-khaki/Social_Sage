import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/services/notification_service.dart';
import 'data/services/scheduler_worker.dart';
import 'data/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.instance.initialize();
  await SchedulerWorker.instance.initialize();
  await SchedulerWorker.instance.scheduleBackgroundCheck();
  runApp(const ProviderScope(child: SocialSageApp()));
}

class SocialSageApp extends StatelessWidget {
  const SocialSageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Social Sage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
