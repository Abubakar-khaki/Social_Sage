/// Social Sage Data Models (v2 — full persistence support)

// ── User Model ──
class UserModel {
  final String id;
  String username;
  String? email;
  String? passwordHash;
  String? securityMethod;
  bool biometricEnabled;
  DateTime createdAt;
  DateTime? lastSync;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.passwordHash,
    this.securityMethod,
    this.biometricEnabled = false,
    DateTime? createdAt,
    this.lastSync,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ── Platform Account ──
class PlatformAccount {
  final String id;
  final String userId;
  final String platformName;
  String? platformUserId;
  String? accessToken;
  String? refreshToken;
  bool isEnabled;
  DateTime createdAt;
  DateTime? expiresAt;

  PlatformAccount({
    required this.id,
    required this.userId,
    required this.platformName,
    this.platformUserId,
    this.accessToken,
    this.refreshToken,
    this.isEnabled = true,
    DateTime? createdAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isConnected => accessToken != null && accessToken!.isNotEmpty;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

// ── Post Model ──
class PostModel {
  final String id;
  final String userId;
  String title;
  String description;
  List<String> hashtags;
  List<String> mediaIds;
  List<String> selectedPlatforms;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isDraft;

  PostModel({
    required this.id,
    required this.userId,
    this.title = '',
    this.description = '',
    List<String>? hashtags,
    List<String>? mediaIds,
    List<String>? selectedPlatforms,
    DateTime? createdAt,
    this.updatedAt,
    this.isDraft = true,
  })  : hashtags = hashtags ?? [],
        mediaIds = mediaIds ?? [],
        selectedPlatforms = selectedPlatforms ?? [],
        createdAt = createdAt ?? DateTime.now();
}

// ── Published Post ──
class PublishedPost {
  final String id;
  final String postId;
  final String accountId;
  final String platformName;
  String? platformPostId;
  DateTime postedAt;
  PostStatus status;

  PublishedPost({
    required this.id,
    required this.postId,
    required this.accountId,
    required this.platformName,
    this.platformPostId,
    DateTime? postedAt,
    this.status = PostStatus.pending,
  }) : postedAt = postedAt ?? DateTime.now();
}

enum PostStatus { pending, success, failed }

// ── Scheduled Post ──
class ScheduledPost {
  final String id;
  final String postId;
  final String title;
  final String description;
  final List<String> platforms;
  DateTime scheduledTime;
  bool isPosted;
  DateTime createdAt;

  ScheduledPost({
    required this.id,
    required this.postId,
    this.title = '',
    this.description = '',
    List<String>? platforms,
    required this.scheduledTime,
    this.isPosted = false,
    DateTime? createdAt,
  })  : platforms = platforms ?? [],
        createdAt = createdAt ?? DateTime.now();
}

// ── Media Item ──
class MediaItem {
  final String id;
  final String userId;
  final String filePath;
  final MediaType mediaType;
  int? fileSize;
  Duration? duration;
  DateTime createdAt;
  List<String> tags;

  MediaItem({
    required this.id,
    required this.userId,
    required this.filePath,
    required this.mediaType,
    this.fileSize,
    this.duration,
    DateTime? createdAt,
    List<String>? tags,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();
}

enum MediaType { photo, video, music }

// ── Analytics Data ──
class AnalyticsData {
  final String id;
  final String publishedPostId;
  final String accountId;
  int views;
  int likes;
  int comments;
  int shares;
  DateTime updatedAt;

  AnalyticsData({
    required this.id,
    required this.publishedPostId,
    required this.accountId,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

// ── Comment ──
class CommentModel {
  final String id;
  final String publishedPostId;
  final String accountId;
  final String platformName;
  final String commenterName;
  final String commentText;
  DateTime createdAt;

  CommentModel({
    required this.id,
    required this.publishedPostId,
    required this.accountId,
    required this.platformName,
    required this.commenterName,
    required this.commentText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ── Notification ──
class NotificationItem {
  final String id;
  final String userId;
  final NotificationType type;
  final String message;
  bool isRead;
  DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum NotificationType { postPublished, newComment, mention }

// ── Security Log ──
class SecurityLog {
  final String id;
  final String userId;
  final String action;
  final DateTime timestamp;
  Map<String, dynamic>? details;

  SecurityLog({
    required this.id,
    required this.userId,
    required this.action,
    DateTime? timestamp,
    this.details,
  }) : timestamp = timestamp ?? DateTime.now();
}
