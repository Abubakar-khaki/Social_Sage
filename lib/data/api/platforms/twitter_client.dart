import '../base_client.dart';

class TwitterClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://api.twitter.com/2";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // Twitter V2 uses /tweets endpoint
      final body = {
        'text': text,
      };

      final response = await post(accountId, "/tweets", body);
      return response.statusCode == 201;
    } catch (e) {
      print("Twitter Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      CommentModel(
        id: 'tw_c1',
        publishedPostId: 'p3',
        accountId: accountId,
        commenterName: 'TechGuru',
        commenterAvatarUrl: 'https://i.pravatar.cc/150?u=tw1',
        commentText: 'RT if you agree! 💯',
        platformName: 'twitter',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AnalyticsData(
      id: 'tw_a1',
      accountId: accountId,
      likes: 2500,
      shares: 1100,
      comments: 230,
      views: 45000,
      platform: 'twitter',
      date: DateTime.now(),
    );
  }
}
