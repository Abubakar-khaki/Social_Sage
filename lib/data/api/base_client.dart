import 'dart:convert';
import 'package:http/http.dart' as http;
export '../models/models.dart';
import '../services/secure_storage_service.dart';

abstract class BaseSocialClient {
  final SecureStorageService _secureStorage = SecureStorageService.instance;
  
  String get baseUrl;
  
  Future<Map<String, String>> _getHeaders(String accountId) async {
    final token = await _secureStorage.getAccessToken(accountId);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<http.Response> get(String accountId, String endpoint) async {
    final headers = await _getHeaders(accountId);
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _handleResponse(response, accountId, () => get(accountId, endpoint));
  }

  Future<http.Response> post(String accountId, String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders(accountId);
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'), 
      headers: headers, 
      body: json.encode(body),
    );
    return _handleResponse(response, accountId, () => post(accountId, endpoint, body));
  }

  Future<http.Response> postMultipart(
    String accountId, 
    String endpoint, 
    Map<String, String> fields, 
    List<String> filePaths,
    {String fileField = 'file'}
  ) async {
    final token = await _secureStorage.getAccessToken(accountId);
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
      ..fields.addAll(fields);

    for (var path in filePaths) {
      request.files.add(await http.MultipartFile.fromPath(fileField, path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response, accountId, () => postMultipart(accountId, endpoint, fields, filePaths, fileField: fileField));
  }

  Future<http.Response> _handleResponse(http.Response response, String accountId, Future<http.Response> Function() retry) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      // 🔄 AUTOMATIC TOKEN REFRESH
      final refreshed = await _refreshToken(accountId);
      if (refreshed) {
        return await retry();
      }
      throw Exception("Unauthorized: Session expired. Please reconnect your account.");
    } else {
      throw Exception("API Error (${response.statusCode}): ${response.body}");
    }
  }

  Future<bool> _refreshToken(String accountId) async {
    final refreshToken = await _secureStorage.getRefreshToken(accountId);
    if (refreshToken == null) return false;

    // This would be a real call to the platform's token endpoint
    // For MVP, we simulate success if a refresh token exists
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Platform specific implementation for posting a standard text/image post
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  });

  /// 📥 Fetch Comments for Unified Inbox
  Future<List<CommentModel>> fetchComments(String accountId);

  /// 📊 Fetch Metrics for Analytics
  Future<AnalyticsData> fetchMetrics(String accountId);
}
