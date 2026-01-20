import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/quote_model.dart';
import '../../../../data/repositories/quote_repository.dart';

part 'quote_viewmodel.g.dart';

@riverpod
class QuoteViewModel extends _$QuoteViewModel {
  int _page = 1;
  static const _limit = 10;
  bool _isLoadingMore = false;
  String _selectedCategory = 'All Quotes';
  String get selectedCategory => _selectedCategory;

  @override
  FutureOr<List<Quote>> build() {
    _page = 1;
    return _fetchQuotes(page: 1);
  }

  Future<List<Quote>> _fetchQuotes({required int page}) {
    final repository = ref.read(quoteRepositoryProvider);
    return repository.fetchQuotes(
      page: page,
      limit: _limit,
      category: _selectedCategory,
    );
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore) return;

    final currentList = state.value;
    if (currentList == null) return;

    _isLoadingMore = true;
    try {
      final newQuotes = await _fetchQuotes(page: _page + 1);
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
    state = await AsyncValue.guard(() => _fetchQuotes(page: 1));
  }

  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await refresh();
  }
}

@riverpod
Future<Quote> quoteOfTheDay(QuoteOfTheDayRef ref) {
  return ref.read(quoteRepositoryProvider).fetchQuoteOfTheDay();
}
