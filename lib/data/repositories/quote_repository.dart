import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/quote_model.dart';
import '../services/api_service.dart';

part 'quote_repository.g.dart';

@riverpod
QuoteRepository quoteRepository(QuoteRepositoryRef ref) {
  return QuoteRepository(ApiService());
}

class QuoteRepository {
  final ApiService _apiService;

  QuoteRepository(this._apiService);

  Future<List<Quote>> fetchQuotes({int page = 1, int limit = 10}) async {
    try {
      // API Ninjas doesn't support pagination by page number directly in the same way,
      // but we can request a limit. 'page' might be ignored or handled by client side if needed.
      // For now, we just fetch 'limit' quotes.
      return await _apiService.getQuotes(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch quotes: $e');
    }
  }
}
