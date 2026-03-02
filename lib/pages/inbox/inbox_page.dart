import '../../widgets/glass_card.dart';
import '../../widgets/shared_widgets.dart';
import '../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page 6: Inbox — Unified comments, messages, mentions from all platforms
class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _replyController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.neonCyan),
            onPressed: () => ref.read(inboxProvider.notifier).refresh(),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(fontSize: 12, color: AppColors.neonCyan),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${items.length})'),
            Tab(text: 'Comments (${items.length})'), // Filter indices omitted for brevity in mock data
            Tab(text: 'Likes (0)'),
            Tab(text: 'Mentions (0)'),
          ],
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(inboxProvider.notifier).refresh(),
              color: AppColors.neonCyan,
              backgroundColor: AppColors.cardBackground,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(items),
                  _buildList(items), // In a real app, apply where() filters
                  _buildList([]),
                  _buildList([]),
                ],
              ),
            ),
          ),

          // ── Reply Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Write reply...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.neonCyan),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.neonCyan,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.background),
                      onPressed: () {
                        _replyController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<CommentModel> items) {
    if (items.isEmpty) {
      return ListView( // Use ListView for RefreshIndicator consistency
        shrinkWrap: true,
        children: [
          const SizedBox(height: 200),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
                const SizedBox(height: 12),
                const Text('No items', style: TextStyle(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'FEED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.neonCyan,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...items.map((item) => _InboxItemCard(item: item)),
        const SizedBox(height: 80),
      ],
    );
  }
}


class _InboxItemCard extends StatelessWidget {
  final CommentModel item;
  const _InboxItemCard({required this.item});

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook': return AppColors.facebook;
      case 'twitter': return AppColors.twitter;
      case 'linkedin': return AppColors.linkedin;
      case 'instagram': return AppColors.instagram;
      case 'reddit': return AppColors.reddit;
      default: return AppColors.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pColor = _getPlatformColor(item.platform);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pColor.withOpacity(0.15),
              shape: BoxShape.circle,
              image: item.avatarUrl != null ? DecorationImage(image: NetworkImage(item.avatarUrl!)) : null,
            ),
            child: item.avatarUrl == null ? Center(
              child: Text(
                item.userName[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: pColor,
                ),
              ),
            ) : null,
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.platform.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: pColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${DateTime.now().difference(item.timestamp).inMinutes}m ago',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionChip(
                      icon: Icons.reply_rounded,
                      label: 'Reply',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.favorite_border_rounded,
                      label: 'Like',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      color: AppColors.error,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
