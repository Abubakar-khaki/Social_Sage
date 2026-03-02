import 'dart:math';

class AIService {
  // Singleton
  static final AIService instance = AIService._();
  AIService._();

  final _tags = [
    '#socialmedia', '#contentcreator', '#viral', '#growthhacking', '#digitalmarketing',
    '#entrepreneur', '#mindset', '#success', '#motivation', '#business',
    '#tutorial', '#howto', '#tips', '#lifehacks', '#productivity', '#future'
  ];

  final _titles = [
    '🚀 The secret to {} in 2026',
    '💡 Why most people fail at {}',
    '🔥 My top 3 tips for {}',
    '🌟 Transforming your {} journey',
  ];

  Future<List<String>> suggestHashtags(String content) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API
    final random = Random();
    return List.generate(5, (_) => _tags[random.nextInt(_tags.length)]);
  }

  Future<List<String>> suggestTitles(String topic) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate API
    final random = Random();
    return List.generate(3, (_) => _titles[random.nextInt(_titles.length)].replaceFirst('{}', topic));
  }

  Future<List<String>> improveCaption(String original) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate API
    return [
      "✨ $original (Refined for better engagement)",
      "🚀 Check this out! $original",
      "💡 Pro Tip: $original #trending",
    ];
  }
}
