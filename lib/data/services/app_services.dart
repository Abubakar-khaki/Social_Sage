import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth Service — handles biometric and password authentication
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  /// Authenticate with biometrics (fingerprint / face)
  Future<bool> authenticateWithBiometrics() async {
    // TODO: Use local_auth package
    // final localAuth = LocalAuthentication();
    // final canAuth = await localAuth.canCheckBiometrics;
    // if (!canAuth) return false;
    // return await localAuth.authenticate(
    //   localizedReason: 'Authenticate to open Social Sage',
    // );
    return true; // Stub: always succeeds for now
  }

  /// Verify password
  Future<bool> verifyPassword(String password) async {
    // TODO: Compare with stored hash from flutter_secure_storage
    return password.isNotEmpty;
  }

  /// Save password hash
  Future<void> savePassword(String password) async {
    // TODO: Hash and save to flutter_secure_storage
  }

  /// Check if app has been set up
  Future<bool> isSetupComplete() async {
    // TODO: Check if user exists in local storage
    return false;
  }

  /// Check if biometrics are available
  Future<bool> isBiometricAvailable() async {
    // TODO: Check device biometric capabilities
    return true;
  }
}

/// Platform Posting Service Interface
abstract class PlatformPostingService {
  String get platformId;
  String get platformName;

  /// Posts content to the platform
  Future<String?> post({
    required String title,
    required String description,
    List<String>? hashtags,
    String? mediaPath,
    String? accessToken,
  });

  /// Fetches analytics for a published post
  Future<Map<String, int>> getAnalytics(String postId, String accessToken);

  /// Fetches comments/interactions
  Future<List<Map<String, dynamic>>> getComments(String postId, String accessToken);
}

/// Notification Service
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {
    // TODO: Initialize flutter_local_notifications
  }

  Future<void> showPostPublished(String platformName) async {
    // TODO: Show local notification
    // "Your post to $platformName is live!"
  }

  Future<void> showScheduledPostReminder(String postTitle, DateTime scheduledTime) async {
    // TODO: Schedule notification
  }

  Future<void> cancelAllNotifications() async {
    // TODO: Cancel all
  }
}

/// Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
