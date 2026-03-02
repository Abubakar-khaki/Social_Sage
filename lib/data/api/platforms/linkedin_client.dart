import '../base_client.dart';

class LinkedInClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://api.linkedin.com/v2";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // 1. Get member URN (Profile ID) - Simplified for MVP
      // In real scenarios, you'd fetch this from /me first
      const memberUrn = "urn:li:person:YOUR_URN";

      // 2. Build UGC Post body
      final body = {
        "author": memberUrn,
        "lifecycleState": "PUBLISHED",
        "specificContent": {
          "com.linkedin.ugc.ShareContent": {
            "shareCommentary": {"text": text},
            "shareMediaCategory": mediaPaths != null && mediaPaths.isNotEmpty ? "IMAGE" : "NONE",
          }
        },
        "visibility": {"com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"}
      };

      final response = await post(accountId, "/ugcPosts", body);
      return response.statusCode == 201;
    } catch (e) {
      print("LinkedIn Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      CommentModel(
        id: 'li_c1',
        postId: 'p2',
        userName: 'Sarah Jenkins',
        avatarUrl: 'https://i.pravatar.cc/150?u=li1',
        content: 'Very insightful share, thanks!',
        platform: 'linkedin',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AnalyticsData(
      likes: 850,
      shares: 120,
      comments: 45,
      views: 5600,
      platform: 'linkedin',
      date: DateTime.now(),
    );
  }
}
