import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// StorageService — wraps SharedPreferences for all app persistence
class StorageService {
  static SharedPreferences? _prefs;

  // ── Keys ──
  static const _kUserKey = 'user_profile';
  static const _kSetupDone = 'setup_complete';
  static const _kPosts = 'posts';
  static const _kDrafts = 'drafts';
  static const _kScheduled = 'scheduled_posts';
  static const _kMedia = 'media_items';
  static const _kPlatforms = 'platform_accounts';
  static const _kSettings = 'app_settings';
  static const _kLastPost = 'last_post_time';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // ── Setup ──────────────────────────────────────────────────── //
  static bool get isSetupComplete => _p.getBool(_kSetupDone) ?? false;
  static Future<void> markSetupComplete() => _p.setBool(_kSetupDone, true);

  // ── User ───────────────────────────────────────────────────── //
  static Map<String, dynamic>? getUserMap() {
    final json = _p.getString(_kUserKey);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  static Future<void> saveUser({
    required String id,
    required String username,
    String? email,
    String? passwordHash,
    bool biometricEnabled = false,
    String? securityMethod,
  }) async {
    await _p.setString(_kUserKey, jsonEncode({
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'biometricEnabled': biometricEnabled,
      'securityMethod': securityMethod,
      'createdAt': DateTime.now().toIso8601String(),
    }));
  }

  static Future<void> updateUser({String? username, String? email}) async {
    final map = getUserMap() ?? {};
    if (username != null) map['username'] = username;
    if (email != null) map['email'] = email;
    await _p.setString(_kUserKey, jsonEncode(map));
  }

  // ── Posts ──────────────────────────────────────────────────── //
  static List<Map<String, dynamic>> getPosts() {
    final json = _p.getString(_kPosts);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> savePosts(List<PostModel> posts) async {
    await _p.setString(_kPosts, jsonEncode(posts.map(_postToMap).toList()));
  }

  static List<Map<String, dynamic>> getDrafts() {
    final json = _p.getString(_kDrafts);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveDrafts(List<PostModel> drafts) async {
    await _p.setString(_kDrafts, jsonEncode(drafts.map(_postToMap).toList()));
  }

  static Map<String, dynamic> _postToMap(PostModel p) => {
    'id': p.id,
    'userId': p.userId,
    'title': p.title,
    'description': p.description,
    'hashtags': p.hashtags,
    'mediaIds': p.mediaIds,
    'selectedPlatforms': p.selectedPlatforms,
    'isDraft': p.isDraft,
    'createdAt': p.createdAt.toIso8601String(),
    'updatedAt': p.updatedAt?.toIso8601String(),
  };

  static PostModel postFromMap(Map<String, dynamic> m) => PostModel(
    id: m['id'] as String,
    userId: m['userId'] as String,
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    hashtags: (m['hashtags'] as List?)?.cast<String>() ?? [],
    mediaIds: (m['mediaIds'] as List?)?.cast<String>() ?? [],
    selectedPlatforms: (m['selectedPlatforms'] as List?)?.cast<String>() ?? [],
    isDraft: m['isDraft'] as bool? ?? false,
    createdAt: DateTime.parse(m['createdAt'] as String),
    updatedAt: m['updatedAt'] != null ? DateTime.parse(m['updatedAt'] as String) : null,
  );

  // ── Scheduled Posts ────────────────────────────────────────── //
  static List<Map<String, dynamic>> getScheduled() {
    final json = _p.getString(_kScheduled);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveScheduled(List<ScheduledPost> items) async {
    await _p.setString(_kScheduled, jsonEncode(items.map((s) => {
      'id': s.id,
      'postId': s.postId,
      'title': s.title,
      'description': s.description,
      'platforms': s.platforms,
      'scheduledTime': s.scheduledTime.toIso8601String(),
      'isPosted': s.isPosted,
    }).toList()));
  }

  static ScheduledPost scheduledFromMap(Map<String, dynamic> m) => ScheduledPost(
    id: m['id'] as String,
    postId: m['postId'] as String,
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    platforms: (m['platforms'] as List?)?.cast<String>() ?? [],
    scheduledTime: DateTime.parse(m['scheduledTime'] as String),
    isPosted: m['isPosted'] as bool? ?? false,
  );

  // ── Media ──────────────────────────────────────────────────── //
  static List<Map<String, dynamic>> getMedia() {
    final json = _p.getString(_kMedia);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveMedia(List<MediaItem> items) async {
    await _p.setString(_kMedia, jsonEncode(items.map((m) => {
      'id': m.id,
      'userId': m.userId,
      'filePath': m.filePath,
      'mediaType': m.mediaType.name,
      'tags': m.tags,
      'createdAt': m.createdAt.toIso8601String(),
    }).toList()));
  }

  static MediaItem mediaFromMap(Map<String, dynamic> m) => MediaItem(
    id: m['id'] as String,
    userId: m['userId'] as String,
    filePath: m['filePath'] as String,
    mediaType: MediaType.values.firstWhere((e) => e.name == m['mediaType']),
    tags: (m['tags'] as List?)?.cast<String>() ?? [],
    createdAt: DateTime.parse(m['createdAt'] as String),
  );

  // ── Platform Accounts ──────────────────────────────────────── //
  static List<String> getConnectedPlatforms() {
    return _p.getStringList(_kPlatforms) ?? [];
  }

  static Future<void> saveConnectedPlatforms(List<String> ids) async {
    await _p.setStringList(_kPlatforms, ids);
  }

  // ── Settings ───────────────────────────────────────────────── //
  static Map<String, dynamic> getSettings() {
    final json = _p.getString(_kSettings);
    if (json == null) return {'aiSuggestions': true, 'notifications': true, 'darkMode': true};
    return jsonDecode(json) as Map<String, dynamic>;
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _p.setString(_kSettings, jsonEncode(settings));
  }

  // ── Cooldown ───────────────────────────────────────────────── //
  static DateTime? getLastPostTime() {
    final s = _p.getString(_kLastPost);
    return s != null ? DateTime.parse(s) : null;
  }

  static Future<void> saveLastPostTime(DateTime t) async {
    await _p.setString(_kLastPost, t.toIso8601String());
  }

  // ── Clear All ──────────────────────────────────────────────── //
  static Future<void> clearAll() async {
    await _p.clear();
  }
}
