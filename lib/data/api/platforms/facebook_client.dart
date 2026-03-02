import '../base_client.dart';

class FacebookClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://graph.facebook.com/v18.0";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // 1. Post to user feed (requires publish_actions or similar)
      // For Page posting, you'd use /page_id/feed
      final body = {
        'message': text,
      };

      final response = await post(accountId, "/me/feed", body);
      return response.statusCode == 200;
    } catch (e) {
      print("Facebook Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    // Simulated fetch from /me/comments
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      CommentModel(
        id: 'fb_c1',
        postId: 'p1',
        userName: 'John Doe',
        avatarUrl: 'https://i.pravatar.cc/150?u=fb1',
        content: 'Love this update! 🚀',
        platform: 'facebook',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    // Simulated fetch from /me/insights
    await Future.delayed(const Duration(milliseconds: 400));
    return AnalyticsData(
      likes: 1240,
      shares: 450,
      comments: 89,
      views: 12000,
      platform: 'facebook',
      date: DateTime.now(),
    );
  }
}
