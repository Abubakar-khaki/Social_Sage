import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shared_widgets.dart';

/// Page 6: Inbox — Unified comments, messages, mentions from all platforms
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _replyController = TextEditingController();

  final List<_InboxItem> _mockItems = [
    _InboxItem(
      name: 'John Doe',
      platform: 'Instagram',
      platformColor: AppColors.instagram,
      message: 'Great post! Love it 🔥',
      time: '2m ago',
      type: 'comment',
      isNew: true,
    ),
    _InboxItem(
      name: 'Jane Smith',
      platform: 'Twitter',
      platformColor: AppColors.twitter,
      message: 'Thanks for sharing this!',
      time: '15m ago',
      type: 'mention',
      isNew: true,
    ),
    _InboxItem(
      name: 'Tech News',
      platform: 'Facebook',
      platformColor: AppColors.facebook,
      message: 'Loved your insights on this topic!',
      time: '1h ago',
      type: 'comment',
      isNew: true,
    ),
    _InboxItem(
      name: 'Alex Chen',
      platform: 'LinkedIn',
      platformColor: AppColors.linkedin,
      message: 'Adding to my reading list 📚',
      time: '3h ago',
      type: 'comment',
      isNew: false,
    ),
    _InboxItem(
      name: 'Sarah Kim',
      platform: 'TikTok',
      platformColor: const Color(0xFFEE1D52),
      message: 'This is gold! 🏆',
      time: '5h ago',
      type: 'like',
      isNew: false,
    ),
    _InboxItem(
      name: 'Mike Ross',
      platform: 'Reddit',
      platformColor: AppColors.reddit,
      message: 'Can you explain more about this?',
      time: '8h ago',
      type: 'comment',
      isNew: false,
    ),
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        automaticallyImplyLeading: false,
        actions: [
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
            Tab(text: 'All (${_mockItems.length})'),
            Tab(text: 'Comments (${_mockItems.where((i) => i.type == "comment").length})'),
            Tab(text: 'Likes (${_mockItems.where((i) => i.type == "like").length})'),
            Tab(text: 'Mentions (${_mockItems.where((i) => i.type == "mention").length})'),
          ],
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_mockItems),
                _buildList(_mockItems.where((i) => i.type == 'comment').toList()),
                _buildList(_mockItems.where((i) => i.type == 'like').toList()),
                _buildList(_mockItems.where((i) => i.type == 'mention').toList()),
              ],
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

  Widget _buildList(List<_InboxItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text('No items', style: TextStyle(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    final newItems = items.where((i) => i.isNew).toList();
    final olderItems = items.where((i) => !i.isNew).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (newItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'NEW',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.neonCyan,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ...newItems.map((item) => _InboxItemCard(item: item)),
        ],
        if (olderItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'EARLIER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ...olderItems.map((item) => _InboxItemCard(item: item)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _InboxItem {
  final String name;
  final String platform;
  final Color platformColor;
  final String message;
  final String time;
  final String type;
  final bool isNew;

  _InboxItem({
    required this.name,
    required this.platform,
    required this.platformColor,
    required this.message,
    required this.time,
    required this.type,
    required this.isNew,
  });
}

class _InboxItemCard extends StatelessWidget {
  final _InboxItem item;
  const _InboxItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: item.isNew ? AppColors.neonCyan.withOpacity(0.2) : null,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.platformColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.name[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: item.platformColor,
                ),
              ),
            ),
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
                      item.name,
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
                        color: item.platformColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.platform,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: item.platformColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.time,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
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
          if (item.isNew)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.neonCyan,
                shape: BoxShape.circle,
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
