import '../base_client.dart';

class TikTokClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://open.tiktokapis.com/v2";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // TikTok direct post API structure
      final body = {
        'title': text,
        'source_info': {
          'source': 'FILE_UPLOAD',
          'video_size': 0, // Should be actual size
        }
      };

      final response = await post(accountId, "/video/publish", body);
      return response.statusCode == 200;
    } catch (e) {
      print("TikTok Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      CommentModel(
        id: 'tt_c1',
        postId: 'p5',
        userName: 'DanceKing',
        avatarUrl: 'https://i.pravatar.cc/150?u=tt1',
        content: 'This is going viral for sure! 🔥',
        platform: 'tiktok',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return AnalyticsData(
      likes: 15000,
      shares: 4500,
      comments: 890,
      views: 245000,
      platform: 'tiktok',
      date: DateTime.now(),
    );
  }
}
