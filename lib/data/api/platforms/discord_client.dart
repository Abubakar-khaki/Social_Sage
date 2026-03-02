import '../base_client.dart';

class DiscordClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://discord.com/api/v10";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // Discord /channels/{channel.id}/messages endpoint
      const channelId = "YOUR_CHANNEL_ID";
      final body = {
        "content": text,
        "tts": false,
      };

      final response = await post(accountId, "/channels/$channelId/messages", body);
      return response.statusCode == 200;
    } catch (e) {
      print("Discord Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      CommentModel(
        id: 'ds_c1',
        postId: 'p8',
        userName: 'GamerGuy',
        avatarUrl: 'https://i.pravatar.cc/150?u=ds1',
        content: '@everyone Check this out!',
        platform: 'discord',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return AnalyticsData(
      likes: 0,
      shares: 0,
      comments: 12,
      views: 450,
      platform: 'discord',
      date: DateTime.now(),
    );
  }
}
