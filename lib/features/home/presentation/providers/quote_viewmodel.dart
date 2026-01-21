import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/quote_model.dart';
import '../../../../data/repositories/quote_repository.dart';

part 'quote_viewmodel.g.dart';

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'All Quotes';

  void setCategory(String category) {
    state = category;
  }
}

@riverpod
class QuoteViewModel extends _$QuoteViewModel {
  int _page = 1;
  static const _limit = 10;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Quote>> build() async {
    _page = 1;
    // Watch the category provider to auto-refresh when it changes
    final category = ref.watch(selectedCategoryProvider);
    return _fetchQuotes(page: 1, category: category);
  }

  Future<List<Quote>> _fetchQuotes({
    required int page,
    required String category,
  }) {
    final repository = ref.read(quoteRepositoryProvider);
    return repository.fetchQuotes(
      page: page,
      limit: _limit,
      category: category,
    );
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore) return;

    final currentList = state.value;
    if (currentList == null) return;

    _isLoadingMore = true;
    try {
      final category = ref.read(selectedCategoryProvider);
      final newQuotes = await _fetchQuotes(page: _page + 1, category: category);
      if (newQuotes.isNotEmpty) {
        _page++;
        // Maintain the current state but append new items
        state = AsyncData([...currentList, ...newQuotes]);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    state = const AsyncValue.loading();
    // No need to manually fetch, forcing a rebuild will re-trigger build()
    ref.invalidateSelf();
  }
}

@riverpod
Future<Quote> quoteOfTheDay(QuoteOfTheDayRef ref) {
  return ref.read(quoteRepositoryProvider).fetchQuoteOfTheDay();
}
