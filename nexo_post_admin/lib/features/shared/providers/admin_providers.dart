import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/admin_api_service.dart';

// Service Provider
final adminApiServiceProvider = Provider((ref) => AdminApiService());

// Users Provider
final adminUsersProvider = StateNotifierProvider<AdminUserNotifier, AsyncValue<List<AdminUser>>>((ref) {
  return AdminUserNotifier(ref.watch(adminApiServiceProvider));
});

class AdminUserNotifier extends StateNotifier<AsyncValue<List<AdminUser>>> {
  final AdminApiService _api;
  AdminUserNotifier(this._api) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _api.getUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCredits(String userId, int newCredits) async {
    try {
      final success = await _api.updateUserCredits(userId, newCredits);
      if (success) {
        state.whenData((users) {
          state = AsyncValue.data(
            users.map((u) => u.id == userId ? u.copyWith(credits: newCredits) : u).toList(),
          );
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleStatus(String userId, String currentStatus) async {
    final nextStatus = currentStatus == 'Active' ? 'Suspended' : 'Active';
    try {
      final success = await _api.updateUserStatus(userId, nextStatus);
      if (success) {
        state.whenData((users) {
          state = AsyncValue.data(
            users.map((u) => u.id == userId ? u.copyWith(status: nextStatus) : u).toList(),
          );
        });
      }
    } catch (e) {
      // Handle error
    }
  }
}

// System Metrics Provider
final systemMetricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(adminApiServiceProvider).getSystemMetrics();
});

// Plans Provider
final adminPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  return ref.watch(adminApiServiceProvider).getPlans();
});

// Queue Jobs Provider
final adminQueueJobsProvider = FutureProvider<List<QueueJob>>((ref) async {
  return ref.watch(adminApiServiceProvider).getQueueJobs();
});
