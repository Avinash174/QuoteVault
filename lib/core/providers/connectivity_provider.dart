import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStatusProvider);
  return connectivity.when(
    data: (results) => results.contains(ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
});
