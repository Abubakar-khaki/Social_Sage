import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shared_widgets.dart';

/// Page 3: Scheduler — Calendar + real scheduled post list
class SchedulerPage extends ConsumerStatefulWidget {
  const SchedulerPage({super.key});

  @override
  ConsumerState<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends ConsumerState<SchedulerPage> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final scheduledPosts = ref.watch(scheduledPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduler'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Calendar ──
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                        onPressed: () => setState(() {
                          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                        }),
                      ),
                      Text(
                        _getMonthYear(_focusedDate),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onPressed: () => setState(() {
                          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                        .map((d) => SizedBox(
                              width: 36,
                              child: Center(
                                child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(scheduledPosts.map((p) => p.scheduledTime).toList()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Scheduled Posts For Selected Day ──
            Row(
              children: [
                const SectionHeader(title: 'Scheduled Posts'),
                const Spacer(),
                Text(
                  '${scheduledPosts.length} total',
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),

            if (scheduledPosts.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 40, color: AppColors.textTertiary.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text('No scheduled posts yet', style: TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      const Text('Use the + button to schedule a post', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              )
            else
              ...scheduledPosts
                  .where((p) => _isSameDay(p.scheduledTime, _selectedDate))
                  .map((post) => _ScheduledPostCard(
                        post: post,
                        onDelete: () => ref.read(scheduledPostsProvider.notifier).remove(post.id),
                      )),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<DateTime> scheduledDates) {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    final days = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      days.add(const SizedBox(width: 36, height: 36));
    }
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final isToday = _isToday(date);
      final isSelected = _isSameDay(date, _selectedDate);
      final hasPost = scheduledDates.any((d) => _isSameDay(d, date));

      days.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.neonCyan
                  : isToday
                      ? AppColors.neonCyanSubtle
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.background
                        : isToday
                            ? AppColors.neonCyan
                            : AppColors.textSecondary,
                  ),
                ),
                if (hasPost && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: AppColors.neonCyan, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: (MediaQuery.of(context).size.width - 64 - 36 * 7) / 6,
      runSpacing: 4,
      children: days,
    );
  }

  String _getMonthYear(DateTime date) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ScheduledPostCard extends StatelessWidget {
  final dynamic post;
  final VoidCallback onDelete;

  const _ScheduledPostCard({required this.post, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neonCyanSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${post.scheduledTime.day}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.neonCyan),
                ),
                Text(
                  _getShortMonth(post.scheduledTime.month),
                  style: const TextStyle(fontSize: 10, color: AppColors.neonCyan),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.isEmpty ? 'Untitled Post' : post.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${post.scheduledTime.hour.toString().padLeft(2, '0')}:${post.scheduledTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    ...post.platforms.take(2).map(
                          (p) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyanSubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(p, style: const TextStyle(fontSize: 9, color: AppColors.neonCyan)),
                          ),
                        ),
                    if (post.platforms.length > 2)
                      Text('+${post.platforms.length - 2}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Scheduled Post'),
                  content: Text('Delete "${post.title.isEmpty ? 'Untitled' : post.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); onDelete(); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getShortMonth(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}
