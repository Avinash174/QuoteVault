import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/quote_model.dart';
import '../../../../data/repositories/quote_repository.dart';

part 'quote_viewmodel.g.dart';

@riverpod
class QuoteViewModel extends _$QuoteViewModel {
  @override
  FutureOr<List<Quote>> build() {
    return _fetchQuotes();
  }

  Future<List<Quote>> _fetchQuotes() {
    final repository = ref.read(quoteRepositoryProvider);
    return repository.fetchQuotes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchQuotes());
  }
}
