import 'dart:async';

class AdminApiService {
  // Simulated database for users
  final List<AdminUser> _mockUsers = [
    AdminUser(id: '1', name: 'Alex Creator', email: 'alex@example.com', plan: 'Gold', credits: 1200, status: 'Active', joinDate: '2026-01-15'),
    AdminUser(id: '2', name: 'Sarah Smith', email: 'sarah@example.com', plan: 'Silver', credits: 200, status: 'Active', joinDate: '2026-02-10'),
    AdminUser(id: '3', name: 'John Doe', email: 'john@example.com', plan: 'Gen Z', credits: 30, status: 'Suspended', joinDate: '2026-03-01'),
    AdminUser(id: '4', name: 'Crypto Guru', email: 'guru@crypto.io', plan: 'Bitcoin', credits: 5000, status: 'Active', joinDate: '2026-02-28'),
  ];

  // Fetch all users
  Future<List<AdminUser>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockUsers);
  }

  // Update user credits
  Future<bool> updateUserCredits(String userId, int newBalance) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _mockUsers[index] = _mockUsers[index].copyWith(credits: newBalance);
      return true;
    }
    return false;
  }

  // Suspend/Unsuspend user
  Future<bool> updateUserStatus(String userId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _mockUsers[index] = _mockUsers[index].copyWith(status: status);
      return true;
    }
    return false;
  }

  // System Metrics
  Future<Map<String, dynamic>> getSystemMetrics() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'totalUsers': '1,284',
      'dailyPosts': '452',
      'activeNow': '89',
      'revenue': '\$12,450',
      'errorRate': '0.02%',
    };
  }

  // Subscription Plans
  Future<List<SubscriptionPlan>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SubscriptionPlan(name: 'GEN Z', price: '0', limit: '30 Credits/Mo', icon: 'user'),
      SubscriptionPlan(name: 'SILVER', price: '19', limit: '200 Credits/Mo', icon: 'award'),
      SubscriptionPlan(name: 'OIL', price: '49', limit: '600 Credits/Mo', icon: 'flame'),
      SubscriptionPlan(name: 'GOLD', price: '99', limit: 'Unlimited', icon: 'star'),
    ];
  }

  // Queue Jobs
  Future<List<QueueJob>> getQueueJobs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      QueueJob(id: 'JOB-882', user: 'Alex Creator', platform: 'Facebook', status: 'Processing', time: '2 mins ago'),
      QueueJob(id: 'JOB-881', user: 'Sarah Smith', platform: 'Instagram', status: 'Completed', time: '5 mins ago'),
      QueueJob(id: 'JOB-880', user: 'John Doe', platform: 'YouTube', status: 'Failed', time: '12 mins ago', error: 'API Timeout'),
    ];
  }
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String plan;
  final int credits;
  final String status;
  final String joinDate;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.credits,
    required this.status,
    required this.joinDate,
  });

  AdminUser copyWith({int? credits, String? status}) {
    return AdminUser(
      id: id,
      name: name,
      email: email,
      plan: plan,
      credits: credits ?? this.credits,
      status: status ?? this.status,
      joinDate: joinDate,
    );
  }
}

class SubscriptionPlan {
  final String name;
  final String price;
  final String limit;
  final String icon;

  SubscriptionPlan({required this.name, required this.price, required this.limit, required this.icon});
}

class QueueJob {
  final String id;
  final String user;
  final String platform;
  final String status;
  final String time;
  final String? error;

  QueueJob({required this.id, required this.user, required this.platform, required this.status, required this.time, this.error});
}
