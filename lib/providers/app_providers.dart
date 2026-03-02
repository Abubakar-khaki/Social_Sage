import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/storage_service.dart';

/// ══════════════════════════════════════════════════════════
/// Social Sage — App State Providers (Riverpod + Persistence)
/// ══════════════════════════════════════════════════════════

// ── Auth State ─────────────────────────────────────────── //
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isFirstLaunch;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isFirstLaunch = true,
  });

  AuthState copyWith({UserModel? user, bool? isAuthenticated, bool? isFirstLaunch}) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _load();
  }

  void _load() {
    if (StorageService.isSetupComplete) {
      final map = StorageService.getUserMap();
      if (map != null) {
        final user = UserModel(
          id: map['id'] as String,
          username: map['username'] as String,
          email: map['email'] as String?,
          biometricEnabled: map['biometricEnabled'] as bool? ?? false,
          securityMethod: map['securityMethod'] as String?,
        );
        state = AuthState(user: user, isAuthenticated: true, isFirstLaunch: false);
      }
    }
  }

  Future<void> completeOnboarding(String username, String securityMethod) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await StorageService.saveUser(
      id: id,
      username: username,
      biometricEnabled: securityMethod != 'password',
      securityMethod: securityMethod,
    );
    await StorageService.markSetupComplete();
    final user = UserModel(
      id: id,
      username: username,
      biometricEnabled: securityMethod != 'password',
      securityMethod: securityMethod,
    );
    state = AuthState(user: user, isAuthenticated: true, isFirstLaunch: false);
  }

  Future<void> updateProfile({String? username, String? email}) async {
    await StorageService.updateUser(username: username, email: email);
    if (state.user != null) {
      final u = state.user!;
      u.username = username ?? u.username;
      u.email = email ?? u.email;
      state = state.copyWith(user: u);
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    state = const AuthState(isFirstLaunch: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// ── Posts State ────────────────────────────────────────── //
class PostsState {
  final List<PostModel> posts;
  final List<PostModel> drafts;
  final bool isPosting;
  final DateTime? lastPostTime;

  const PostsState({
    this.posts = const [],
    this.drafts = const [],
    this.isPosting = false,
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
    DateTime? lastPostTime,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      drafts: drafts ?? this.drafts,
      isPosting: isPosting ?? this.isPosting,
      lastPostTime: lastPostTime ?? this.lastPostTime,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier() : super(const PostsState()) {
    _load();
  }

  void _load() {
    final posts = StorageService.getPosts().map(StorageService.postFromMap).toList();
    final drafts = StorageService.getDrafts().map(StorageService.postFromMap).toList();
    final lastTime = StorageService.getLastPostTime();
    state = PostsState(posts: posts, drafts: drafts, lastPostTime: lastTime);
  }

  Future<void> addPost(PostModel post) async {
    final now = DateTime.now();
    final updated = PostsState(
      posts: [post, ...state.posts],
      drafts: state.drafts,
      isPosting: false,
      lastPostTime: now,
    );
    state = updated;
    await StorageService.savePosts(state.posts);
    await StorageService.saveLastPostTime(now);
  }

  Future<void> saveDraft(PostModel draft) async {
    state = state.copyWith(drafts: [draft, ...state.drafts]);
    await StorageService.saveDrafts(state.drafts);
  }

  Future<void> deletePost(String id) async {
    state = state.copyWith(posts: state.posts.where((p) => p.id != id).toList());
    await StorageService.savePosts(state.posts);
  }

  void setPosting(bool v) => state = state.copyWith(isPosting: v);
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) => PostsNotifier());

// ── Scheduled Posts ────────────────────────────────────── //
class ScheduledNotifier extends StateNotifier<List<ScheduledPost>> {
  ScheduledNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getScheduled().map(StorageService.scheduledFromMap).toList();
  }

  Future<void> add(ScheduledPost post) async {
    state = [post, ...state];
    await StorageService.saveScheduled(state);
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await StorageService.saveScheduled(state);
  }
}

final scheduledPostsProvider =
    StateNotifierProvider<ScheduledNotifier, List<ScheduledPost>>((ref) => ScheduledNotifier());

// ── Media Library ──────────────────────────────────────── //
class MediaNotifier extends StateNotifier<List<MediaItem>> {
  MediaNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getMedia().map(StorageService.mediaFromMap).toList();
  }

  Future<void> add(MediaItem item) async {
    state = [item, ...state];
    await StorageService.saveMedia(state);
  }

  Future<void> remove(String id) async {
    state = state.where((m) => m.id != id).toList();
    await StorageService.saveMedia(state);
  }
}

final mediaLibraryProvider =
    StateNotifierProvider<MediaNotifier, List<MediaItem>>((ref) => MediaNotifier());

// ── Platform Accounts State ────────────────────────────── //
class PlatformAccountsNotifier extends StateNotifier<List<String>> {
  PlatformAccountsNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getConnectedPlatforms();
  }

  Future<void> connect(String platformId) async {
    if (!state.contains(platformId)) {
      state = [...state, platformId];
      await StorageService.saveConnectedPlatforms(state);
    }
  }

  Future<void> disconnect(String platformId) async {
    state = state.where((id) => id != platformId).toList();
    await StorageService.saveConnectedPlatforms(state);
  }

  bool isConnected(String platformId) => state.contains(platformId);
}

final platformAccountsProvider =
    StateNotifierProvider<PlatformAccountsNotifier, List<String>>(
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

// ── Inbox (Comments) — mock only ──────────────────────── //
final analyticsProvider = StateProvider<List<AnalyticsData>>((ref) => []);
final notificationsProvider = StateProvider<List<NotificationItem>>((ref) => []);
final inboxProvider = StateProvider<List<CommentModel>>((ref) => []);
