import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/database/database_helper.dart';
import '../data/services/secure_storage_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/scheduler_worker.dart';
import '../data/services/oauth_service.dart';
import '../data/api/platforms/facebook_client.dart';
import '../data/api/platforms/linkedin_client.dart';
import '../data/api/platforms/twitter_client.dart';
import '../data/api/platforms/instagram_client.dart';
import '../data/api/platforms/tiktok_client.dart';
import '../data/api/platforms/youtube_client.dart';
import '../data/api/platforms/pinterest_client.dart';
import '../data/api/platforms/telegram_client.dart';
import '../data/api/platforms/whatsapp_client.dart';
import '../data/api/platforms/snapchat_client.dart';
import '../data/api/platforms/reddit_client.dart';
import '../data/api/platforms/discord_client.dart';
import '../data/api/platforms/wechat_client.dart';
import '../data/api/base_client.dart';

/// ══════════════════════════════════════════════════════════
/// Social Sage — App State Providers (Riverpod + SQLite Backend)
/// ══════════════════════════════════════════════════════════

// ── Auth State ─────────────────────────────────────────── //
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isFirstLaunch;
  final bool isLoading;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isFirstLaunch = true,
    this.isLoading = true,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isFirstLaunch,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SecureStorageService _secure = SecureStorageService.instance;

  AuthNotifier() : super(const AuthState()) {
    _load();
  }

  Future<void> _load() async {
    final db = await _db.database;
    final userMaps = await db.query('users', limit: 1);
    
    if (userMaps.isNotEmpty) {
      final user = UserModel.fromMap(userMaps.first);
      // Fetch sensitive data from secure storage
      user.passwordHash = await _secure.getPasswordHash();
      user.securityMethod = await _secure.getSecurityMethod();
      
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isFirstLaunch: false,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> completeOnboarding(String username, String securityMethod, {String? password}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      id: id,
      username: username,
      biometricEnabled: securityMethod != 'password',
    );

    // 1. Save to DB
    final db = await _db.database;
    await db.insert('users', user.toMap());

    // 2. Save sensitive data to Secure Storage
    if (password != null) {
      await _secure.savePasswordHash(password); // In real app, hash this first
    }
    await _secure.saveSecurityMethod(securityMethod);

    // 3. Mark setup complete in SharedPreferences (for router redirect)
    await StorageService.markSetupComplete();

    state = AuthState(
      user: user,
      isAuthenticated: true,
      isFirstLaunch: false,
      isLoading: false,
    );
  }

  Future<void> updateProfile({String? username, String? email}) async {
    if (state.user == null) return;
    
    final updatedUser = state.user!;
    if (username != null) updatedUser.username = username;
    if (email != null) updatedUser.email = email;

    final db = await _db.database;
    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [updatedUser.id],
    );

    state = state.copyWith(user: updatedUser);
  }

  Future<void> logout() async {
    final db = await _db.database;
    await db.delete('users');
    await db.delete('platform_accounts');
    await db.delete('posts');
    await db.delete('scheduled_posts');
    await _secure.deleteAll();
    await StorageService.clearAll();
    
    state = const AuthState(isFirstLaunch: true, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// ── Posts State ────────────────────────────────────────── //
class PostsState {
  final List<PostModel> posts;
  final List<PostModel> drafts;
  final bool isPosting;
  final bool isLoading;
  final DateTime? lastPostTime;

  const PostsState({
    this.posts = const [],
    this.drafts = const [],
    this.isPosting = false,
    this.isLoading = true,
    this.lastPostTime,
  });

  bool get canPost {
    if (lastPostTime == null) return true;
    return DateTime.now().difference(lastPostTime!) >= const Duration(minutes: 5);
  }

  Duration get cooldownRemaining {
    if (lastPostTime == null) return Duration.zero;
    final remaining = const Duration(minutes: 5) - DateTime.now().difference(lastPostTime!);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  PostsState copyWith({
    List<PostModel>? posts,
    List<PostModel>? drafts,
    bool? isPosting,
    bool? isLoading,
    DateTime? lastPostTime,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      drafts: drafts ?? this.drafts,
      isPosting: isPosting ?? this.isPosting,
      isLoading: isLoading ?? this.isLoading,
      lastPostTime: lastPostTime ?? this.lastPostTime,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Ref _ref;

  // Platform client registry (All 13 MVP Platforms)
  final Map<String, BaseSocialClient> _clients = {
    'facebook': FacebookClient(),
    'instagram': InstagramClient(),
    'twitter': TwitterClient(),
    'linkedin': LinkedInClient(),
    'tiktok': TikTokClient(),
    'youtube': YouTubeClient(),
    'pinterest': PinterestClient(),
    'telegram': TelegramClient(),
    'whatsapp': WhatsAppClient(),
    'snapchat': SnapchatClient(),
    'reddit': RedditClient(),
    'discord': DiscordClient(),
    'wechat': WeChatClient(),
  };

  PostsNotifier(this._ref) : super(const PostsState()) {
    _load();
  }

  Future<void> _load() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('posts', orderBy: 'created_at DESC');
    
    final allPosts = maps.map((m) => PostModel.fromMap(m)).toList();
    final posts = allPosts.where((p) => !p.isDraft).toList();
    final drafts = allPosts.where((p) => p.isDraft).toList();
    
    final lastTimeStr = StorageService.getLastPostTime()?.toIso8601String(); 
    final lastTime = lastTimeStr != null ? DateTime.parse(lastTimeStr) : null;
    
    state = PostsState(
      posts: posts, 
      drafts: drafts, 
      lastPostTime: lastTime,
      isLoading: false,
    );
  }

  Future<void> addPost(PostModel post) async {
    if (!state.canPost) {
      throw Exception('Cooldown active. Please wait ${state.cooldownRemaining.inMinutes}m.');
    }
    
    setPosting(true);
    
    try {
      // 1. Get connected accounts
      final accounts = _ref.read(platformAccountsProvider);
      
      // 2. Filter accounts for the selected platforms for this post
      final targetAccounts = accounts.where((acc) => post.selectedPlatforms.contains(acc.platformName)).toList();
      
      if (targetAccounts.isEmpty) {
        throw Exception("No connected accounts found for the selected platforms.");
      }

      // 3. Resolve Media Paths
      final allMedia = _ref.read(mediaLibraryProvider);
      final mediaPaths = post.mediaIds
          .map((id) => allMedia.firstWhere((m) => m.id == id).filePath)
          .toList();

      // 4. Dispatch to platform clients
      final results = await Future.wait(targetAccounts.map((acc) async {
        final client = _clients[acc.platformName];
        if (client == null) {
          print("No client implemented for ${acc.platformName}");
          return false;
        }

        final text = '${post.title}\n\n${post.description}\n\n${post.hashtags.join(' ')}';

        if (mediaPaths.isNotEmpty) {
          // Use multipart for media
          final response = await client.postMultipart(
            acc.id,
            client is FacebookClient ? "/me/photos" : "/media", // Platform specific endpoints
            {'message': text, 'caption': text},
            mediaPaths,
          );
          return response.statusCode >= 200 && response.statusCode < 300;
        } else {
          // Standard text post
          return await client.postContent(
            accountId: acc.id,
            text: text,
          );
        }
      }));

      final successCount = results.where((r) => r).length;
      if (successCount == 0) {
        throw Exception("Failed to publish to any platform. Check your connection.");
      }

      // 4. Save to DB on success
      final now = DateTime.now();
      final db = await _db.database;
      await db.insert('posts', post.toMap());
      
      state = state.copyWith(
        posts: [post, ...state.posts],
        lastPostTime: now,
      );
      await StorageService.saveLastPostTime(now);
    } finally {
      setPosting(false);
    }
  }

  Future<void> saveDraft(PostModel draft) async {
    final db = await _db.database;
    await db.insert('posts', draft.toMap());
    state = state.copyWith(drafts: [draft, ...state.drafts]);
  }

  Future<void> deletePost(String id) async {
    final db = await _db.database;
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != id).toList(),
      drafts: state.drafts.where((p) => p.id != id).toList(),
    );
  }

  void setPosting(bool v) => state = state.copyWith(isPosting: v);
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) => PostsNotifier(ref));

// ── Scheduled Posts ────────────────────────────────────── //
class ScheduledNotifier extends StateNotifier<List<ScheduledPost>> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  ScheduledNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('scheduled_posts', orderBy: 'scheduled_time ASC');
    state = maps.map((m) => ScheduledPost.fromMap(m)).toList();
  }

  Future<void> add(ScheduledPost post) async {
    final db = await _db.database;
    await db.insert('scheduled_posts', post.toMap());
    state = [post, ...state]..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    
    // Register a one-off task to check for this post specifically if needed
    final delay = post.scheduledTime.difference(DateTime.now());
    if (delay > Duration.zero) {
      await SchedulerWorker.instance.scheduleOneOffCheck(delay);
    }
  }

  Future<void> remove(String id) async {
    final db = await _db.database;
    await db.delete('scheduled_posts', where: 'id = ?', whereArgs: [id]);
    state = state.where((p) => p.id != id).toList();
  }
}

final scheduledPostsProvider =
    StateNotifierProvider<ScheduledNotifier, List<ScheduledPost>>((ref) => ScheduledNotifier());

// ── Media Library ──────────────────────────────────────── //
class MediaNotifier extends StateNotifier<List<MediaItem>> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  MediaNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('media', orderBy: 'created_at DESC');
    state = maps.map((m) => MediaItem.fromMap(m)).toList();
  }

  /// PICK & SAVE: Copies file from temporary picker path to permanent app storage
  Future<MediaItem?> addFromPicker(String tempPath, MediaType type) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDir.path}/media');
      if (!await mediaDir.exists()) await mediaDir.create(recursive: true);

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(tempPath)}';
      final permanentPath = '${mediaDir.path}/$fileName';
      
      // Copy file to permanent location
      final file = File(tempPath);
      await file.copy(permanentPath);

      final item = MediaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        filePath: permanentPath,
        mediaType: type,
        createdAt: DateTime.now(),
      );

      final db = await _db.database;
      await db.insert('media', item.toMap());
      state = [item, ...state];
      return item;
    } catch (e) {
      print("Media Save Error: $e");
      return null;
    }
  }

  Future<void> add(MediaItem item) async {
    final db = await _db.database;
    await db.insert('media', item.toMap());
    state = [item, ...state];
  }

  Future<void> remove(String id) async {
    final item = state.firstWhere((m) => m.id == id);
    try {
      final file = File(item.filePath);
      if (await file.exists()) await file.delete();
    } catch (e) {
      print("Media Delete File Error: $e");
    }

    final db = await _db.database;
    await db.delete('media', where: 'id = ?', whereArgs: [id]);
    state = state.where((m) => m.id != id).toList();
  }
}

final mediaLibraryProvider =
    StateNotifierProvider<MediaNotifier, List<MediaItem>>((ref) => MediaNotifier());

// ── Platform Accounts State ────────────────────────────── //
class PlatformAccountsNotifier extends StateNotifier<List<PlatformAccount>> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SecureStorageService _secure = SecureStorageService.instance;

  PlatformAccountsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('platform_accounts');
    final accounts = maps.map((m) => PlatformAccount.fromMap(m)).toList();
    
    // Enrich with secure tokens
    for (var acc in accounts) {
      acc.accessToken = await _secure.getAccessToken(acc.id);
      acc.refreshToken = await _secure.getRefreshToken(acc.id);
    }
    
    state = accounts;
  }

  Future<void> connect(String platformName) async {
    // 1. Trigger OAuth flow
    final credentials = await OAuthService.instance.authenticate(platformName);
    
    if (credentials == null) return; // User cancelled or error

    final accessToken = credentials['access_token']!;
    final refreshToken = credentials['refresh_token'];
    
    // 2. Generate a unique ID for this connection
    final id = '${platformName}_${DateTime.now().millisecondsSinceEpoch}';
    final account = PlatformAccount(
      id: id,
      userId: 'current_user', // Simplified for MVP
      platformName: platformName,
      platformUserId: 'fetched_id', // Ideally fetched from /me during OAuth
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final db = await _db.database;
    await db.insert('platform_accounts', account.toMap());
    
    await _secure.saveTokens(
      platformId: id, 
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    state = [...state, account];
  }

  Future<void> disconnect(String id) async {
    final db = await _db.database;
    await db.delete('platform_accounts', where: 'id = ?', whereArgs: [id]);
    await _secure.deleteTokens(id);
    state = state.where((acc) => acc.id != id).toList();
  }

  bool isConnected(String platformName) => 
      state.any((acc) => acc.platformName == platformName && acc.isConnected);
}

final platformAccountsProvider =
    StateNotifierProvider<PlatformAccountsNotifier, List<PlatformAccount>>(
        (ref) => PlatformAccountsNotifier());

// ── App Settings ───────────────────────────────────────── //
class AppSettings {
  final bool aiSuggestions;
  final bool notifications;
  final bool darkMode;

  const AppSettings({
    this.aiSuggestions = true,
    this.notifications = true,
    this.darkMode = true,
  });

  AppSettings copyWith({bool? aiSuggestions, bool? notifications, bool? darkMode}) {
    return AppSettings(
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      notifications: notifications ?? this.notifications,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  void _load() {
    final m = StorageService.getSettings();
    state = AppSettings(
      aiSuggestions: m['aiSuggestions'] as bool? ?? true,
      notifications: m['notifications'] as bool? ?? true,
      darkMode: m['darkMode'] as bool? ?? true,
    );
  }

  Future<void> update({bool? aiSuggestions, bool? notifications, bool? darkMode}) async {
    state = state.copyWith(
      aiSuggestions: aiSuggestions,
      notifications: notifications,
      darkMode: darkMode,
    );
    await StorageService.saveSettings({
      'aiSuggestions': state.aiSuggestions,
      'notifications': state.notifications,
      'darkMode': state.darkMode,
    });
  }
}

final appSettingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());

// ── Analytics Notifier ──────────────────────────────────── //
class AnalyticsNotifier extends StateNotifier<List<AnalyticsData>> {
  final Ref _ref;
  final Map<String, BaseSocialClient> _clients;

  AnalyticsNotifier(this._ref, this._clients) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    final accounts = _ref.read(platformAccountsProvider);
    if (accounts.isEmpty) return;

    List<AnalyticsData> allMetrics = [];
    for (var acc in accounts) {
      final client = _clients[acc.platformName];
      if (client != null) {
        try {
          final data = await client.fetchMetrics(acc.id);
          allMetrics.add(data);
        } catch (e) {
          print("Error fetching analytics for ${acc.platformName}: $e");
        }
      }
    }
    state = allMetrics;
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, List<AnalyticsData>>((ref) {
  // We need the same clients registry used in PostsNotifier
  // For simplicity in this demo, we recreate or pass them. 
  // Ideally, they'd be their own providers.
  final clients = {
    'facebook': FacebookClient(),
    'instagram': InstagramClient(),
    'twitter': TwitterClient(),
    'linkedin': LinkedInClient(),
    'tiktok': TikTokClient(),
    'youtube': YouTubeClient(),
    'pinterest': PinterestClient(),
    'telegram': TelegramClient(),
    'whatsapp': WhatsAppClient(),
    'snapchat': SnapchatClient(),
    'reddit': RedditClient(),
    'discord': DiscordClient(),
    'wechat': WeChatClient(),
  };
  return AnalyticsNotifier(ref, clients);
});

// ── Inbox Notifier ──────────────────────────────────────── //
class InboxNotifier extends StateNotifier<List<CommentModel>> {
  final Ref _ref;
  final Map<String, BaseSocialClient> _clients;

  InboxNotifier(this._ref, this._clients) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    final accounts = _ref.read(platformAccountsProvider);
    if (accounts.isEmpty) return;

    List<CommentModel> allComments = [];
    for (var acc in accounts) {
      final client = _clients[acc.platformName];
      if (client != null) {
        try {
          final comments = await client.fetchComments(acc.id);
          allComments.addAll(comments);
        } catch (e) {
          print("Error fetching inbox for ${acc.platformName}: $e");
        }
      }
    }
    // Sort by createdAt
    allComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = allComments;
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, List<CommentModel>>((ref) {
  final clients = {
    'facebook': FacebookClient(),
    'instagram': InstagramClient(),
    'twitter': TwitterClient(),
    'linkedin': LinkedInClient(),
    'tiktok': TikTokClient(),
    'youtube': YouTubeClient(),
    'pinterest': PinterestClient(),
    'telegram': TelegramClient(),
    'whatsapp': WhatsAppClient(),
    'snapchat': SnapchatClient(),
    'reddit': RedditClient(),
    'discord': DiscordClient(),
    'wechat': WeChatClient(),
  };
  return InboxNotifier(ref, clients);
});

final notificationsProvider = StateProvider<List<NotificationItem>>((ref) => []);
