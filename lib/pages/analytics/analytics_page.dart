import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shared_widgets.dart';
import '../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';

/// Page 4: Analytics Dashboard
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    
    // Aggregation
    final totalViews = analytics.fold<int>(0, (sum, item) => sum + item.views);
    final totalLikes = analytics.fold<int>(0, (sum, item) => sum + item.likes);
    final totalComments = analytics.fold<int>(0, (sum, item) => sum + item.comments);
    final totalShares = analytics.fold<int>(0, (sum, item) => sum + item.shares);
    
    final maxViews = analytics.isEmpty ? 1 : analytics.map((e) => e.views).reduce((a, b) => a > b ? a : b);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonPink.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.neonCyan),
                  onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Last 7 Days', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Summary Cards ──
            Row(
              children: [
                _StatCard(
                  label: 'Total Views',
                  value: totalViews.toString(),
                  icon: Icons.visibility_rounded,
                  color: AppColors.neonCyan,
                  change: '+15%',
                  isPositive: true,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Total Likes',
                  value: totalLikes.toString(),
                  icon: Icons.favorite_rounded,
                  color: AppColors.neonPink,
                  change: '+5%',
                  isPositive: true,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Comments',
                  value: totalComments.toString(),
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.neonBlue,
                  change: '+2%',
                  isPositive: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Best Time to Post ──
            GlassCard(
              borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.access_time_rounded, color: AppColors.neonCyan, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Best Time to Post',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Friday 7:00 PM',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '🔥 Most Views',
                    style: TextStyle(fontSize: 12, color: AppColors.gold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Platform Breakdown ──
            const SectionHeader(title: 'Platform Breakdown'),
            if (analytics.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No platform data connected', style: TextStyle(color: AppColors.textTertiary)),
              )),
            ...analytics.map((data) => _PlatformBreakdownItem(
              name: data.platform[0].toUpperCase() + data.platform.substring(1),
              icon: _getIconForPlatform(data.platform),
              color: _getColorForPlatform(data.platform),
              views: data.views,
              likes: data.likes,
              maxViews: maxViews,
            )),

            const SizedBox(height: 24),

            // ── Engagement Chart Placeholder ──
            const SectionHeader(title: 'Engagement Trend'),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ChartBar(label: 'Mon', height: 0.3, color: AppColors.neonCyan),
                    _ChartBar(label: 'Tue', height: 0.5, color: AppColors.neonCyan),
                    _ChartBar(label: 'Wed', height: 0.4, color: AppColors.neonCyan),
                    _ChartBar(label: 'Thu', height: 0.7, color: AppColors.neonCyan),
                    _ChartBar(label: 'Fri', height: 1.0, color: AppColors.neonGreen),
                    _ChartBar(label: 'Sat', height: 0.6, color: AppColors.neonCyan),
                    _ChartBar(label: 'Sun', height: 0.45, color: AppColors.neonCyan),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── First Post Stats ──
            const SectionHeader(title: 'Your First Post'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Starting my journey..."',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Feb 1 • 👁️ 1,200 views • ❤️ 95 likes',
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
  final bool isPositive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                change,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformBreakdownItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int views;
  final int likes;
  final int maxViews;

  const _PlatformBreakdownItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.views,
    required this.likes,
    required this.maxViews,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '👁️ $views',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(
                '❤️ $likes',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: maxViews > 0 ? views / maxViews : 0,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final double height;
  final Color color;

  const _ChartBar({
    required this.label,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 120 * height,
          width: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
IconData _getIconForPlatform(String platform) {
  switch (platform.toLowerCase()) {
    case 'facebook': return Icons.facebook_rounded;
    case 'twitter': return Icons.tag_rounded;
    case 'instagram': return Icons.camera_alt_rounded;
    case 'linkedin': return Icons.work_rounded;
    case 'tiktok': return Icons.music_note_rounded;
    case 'youtube': return Icons.play_circle_fill_rounded;
    default: return Icons.share_rounded;
  }
}

Color _getColorForPlatform(String platform) {
  switch (platform.toLowerCase()) {
    case 'facebook': return AppColors.facebook;
    case 'twitter': return AppColors.twitter;
    case 'instagram': return AppColors.instagram;
    case 'linkedin': return AppColors.linkedin;
    case 'tiktok': return const Color(0xFFEE1D52);
    case 'youtube': return Colors.red;
    default: return AppColors.neonCyan;
  }
}
