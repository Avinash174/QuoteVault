import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/repositories/quote_repository.dart';

part 'authors_viewmodel.g.dart';

@riverpod
class AuthorsViewModel extends _$AuthorsViewModel {
  @override
  FutureOr<List<String>> build() {
    return _fetchAuthors();
  }

  Future<List<String>> _fetchAuthors() {
    final repository = ref.read(quoteRepositoryProvider);
    return repository.fetchAuthors(limit: 100); // Fetch a good amount
  }
}
