import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class OAuthService {
  static final OAuthService instance = OAuthService._init();
  OAuthService._init();

  final String _callbackUrlScheme = "social-sage-auth";

  // Platform specific configuration
  final Map<String, Map<String, String>> _config = {
    'linkedin': {
      'clientId': 'YOUR_LINKEDIN_CLIENT_ID',
      'authEndpoint': 'https://www.linkedin.com/oauth/v2/authorization',
      'tokenEndpoint': 'https://www.linkedin.com/oauth/v2/accessToken',
      'scope': 'r_liteprofile r_emailaddress w_member_social',
    },
    'facebook': {
      'clientId': 'YOUR_FACEBOOK_CLIENT_ID',
      'authEndpoint': 'https://www.facebook.com/v18.0/dialog/oauth',
      'tokenEndpoint': 'https://graph.facebook.com/v18.0/oauth/access_token',
      'scope': 'public_profile,email,publish_video,instagram_basic,instagram_content_publish',
    },
    'twitter': {
      'clientId': 'YOUR_TWITTER_CLIENT_ID',
      'authEndpoint': 'https://twitter.com/i/oauth2/authorize',
      'tokenEndpoint': 'https://api.twitter.com/2/oauth2/token',
      'scope': 'tweet.read tweet.write users.read offline.access',
    },
    'instagram': {
      'clientId': 'YOUR_INSTAGRAM_CLIENT_ID',
      'authEndpoint': 'https://api.instagram.com/oauth/authorize',
      'tokenEndpoint': 'https://api.instagram.com/oauth/access_token',
      'scope': 'instagram_basic,instagram_content_publish',
    },
    'tiktok': {
      'clientId': 'YOUR_TIKTOK_CLIENT_ID',
      'authEndpoint': 'https://www.tiktok.com/auth/authorize/',
      'tokenEndpoint': 'https://open.tiktokapis.com/v2/oauth/token/',
      'scope': 'user.info.basic,video.publish,video.upload',
    },
    'youtube': {
      'clientId': 'YOUR_YOUTUBE_CLIENT_ID',
      'authEndpoint': 'https://accounts.google.com/o/oauth2/v2/auth',
      'tokenEndpoint': 'https://oauth2.googleapis.com/token',
      'scope': 'https://www.googleapis.com/auth/youtube.upload https://www.googleapis.com/auth/youtube.readonly',
    },
    'pinterest': {
      'clientId': 'YOUR_PINTEREST_CLIENT_ID',
      'authEndpoint': 'https://www.pinterest.com/oauth/',
      'tokenEndpoint': 'https://api.pinterest.com/v5/oauth/token',
      'scope': 'boards:read pins:read pins:write',
    },
    'reddit': {
      'clientId': 'YOUR_REDDIT_CLIENT_ID',
      'authEndpoint': 'https://www.reddit.com/api/v1/authorize',
      'tokenEndpoint': 'https://www.reddit.com/api/v1/access_token',
      'scope': 'identity submit read',
    },
    'discord': {
      'clientId': 'YOUR_DISCORD_CLIENT_ID',
      'authEndpoint': 'https://discord.com/api/oauth2/authorize',
      'tokenEndpoint': 'https://discord.com/api/oauth2/token',
      'scope': 'identify messages.read guilds',
    },
    'snapchat': {
      'clientId': 'YOUR_SNAPCHAT_CLIENT_ID',
      'authEndpoint': 'https://accounts.snapchat.com/accounts/oauth2/auth',
      'tokenEndpoint': 'https://accounts.snapchat.com/accounts/oauth2/token',
      'scope': 'https://auth.snapchat.com/oauth2/api/user.display_name',
    },
    'telegram': {
      'clientId': 'YOUR_TELEGRAM_BOT_TOKEN', // Telegram uses Bot Token usually
      'authEndpoint': 'https://oauth.telegram.org/auth',
      'tokenEndpoint': 'https://api.telegram.org/bot', 
      'scope': 'callback',
    },
    'whatsapp': {
      'clientId': 'YOUR_WHATSAPP_CLIENT_ID',
      'authEndpoint': 'https://www.facebook.com/v18.0/dialog/oauth',
      'tokenEndpoint': 'https://graph.facebook.com/v18.0/oauth/access_token',
      'scope': 'whatsapp_business_management,whatsapp_business_messaging',
    },
    'wechat': {
      'clientId': 'YOUR_WECHAT_CLIENT_ID',
      'authEndpoint': 'https://open.weixin.qq.com/connect/oauth2/authorize',
      'tokenEndpoint': 'https://api.weixin.qq.com/sns/oauth2/access_token',
      'scope': 'snsapi_userinfo',
    },
  };

  /// Main entry point to start authentication for a platform
  Future<Map<String, String>?> authenticate(String platform) async {
    final conf = _config[platform];
    if (conf == null) throw Exception("Configuration not found for $platform");

    final state = _generateRandomString(32);
    
    // 1. Build Authorization URL
    final authUrl = Uri.parse(conf['authEndpoint']!).replace(queryParameters: {
      'response_type': 'code',
      'client_id': conf['clientId'],
      'redirect_uri': "$_callbackUrlScheme://callback",
      'state': state,
      'scope': conf['scope'],
    });

    try {
      // 2. Launch Web Auth
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: _callbackUrlScheme,
      );

      // 3. Extract code from callback
      final callbackUri = Uri.parse(result);
      final code = callbackUri.queryParameters['code'];
      final returnedState = callbackUri.queryParameters['state'];

      if (returnedState != state) throw Exception("Invalid state returned");
      if (code == null) throw Exception("No authorization code returned");

      // 4. Exchange code for token
      return await _exchangeCodeForToken(platform, code);
    } catch (e) {
      print("Auth Error: $e");
      return null;
    }
  }

  Future<Map<String, String>> _exchangeCodeForToken(String platform, String code) async {
    final conf = _config[platform]!;
    
    final response = await http.post(
      Uri.parse(conf['tokenEndpoint']!),
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': conf['clientId'],
        'client_secret': 'YOUR_CLIENT_SECRET', // Should ideally be handled via a proxy or injected securely
        'redirect_uri': "$_callbackUrlScheme://callback",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'access_token': data['access_token'] as String,
        'refresh_token': (data['refresh_token'] ?? '') as String,
        'expires_in': (data['expires_in'] ?? 0).toString(),
      };
    } else {
      throw Exception("Failed to exchange token: ${response.body}");
    }
  }

  String _generateRandomString(int length) {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(length, (_) => random.nextInt(256)));
  }
}
