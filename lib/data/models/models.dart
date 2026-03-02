import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'security_method': securityMethod,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_sync': lastSync?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      securityMethod: map['security_method'],
      biometricEnabled: map['biometric_enabled'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastSync: map['last_sync'] != null ? DateTime.parse(map['last_sync']) : null,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'platform_name': platformName,
      'platform_user_id': platformUserId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  factory PlatformAccount.fromMap(Map<String, dynamic> map) {
    return PlatformAccount(
      id: map['id'],
      userId: map['user_id'],
      platformName: map['platform_name'],
      platformUserId: map['platform_user_id'],
      accessToken: map['access_token'],
      refreshToken: map['refresh_token'],
      isEnabled: map['is_enabled'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'hashtags': jsonEncode(hashtags),
      'media_ids': jsonEncode(mediaIds),
      'selected_platforms': jsonEncode(selectedPlatforms),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_draft': isDraft ? 1 : 0,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      hashtags: List<String>.from(jsonDecode(map['hashtags'])),
      mediaIds: List<String>.from(jsonDecode(map['media_ids'])),
      selectedPlatforms: List<String>.from(jsonDecode(map['selected_platforms'])),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isDraft: map['is_draft'] == 1,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'account_id': accountId,
      'platform_name': platformName,
      'platform_post_id': platformPostId,
      'posted_at': postedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory PublishedPost.fromMap(Map<String, dynamic> map) {
    return PublishedPost(
      id: map['id'],
      postId: map['post_id'],
      accountId: map['account_id'],
      platformName: map['platform_name'],
      platformPostId: map['platform_post_id'],
      postedAt: DateTime.parse(map['posted_at']),
      status: PostStatus.values.byName(map['status']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'title': title,
      'description': description,
      'platforms': jsonEncode(platforms),
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_posted': isPosted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScheduledPost.fromMap(Map<String, dynamic> map) {
    return ScheduledPost(
      id: map['id'],
      postId: map['post_id'],
      title: map['title'],
      description: map['description'],
      platforms: List<String>.from(jsonDecode(map['platforms'])),
      scheduledTime: DateTime.parse(map['scheduled_time']),
      isPosted: map['is_posted'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'file_path': filePath,
      'media_type': mediaType.name,
      'file_size': fileSize,
      'duration_ms': duration?.inMilliseconds,
      'created_at': createdAt.toIso8601String(),
      'tags': jsonEncode(tags),
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'],
      userId: map['user_id'],
      filePath: map['file_path'],
      mediaType: MediaType.values.byName(map['media_type']),
      fileSize: map['file_size'],
      duration: map['duration_ms'] != null ? Duration(milliseconds: map['duration_ms']) : null,
      createdAt: DateTime.parse(map['created_at']),
      tags: List<String>.from(jsonDecode(map['tags'])),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'published_post_id': publishedPostId,
      'account_id': accountId,
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AnalyticsData.fromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      id: map['id'],
      publishedPostId: map['published_post_id'],
      accountId: map['account_id'],
      views: map['views'],
      likes: map['likes'],
      comments: map['comments'],
      shares: map['shares'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'published_post_id': publishedPostId,
      'account_id': accountId,
      'platform_name': platformName,
      'commenter_name': commenterName,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      publishedPostId: map['published_post_id'],
      accountId: map['account_id'],
      platformName: map['platform_name'],
      commenterName: map['commenter_name'],
      commentText: map['comment_text'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      userId: map['user_id'],
      type: NotificationType.values.byName(map['type']),
      message: map['message'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'details': details != null ? jsonEncode(details) : null,
    };
  }

  factory SecurityLog.fromMap(Map<String, dynamic> map) {
    return SecurityLog(
      id: map['id'],
      userId: map['user_id'],
      action: map['action'],
      timestamp: DateTime.parse(map['timestamp']),
      details: map['details'] != null ? jsonDecode(map['details']) : null,
    );
  }
}
