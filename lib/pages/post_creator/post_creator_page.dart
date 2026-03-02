import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../data/models/models.dart';
import '../../data/services/ai_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/shared_widgets.dart';

/// Page 2: Post Creator — fully functional
class PostCreatorPage extends ConsumerStatefulWidget {
  const PostCreatorPage({super.key});

  @override
  ConsumerState<PostCreatorPage> createState() => _PostCreatorPageState();
}

class _PostCreatorPageState extends ConsumerState<PostCreatorPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hashtagController = TextEditingController();
  bool _addMusic = false;
  String? _mediaPath;
  String? _mediaType; // 'photo' | 'video'
  String? _mediaId;   // PERSISTENT ID
  final List<String> _selectedPlatforms = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Only pre-select platforms that are actually connected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectedAccounts = ref.read(platformAccountsProvider);
      setState(() {
        for (var acc in connectedAccounts) {
          if (!_selectedPlatforms.contains(acc.platformName)) {
            _selectedPlatforms.add(acc.platformName);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    final picker = ImagePicker();
    final XFile? file = video
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);
    if (file != null) {
      final mediaNotifier = ref.read(mediaLibraryProvider.notifier);
      final type = video ? 'video' : 'photo';
      
      // Permanently save to app documents
      final savedItem = await mediaNotifier.addFromPicker(file.path, type);
      
      if (savedItem != null) {
        setState(() {
          _mediaPath = savedItem.filePath;
          _mediaType = type;
          _mediaId = savedItem.id;
        });
      }
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Media',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.neonCyan),
              title: const Text('Pick Photo from Gallery', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () { Navigator.pop(ctx); _pickMedia(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded, color: AppColors.neonPurple),
              title: const Text('Pick Video from Gallery', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () { Navigator.pop(ctx); _pickMedia(ImageSource.gallery, video: true); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.neonGreen),
              title: const Text('Take Photo', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () { Navigator.pop(ctx); _pickMedia(ImageSource.camera); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAiSuggestions(String field) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AiSuggestionsSheet(
        field: field,
        topic: _titleController.text.isNotEmpty ? _titleController.text : "social media",
        currentText: field == 'description' ? _descriptionController.text : '',
        onSelect: (s) {
          if (field == 'title') _titleController.text = s;
          if (field == 'description') _descriptionController.text = s;
          if (field == 'hashtags') _hashtagController.text = s;
        },
      ),
    );
  }

  Future<void> _postNow() async {
    final auth = ref.read(authProvider);
    final posts = ref.read(postsProvider.notifier);

    final post = PostModel(
      id: _uuid.v4(),
      userId: auth.user?.id ?? 'local',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hashtags: _hashtagController.text.split(' ').where((h) => h.startsWith('#')).toList(),
      selectedPlatforms: List.from(_selectedPlatforms),
      mediaIds: _mediaId != null ? [_mediaId!] : [],
      isDraft: false,
    );

    try {
      await posts.addPost(post);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 18),
                SizedBox(width: 8),
                Text('🚀 Post published to all platforms!'),
              ],
            ),
            backgroundColor: AppColors.cardBackground,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      posts.setPosting(false);
    }
  }

  Future<void> _saveDraft() async {
    final auth = ref.read(authProvider);
    final draft = PostModel(
      id: _uuid.v4(),
      userId: auth.user?.id ?? 'local',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hashtags: _hashtagController.text.split(' ').where((h) => h.startsWith('#')).toList(),
      selectedPlatforms: List.from(_selectedPlatforms),
      isDraft: true,
    );
    await ref.read(postsProvider.notifier).saveDraft(draft);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📝 Draft saved'),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSchedulePicker() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonCyan,
            onPrimary: AppColors.background,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonCyan,
            onPrimary: AppColors.background,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final scheduledTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final auth = ref.read(authProvider);
    final postId = _uuid.v4();

    // Save post
    final post = PostModel(
      id: postId,
      userId: auth.user?.id ?? 'local',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hashtags: _hashtagController.text.split(' ').where((h) => h.startsWith('#')).toList(),
      selectedPlatforms: List.from(_selectedPlatforms),
      mediaIds: _mediaId != null ? [_mediaId!] : [],
      isDraft: false,
    );
    await ref.read(postsProvider.notifier).saveDraft(post);

    // Save scheduled
    final scheduled = ScheduledPost(
      id: _uuid.v4(),
      postId: postId,
      title: post.title,
      description: post.description,
      platforms: List.from(_selectedPlatforms),
      scheduledTime: scheduledTime,
    );
    await ref.read(scheduledPostsProvider.notifier).add(scheduled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📅 Scheduled for ${_formatScheduled(scheduledTime)}'),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  String _formatScheduled(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final cooldown = postsState.cooldownRemaining;
    final hasCooldown = cooldown > Duration.zero;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Post'),
        actions: [
          TextButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Draft'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            StyledTextField(
              label: 'Title',
              hint: 'Enter a catchy title...',
              controller: _titleController,
              suffix: _AiSuggestButton(onTap: () => _showAiSuggestions('title')),
            ),
            const SizedBox(height: 20),

            // ── Description ──
            StyledTextField(
              label: 'Description',
              hint: 'Write your post content...',
              controller: _descriptionController,
              maxLines: 6,
              suffix: _AiSuggestButton(onTap: () => _showAiSuggestions('description')),
            ),
            const SizedBox(height: 20),

            // ── Hashtags ──
            StyledTextField(
              label: 'Hashtags',
              hint: '#socialmedia #content #trending',
              controller: _hashtagController,
              suffix: _AiSuggestButton(onTap: () => _showAiSuggestions('hashtags')),
            ),
            const SizedBox(height: 24),

            // ── Media Upload ──
            const Text('Media', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            GlassCard(
              onTap: _showMediaPicker,
              padding: const EdgeInsets.all(24),
              child: _mediaPath != null
                  ? Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.neonCyanSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _mediaType == 'video' ? Icons.videocam_rounded : Icons.image_rounded,
                            color: AppColors.neonCyan,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _mediaType == 'video' ? 'Video attached' : 'Photo attached',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                              ),
                              const Text('Tap to change', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() { _mediaPath = null; _mediaType = null; }),
                          child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 20),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.add_photo_alternate_rounded, size: 28, color: AppColors.neonCyan),
                        ),
                        const SizedBox(height: 12),
                        const Text('Add Photo or Video', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Text('Tap to upload from your device', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // ── Music Toggle ──
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: AppColors.neonPurple, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Music', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text('Only from your Library', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _addMusic,
                    onChanged: (v) => setState(() => _addMusic = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Platform Selection ──
            const Text('Posting to', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AppConstants.platforms.map((p) {
                final isSelected = _selectedPlatforms.contains(p.id);
                final connectedAccounts = ref.watch(platformAccountsProvider);
                final isConnected = connectedAccounts.any((acc) => acc.platformName == p.id);
                
                return GestureDetector(
                  onTap: () {
                    if (!isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please connect ${p.name} in Settings first'))
                      );
                      return;
                    }
                    setState(() {
                      if (isSelected) {
                        _selectedPlatforms.remove(p.id);
                      } else {
                        _selectedPlatforms.add(p.id);
                      }
                    });
                  },
                  child: Opacity(
                    opacity: isConnected ? 1.0 : 0.4,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? p.color.withOpacity(0.15) : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? p.color : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(p.icon, size: 14, color: isSelected ? p.color : AppColors.textTertiary),
                          const SizedBox(width: 5),
                          Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? p.color : AppColors.textTertiary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    label: hasCooldown
                        ? '⏳ ${cooldown.inMinutes}m ${cooldown.inSeconds % 60}s'
                        : 'Post Now',
                    isPrimary: true,
                    isLoading: postsState.isPosting,
                    icon: Icons.send_rounded,
                    onPressed: hasCooldown ? null : () => _postNow(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeonButton(
                    label: 'Schedule',
                    isPrimary: false,
                    icon: Icons.schedule_rounded,
                    onPressed: _showSchedulePicker,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                hasCooldown
                    ? '⏱ Cooldown active — wait ${cooldown.inMinutes}m ${cooldown.inSeconds % 60}s'
                    : '⏱ 5-minute cooldown after posting (anti-spam)',
                style: TextStyle(
                  fontSize: 11,
                  color: hasCooldown
                      ? AppColors.warning
                      : AppColors.textTertiary.withOpacity(0.7),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AiSuggestButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AiSuggestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 14, color: AppColors.gold),
            SizedBox(width: 4),
            Text('AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gold)),
          ],
        ),
      ),
    );
  }
}

class _AiSuggestionsSheet extends StatefulWidget {
  final String field;
  final String topic;
  final String currentText;
  final Function(String) onSelect;

  const _AiSuggestionsSheet({
    required this.field,
    required this.topic,
    required this.currentText,
    required this.onSelect,
  });

  @override
  State<_AiSuggestionsSheet> createState() => _AiSuggestionsSheetState();
}

class _AiSuggestionsSheetState extends State<_AiSuggestionsSheet> {
  List<String> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final ai = AIService.instance;
    List<String> res = [];
    if (widget.field == 'title') {
      res = await ai.suggestTitles(widget.topic);
    } else if (widget.field == 'description') {
      res = await ai.improveCaption(widget.currentText.isNotEmpty ? widget.currentText : "social media post");
    } else if (widget.field == 'hashtags') {
      res = await ai.suggestHashtags(widget.topic);
    }
    if (mounted) {
      setState(() {
        _suggestions = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI ${widget.field[0].toUpperCase()}${widget.field.substring(1)} Suggestions',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: Text('Consulting the Sage...', style: TextStyle(color: AppColors.textTertiary)))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        return GestureDetector(
                          onTap: () {
                            widget.onSelect(s);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiSuggestButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AiSuggestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
      onPressed: onTap,
      tooltip: 'Get AI Suggestions',
    );
  }
}
