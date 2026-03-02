import '../base_client.dart';

class YouTubeClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://www.googleapis.com/youtube/v3";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // YouTube posting requires uploading video first, then setting metadata.
      // This is a placeholder for the v3/videos/insert call.
      final body = {
        'snippet': {
          'title': text.split('\n').first,
          'description': text,
          'categoryId': '22',
        },
        'status': {
          'privacyStatus': 'public',
        },
      };

      final response = await post(accountId, "/videos", body);
      return response.statusCode == 200;
    } catch (e) {
      print("YouTube Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      CommentModel(
        id: 'yt_c1',
        postId: 'p6',
        userName: 'Subscriber #1',
        avatarUrl: 'https://i.pravatar.cc/150?u=yt1',
        content: 'First! Great video as always.',
        platform: 'youtube',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return AnalyticsData(
      likes: 3400,
      shares: 890,
      comments: 450,
      views: 56000,
      platform: 'youtube',
      date: DateTime.now(),
    );
  }
}
