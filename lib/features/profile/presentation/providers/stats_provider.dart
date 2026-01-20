import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../data/models/user_stats.dart';

part 'stats_provider.g.dart';

@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  Stream<UserStats> build() {
    final user = ref.watch(
      authStateProvider.select((value) => value.valueOrNull),
    );

    if (user == null) {
      return Stream.value(const UserStats());
    }
    return FirestoreService().getUserStats(user.uid);
  }

  Future<void> updateDailyGoal(int newGoal) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await FirestoreService().updateDailyGoal(user.uid, newGoal);
    }
  }
}
