import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/quote_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Quote?> getRandomQuote() async {
    try {
      // First, get the count of rows
      final countResponse = await _client
          .from('quotes')
          .select('id')
          .count(CountOption.exact);

      final count = countResponse.count;

      if (count == 0) {
        return null;
      }

      // Generate a random offset
      final randomOffset = Random().nextInt(count);

      // Fetch a single random quote
      final response = await _client
          .from('quotes')
          .select()
          .range(randomOffset, randomOffset)
          .single();

      return Quote.fromJson(response);
    } catch (e) {
      // Handle error or return null to fall back to default
      print('Error fetching quote from Supabase: $e');
      return null;
    }
  }
}
