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

  Future<List<Quote>> fetchQuotes({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    try {
      // Calculate skip based on page and limit
      final skip = (page - 1) * limit;
      return await _apiService.getQuotes(
        limit: limit,
        skip: skip,
        category: category,
      );
    } catch (e) {
      throw Exception('Failed to fetch quotes: $e');
    }
  }

  Future<Quote> fetchQuoteOfTheDay() async {
    try {
      return await _apiService.getQuoteOfTheDay();
    } catch (e) {
      throw Exception('Failed to fetch Quote of the Day: $e');
    }
  }

  Future<List<String>> fetchAuthors({int limit = 20, int offset = 0}) async {
    try {
      return await _apiService.getAuthors(limit: limit, offset: offset);
    } catch (e) {
      throw Exception('Failed to fetch authors: $e');
    }
  }

  Future<List<Quote>> searchQuotes(String query) async {
    try {
      return await _apiService.searchQuotes(query);
    } catch (e) {
      throw Exception('Failed to search quotes: $e');
    }
  }
}
