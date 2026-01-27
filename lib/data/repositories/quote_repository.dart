import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/quote_model.dart';
import '../services/api_service.dart';
import '../../core/services/firestore_service.dart';

part 'quote_repository.g.dart';

@riverpod
QuoteRepository quoteRepository(QuoteRepositoryRef ref) {
  return QuoteRepository(ApiService());
}

class QuoteRepository {
  final ApiService _apiService;
  final FirestoreService _firestoreService = FirestoreService();

  QuoteRepository(this._apiService);

  Future<List<Quote>> fetchQuotes({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    try {
      final bool isDefaultCategory =
          category == null || category.isEmpty || category == 'All Quotes';

      // Fetch from API
      final skip = (page - 1) * limit;
      final apiQuotes = await _apiService.getQuotes(
        limit: limit,
        skip: skip,
        category: category,
      );

      // Only merge community quotes if we are on the first page of "All Quotes"
      if (page == 1 && isDefaultCategory) {
        final communityData = await _firestoreService.getCommunityQuotes(
          limit: 5,
        );
        final communityQuotes = communityData.map((data) {
          return Quote(
            text: data['quote'] ?? '',
            author: data['author'] ?? 'Unknown',
            categories: ['Community'],
          );
        }).toList();

        // Merge community quotes at the beginning
        return [...communityQuotes, ...apiQuotes];
      }

      return apiQuotes;
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
