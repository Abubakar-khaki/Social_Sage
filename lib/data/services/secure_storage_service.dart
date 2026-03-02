import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._init();
  static const _storage = FlutterSecureStorage();

  SecureStorageService._init();

  // ── Keys ──
  static const String _keyPasswordHash = 'user_password_hash';
  static const String _keySecurityMethod = 'security_method';
  static const String _prefixAccessToken = 'at_';
  static const String _prefixRefreshToken = 'rt_';

  // ── Password & Auth ──
  Future<void> savePasswordHash(String hash) async {
    await _storage.write(key: _keyPasswordHash, value: hash);
  }

  Future<String?> getPasswordHash() async {
    return await _storage.read(key: _keyPasswordHash);
  }

  Future<void> saveSecurityMethod(String method) async {
    await _storage.write(key: _keySecurityMethod, value: method);
  }

  Future<String?> getSecurityMethod() async {
    return await _storage.read(key: _keySecurityMethod);
  }

  // ── Platform Tokens ──
  Future<void> saveTokens({
    required String platformId,
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: '$_prefixAccessToken$platformId', value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: '$_prefixRefreshToken$platformId', value: refreshToken);
    }
  }

  Future<String?> getAccessToken(String platformId) async {
    return await _storage.read(key: '$_prefixAccessToken$platformId');
  }

  Future<String?> getRefreshToken(String platformId) async {
    return await _storage.read(key: '$_prefixRefreshToken$platformId');
  }

  Future<void> deleteTokens(String platformId) async {
    await _storage.delete(key: '$_prefixAccessToken$platformId');
    await _storage.delete(key: '$_prefixRefreshToken$platformId');
  }

  // ── Clear All ──
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
