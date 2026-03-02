import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../widgets/platform_icon.dart';
import '../../widgets/glass_card.dart';
import '../../providers/app_providers.dart';

/// Page 1: Home / Dashboard — wired to real state
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final posts = ref.watch(postsProvider);
    final scheduled = ref.watch(scheduledPostsProvider);
    final platforms = ref.watch(platformAccountsProvider);

    final username = auth.user?.username ?? 'Sage';
    final postsToday = posts.posts
        .where((p) {
          final now = DateTime.now();
          return p.createdAt.year == now.year &&
              p.createdAt.month == now.month &&
              p.createdAt.day == now.day;
        })
        .length;

    if (auth.isLoading || posts.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$username 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _HeaderButton(
                          icon: Icons.notifications_none_rounded,
                          badge: 0,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _HeaderButton(
                          icon: Icons.bar_chart_rounded,
                          onTap: () => context.push('/analytics'),
                        ),
                        const SizedBox(width: 8),
                        _HeaderButton(
                          icon: Icons.photo_library_outlined,
                          onTap: () => context.push('/library'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Quick Stats ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    _QuickStat(
                      label: 'Posts Today',
                      value: '$postsToday',
                      icon: Icons.edit_note_rounded,
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(width: 12),
                    _QuickStat(
                      label: 'Scheduled',
                      value: '${scheduled.length}',
                      icon: Icons.schedule_rounded,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 12),
                    _QuickStat(
                      label: 'Platforms',
                      value: '${platforms.length}/13',
                      icon: Icons.link_rounded,
                      color: AppColors.neonGreen,
                    ),
                  ],
                ),
              ),
            ),

            // ── Platforms Section ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'Your Platforms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ── Platform Grid ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 16,
                    children: AppConstants.platforms.map((platform) {
                      return PlatformIcon(
                        platform: platform,
                        isConnected: platforms.any((acc) => acc.platformName == platform.id),
                        onTap: () => context.go('/settings'),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── Recent Posts ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Recent Posts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ── Posts List or Empty State ──
            if (posts.posts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.post_add_rounded,
                          size: 48,
                          color: AppColors.textTertiary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap the + button to create your first post',
                          style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/post-creator'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create Post'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts.posts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.neonCyanSubtle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.article_rounded,
                                  size: 22, color: AppColors.neonCyan),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title.isEmpty ? 'Untitled Post' : post.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    post.description.isEmpty
                                        ? 'No description'
                                        : post.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(post.createdAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (post.selectedPlatforms.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyanSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${post.selectedPlatforms.length} platforms',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.neonCyan,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: posts.posts.length > 5 ? 5 : posts.posts.length,
                ),
              ),

            // ── Drafts Section ──
            if (posts.drafts.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Drafts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final draft = posts.drafts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: GlassCard(
                        borderColor: AppColors.gold.withOpacity(0.3),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.drafts_rounded,
                                  size: 22, color: AppColors.gold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft.title.isEmpty ? 'Untitled Draft' : draft.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _formatTime(draft.createdAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'DRAFT',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: posts.drafts.length > 3 ? 3 : posts.drafts.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Header Button ──
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final int? badge;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Quick Stat Card ──
class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
