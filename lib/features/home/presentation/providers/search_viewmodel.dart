import '../../../../data/models/quote_model.dart';
import '../../../../data/repositories/quote_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_viewmodel.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  @override
  FutureOr<List<Quote>> build() {
    return [];
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(quoteRepositoryProvider).searchQuotes(query),
    );
  }

  Future<void> searchByCategory(String category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(quoteRepositoryProvider).fetchQuotes(category: category),
    );
  }
}
