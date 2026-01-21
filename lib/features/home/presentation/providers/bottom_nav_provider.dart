import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_nav_provider.g.dart';

@Riverpod(keepAlive: true)
class BottomNavNotifier extends _$BottomNavNotifier {
  @override
  int build() {
    return 0; // Default to Home
  }

  void setIndex(int index) {
    state = index;
  }
}
