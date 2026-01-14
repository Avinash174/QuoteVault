import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quote_repository.g.dart';

@riverpod
QuoteRepository quoteRepository(QuoteRepositoryRef ref) {
  return QuoteRepository();
}

class QuoteRepository {
  Future<List<Quote>> fetchQuotes() async {
    try {
      final response = await Supabase.instance.client.from('quotes').select();

      final data = response as List<dynamic>;
      return data
          .map((json) => Quote.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list or throw, depending on error handling strategy.
      // For now, let's rethrow to let the UI show the error state.
      throw Exception('Failed to fetch quotes: $e');
    }
  }
}
