import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/quote_model.dart';

part 'library_viewmodel.g.dart';

@riverpod
class LibraryViewModel extends _$LibraryViewModel {
  @override
  List<Quote> build() {
    return [];
  }

  void toggleFavorite(Quote quote) {
    if (state.contains(quote)) {
      state = state.where((q) => q != quote).toList();
    } else {
      state = [...state, quote];
    }
  }

  bool isFavorite(Quote quote) {
    return state.contains(quote);
  }
}
