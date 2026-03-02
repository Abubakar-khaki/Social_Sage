import 'package:workmanager/workmanager.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    // 1. Fetch posts due for scheduling
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'scheduled_posts',
      where: 'scheduled_time <= ? AND is_posted = 0',
      whereArgs: [now],
    );

    if (maps.isEmpty) return true;

    final scheduledPosts = maps.map((m) => ScheduledPost.fromMap(m)).toList();

    for (var scheduled in scheduledPosts) {
      // 2. Simulate platform posting logic
      // In a real app, you'd iterate over scheduled.platforms and call the respective APIs here.
      
      // 3. Update status in DB
      await db.update(
        'scheduled_posts',
        {'is_posted': 1},
        where: 'id = ?',
        whereArgs: [scheduled.id],
      );

      // 4. Create a published post record
      for (var platform in scheduled.platforms) {
        final published = PublishedPost(
          id: 'pub_${DateTime.now().millisecondsSinceEpoch}_$platform',
          postId: scheduled.postId,
          accountId: 'unknown', // Would be matched in a real scenario
          platformName: platform,
          status: PostStatus.success,
        );
        await db.insert('published_posts', published.toMap());
      }

      // 5. Notify the user
      await NotificationService.instance.showNotification(
        id: scheduled.id.hashCode,
        title: 'Post Published! 🚀',
        body: 'Your scheduled post "${scheduled.title}" is now live on ${scheduled.platforms.join(", ")}.',
      );
    }

    return true;
  });
}

class SchedulerWorker {
  static final SchedulerWorker instance = SchedulerWorker._init();
  SchedulerWorker._init();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false for production
    );
  }

  Future<void> scheduleBackgroundCheck() async {
    await Workmanager().registerPeriodicTask(
      "social_sage_post_check",
      "postCheckTask",
      frequency: const Duration(minutes: 15), // Minimum allowed for periodic tasks
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  Future<void> scheduleOneOffCheck(Duration delay) async {
    await Workmanager().registerOneOffTask(
      "oneoff_${DateTime.now().millisecondsSinceEpoch}",
      "postCheckTask",
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
