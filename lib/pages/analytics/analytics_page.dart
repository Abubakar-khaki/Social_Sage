import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shared_widgets.dart';

/// Page 4: Analytics Dashboard
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Analytics'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Last 7 Days', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Cards ──
            Row(
              children: const [
                _StatCard(
                  label: 'Total Views',
                  value: '2,450',
                  icon: Icons.visibility_rounded,
                  color: AppColors.neonCyan,
                  change: '+12%',
                  isPositive: true,
                ),
                SizedBox(width: 10),
                _StatCard(
                  label: 'Total Likes',
                  value: '340',
                  icon: Icons.favorite_rounded,
                  color: AppColors.neonPink,
                  change: '+8%',
                  isPositive: true,
                ),
                SizedBox(width: 10),
                _StatCard(
                  label: 'Comments',
                  value: '85',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.neonBlue,
                  change: '+3%',
                  isPositive: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Best Time to Post ──
            GlassCard(
              borderColor: AppColors.neonCyan.withOpacity(0.3),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.access_time_rounded, color: AppColors.neonCyan, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
            _PlatformBreakdownItem(
              name: 'Instagram',
              icon: Icons.camera_alt_rounded,
              color: AppColors.instagram,
              views: 800,
              likes: 150,
              maxViews: 800,
            ),
            _PlatformBreakdownItem(
              name: 'Twitter / X',
              icon: Icons.tag_rounded,
              color: AppColors.twitter,
              views: 600,
              likes: 120,
              maxViews: 800,
            ),
            _PlatformBreakdownItem(
              name: 'TikTok',
              icon: Icons.music_note_rounded,
              color: const Color(0xFFEE1D52),
              views: 500,
              likes: 60,
              maxViews: 800,
            ),
            _PlatformBreakdownItem(
              name: 'LinkedIn',
              icon: Icons.work_rounded,
              color: AppColors.linkedin,
              views: 400,
              likes: 10,
              maxViews: 800,
            ),
            _PlatformBreakdownItem(
              name: 'Facebook',
              icon: Icons.facebook_rounded,
              color: AppColors.facebook,
              views: 150,
              likes: 0,
              maxViews: 800,
            ),

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
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                color: (isPositive ? AppColors.success : AppColors.error).withOpacity(0.1),
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
                  color: color.withOpacity(0.12),
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
              colors: [color, color.withOpacity(0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
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
