import '../base_client.dart';

class RedditClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://oauth.reddit.com";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // Reddit /api/submit endpoint
      final body = {
        'api_type': 'json',
        'kind': 'self',
        'sr': 'test', // Subreddit
        'title': text.split('\n').first,
        'text': text,
      };

      final response = await post(accountId, "/api/submit", body);
      return response.statusCode == 200;
    } catch (e) {
      print("Reddit Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 650));
    return [
      CommentModel(
        id: 'rd_c1',
        publishedPostId: 'p7',
        accountId: accountId,
        commenterName: 'RedditUser42',
        commenterAvatarUrl: 'https://i.pravatar.cc/150?u=rd1',
        commentText: 'Upvoted! Great points.',
        platformName: 'reddit',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 550));
    return AnalyticsData(
      id: 'rd_a1',
      accountId: accountId,
      likes: 1200, // Upvotes
      shares: 89,
      comments: 24,
      views: 8900,
      platform: 'reddit',
      date: DateTime.now(),
    );
  }
}
