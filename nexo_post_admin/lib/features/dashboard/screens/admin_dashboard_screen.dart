import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(systemMetricsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('System Overview', style: Theme.of(context).textTheme.displayMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Export Report'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          metricsAsync.when(
            data: (metrics) => Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Users',
                    value: metrics['totalUsers'] ?? '0',
                    trend: '+12%',
                    icon: LucideIcons.users,
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Daily Posts',
                    value: metrics['dailyPosts'] ?? '0',
                    trend: '+5%',
                    icon: LucideIcons.send,
                    color: AppColors.secondaryAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Revenue',
                    value: metrics['revenue'] ?? '\$0',
                    trend: '+18%',
                    icon: LucideIcons.coins,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Success Rate',
                    value: metrics['errorRate'] ?? '0%',
                    trend: '+0.2%',
                    icon: LucideIcons.checkCircle,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          
          const SizedBox(height: 32),
          
          // Charts Section (Mocks)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _ChartContainer(
                  title: 'Activity Pulse',
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.primaryAccent.withOpacity(0.05),
                          AppColors.primaryAccent.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text('Activity Graph Mockup', style: TextStyle(color: AppColors.textDisabled)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _ChartContainer(
                  title: 'Platform Distribution',
                  child: SizedBox(
                    height: 300,
                    child: const Center(
                      child: Text('Pie Chart Mockup', style: TextStyle(color: AppColors.textDisabled)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ],
    );
  }
}
