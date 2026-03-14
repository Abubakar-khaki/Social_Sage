import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/providers/admin_providers.dart';
import '../../../core/services/admin_api_service.dart';

class SystemLogsScreen extends ConsumerStatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  ConsumerState<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends ConsumerState<SystemLogsScreen> {
  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(adminQueueJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Queue & System Health', style: Theme.of(context).textTheme.displayMedium),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => ref.refresh(adminQueueJobsProvider),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Retry All Failed'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.power, size: 16),
                label: const Text('Kill Switch'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Queue Metrics
          Row(
            children: [
              _buildMiniMetric('Waiting', '12', LucideIcons.clock, Colors.blueAccent),
              const SizedBox(width: 16),
              _buildMiniMetric('Active', '4', LucideIcons.activity, AppColors.primaryAccent),
              const SizedBox(width: 16),
              _buildMiniMetric('Failed', '2', LucideIcons.alertTriangle, AppColors.error),
              const SizedBox(width: 16),
              _buildMiniMetric('Completed', '1,204', LucideIcons.checkCircle, AppColors.success),
            ],
          ),
          
          const SizedBox(height: 32),

          // Search & Filter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(LucideIcons.filter, size: 18, color: AppColors.textDisabled),
                  const SizedBox(width: 12),
                  const Text('Filters:', style: TextStyle(color: AppColors.textDisabled)),
                  const SizedBox(width: 16),
                  _buildTag('All Jobs', true),
                  _buildTag('Failed Only', false),
                  _buildTag('Today', false),
                  const Spacer(),
                  const SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Job ID...',
                        prefixIcon: Icon(LucideIcons.search, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Jobs Table
          Expanded(
            child: Card(
              child: jobsAsync.when(
                data: (jobs) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ListView(
                    children: [
                      _buildTableHeader(),
                      const Divider(height: 1),
                      ...jobs.map((job) => _buildJobRow(job)),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDisabled)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryAccent.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.primaryAccent : AppColors.divider),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.primaryAccent : AppColors.textDisabled,
          fontSize: 12,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        children: [
          Expanded(child: Text('JOB ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(flex: 2, child: Text('USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('PLATFORM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('ACTION', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
        ],
      ),
    );
  }

  Widget _buildJobRow(QueueJob job) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(job.id, style: const TextStyle(fontFamily: 'Courier', fontSize: 12))),
          Expanded(flex: 2, child: Text(job.user)),
          Expanded(
            child: Row(
              children: [
                Icon(_getPlatformIcon(job.platform), size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(job.platform, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(child: _buildStatusBadge(job.status)),
          Expanded(child: Text(job.time, style: const TextStyle(fontSize: 12, color: AppColors.textDisabled))),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.eye, size: 16),
                  onPressed: () => _showJobDetails(job),
                ),
                if (job.status == 'Failed')
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.primaryAccent),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String p) {
    if (p == 'Facebook') return LucideIcons.facebook;
    if (p == 'Instagram') return LucideIcons.instagram;
    if (p == 'YouTube') return LucideIcons.youtube;
    if (p == 'TikTok') return LucideIcons.video;
    return LucideIcons.messageCircle;
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.textDisabled;
    if (status == 'Completed') color = AppColors.success;
    if (status == 'Processing') color = AppColors.secondaryAccent;
    if (status == 'Failed') color = AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showJobDetails(QueueJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Job Details: ${job.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('User', job.user),
            _detailRow('Platform', job.platform),
            _detailRow('Status', job.status),
            if (job.error != null) _detailRow('Error', job.error!, isError: true),
            const SizedBox(height: 16),
            const Text('Payload:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '{\n  "caption": "Hello World",\n  "platforms": ["Facebook"],\n  "scheduler_id": "null"\n}',
                style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.greenAccent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: isError ? AppColors.error : null)),
        ],
      ),
    );
  }
}
