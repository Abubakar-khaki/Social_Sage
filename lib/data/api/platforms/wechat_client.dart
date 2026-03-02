import '../base_client.dart';

class WeChatClient extends BaseSocialClient {
  @override
  String get baseUrl => "https://api.weixin.qq.com";

  @override
  Future<bool> postContent({
    required String accountId,
    required String text,
    List<String>? mediaPaths,
  }) async {
    try {
      // WeChat Official Accounts API /cgi-bin/message/custom/send
      final body = {
        "touser": "OPENID",
        "msgtype": "text",
        "text": {"content": text}
      };

      final response = await post(accountId, "/cgi-bin/message/custom/send", body);
      return response.statusCode == 200;
    } catch (e) {
      print("WeChat Post Error: $e");
      return false;
    }
  }

  @override
  Future<List<CommentModel>> fetchComments(String accountId) async {
    return [];
  }

  @override
  Future<AnalyticsData> fetchMetrics(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return AnalyticsData(
      likes: 890,
      shares: 230,
      comments: 0,
      views: 15600,
      platform: 'wechat',
      date: DateTime.now(),
    );
  }
}
