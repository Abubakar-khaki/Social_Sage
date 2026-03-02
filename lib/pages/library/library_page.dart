import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shared_widgets.dart';

/// Page 5: Library — Photos, Videos, Music management (fully functional)
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final auth = ref.read(authProvider);
    final item = MediaItem(
      id: _uuid.v4(),
      userId: auth.user?.id ?? 'local',
      filePath: file.path,
      mediaType: MediaType.photo,
    );
    await ref.read(mediaLibraryProvider.notifier).add(item);
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    final auth = ref.read(authProvider);
    final item = MediaItem(
      id: _uuid.v4(),
      userId: auth.user?.id ?? 'local',
      filePath: file.path,
      mediaType: MediaType.video,
    );
    await ref.read(mediaLibraryProvider.notifier).add(item);
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final auth = ref.read(authProvider);
    final item = MediaItem(
      id: _uuid.v4(),
      userId: auth.user?.id ?? 'local',
      filePath: result.files.first.path ?? '',
      mediaType: MediaType.music,
    );
    await ref.read(mediaLibraryProvider.notifier).add(item);
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mediaLibraryProvider);
    final photos = media.where((m) => m.mediaType == MediaType.photo).toList();
    final videos = media.where((m) => m.mediaType == MediaType.video).toList();
    final music = media.where((m) => m.mediaType == MediaType.music).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.photo_rounded, size: 20), text: 'Photos (${photos.length})'),
            Tab(icon: const Icon(Icons.videocam_rounded, size: 20), text: 'Videos (${videos.length})'),
            Tab(icon: const Icon(Icons.music_note_rounded, size: 20), text: 'Music (${music.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PhotosTab(photos: photos, onUpload: _pickPhoto, onDelete: (id) => ref.read(mediaLibraryProvider.notifier).remove(id)),
          _VideosTab(videos: videos, onUpload: _pickVideo, onDelete: (id) => ref.read(mediaLibraryProvider.notifier).remove(id)),
          _MusicTab(music: music, onUpload: _pickMusic, onDelete: (id) => ref.read(mediaLibraryProvider.notifier).remove(id)),
        ],
      ),
    );
  }
}

// ── Photos Tab ──
class _PhotosTab extends StatelessWidget {
  final List<MediaItem> photos;
  final VoidCallback onUpload;
  final Function(String) onDelete;

  const _PhotosTab({required this.photos, required this.onUpload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return _EmptyMediaTab(
        icon: Icons.photo_library_rounded,
        title: 'No Photos Yet',
        subtitle: 'Upload photos to reuse in your posts',
        buttonLabel: 'Upload Photo',
        onUpload: onUpload,
      );
    }
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: photos.length,
            itemBuilder: (ctx, i) => _MediaTile(item: photos[i], onDelete: onDelete),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: const Text('Add Photo'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Videos Tab ──
class _VideosTab extends StatelessWidget {
  final List<MediaItem> videos;
  final VoidCallback onUpload;
  final Function(String) onDelete;

  const _VideosTab({required this.videos, required this.onUpload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return _EmptyMediaTab(
        icon: Icons.video_library_rounded,
        title: 'No Videos Yet',
        subtitle: 'Upload videos to reuse across platforms',
        buttonLabel: 'Upload Video',
        onUpload: onUpload,
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: videos.length,
            itemBuilder: (ctx, i) => _MediaListTile(item: videos[i], onDelete: onDelete),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.video_call_rounded, size: 18),
              label: const Text('Add Video'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Music Tab ──
class _MusicTab extends StatelessWidget {
  final List<MediaItem> music;
  final VoidCallback onUpload;
  final Function(String) onDelete;

  const _MusicTab({required this.music, required this.onUpload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (music.isEmpty) {
      return _EmptyMediaTab(
        icon: Icons.library_music_rounded,
        title: 'No Music Yet',
        subtitle: 'Upload your own MP3 files for TikTok/Shorts',
        buttonLabel: 'Upload Music',
        onUpload: onUpload,
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: music.length,
            itemBuilder: (ctx, i) => _MediaListTile(item: music[i], onDelete: onDelete),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.audio_file_rounded, size: 18),
              label: const Text('Add Music'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Media Tile (Grid) ──
class _MediaTile extends StatelessWidget {
  final MediaItem item;
  final Function(String) onDelete;

  const _MediaTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.image_rounded, color: AppColors.neonCyan, size: 36),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onDelete(item.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Media List Tile ──
class _MediaListTile extends StatelessWidget {
  final MediaItem item;
  final Function(String) onDelete;

  const _MediaListTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = item.filePath.split('/').last.split('\\').last;
    final icon = item.mediaType == MediaType.video
        ? Icons.videocam_rounded
        : Icons.music_note_rounded;
    final color = item.mediaType == MediaType.video
        ? AppColors.neonPurple
        : AppColors.gold;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
            onPressed: () => onDelete(item.id),
          ),
        ],
      ),
    );
  }
}

// ── Empty Media Tab ──
class _EmptyMediaTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onUpload;

  const _EmptyMediaTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neonCyanSubtle,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppColors.neonCyan.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
