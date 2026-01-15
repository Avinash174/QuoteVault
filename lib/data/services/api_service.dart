import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quote_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.api-ninjas.com/v2/quotes';

  Future<List<Quote>> getQuotes({String? category, int limit = 10}) async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API_KEY not found in .env');
    }

    final queryParameters = {
      'limit': limit.toString(),
      if (category != null && category.isNotEmpty) 'categories': category,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Quote.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load quotes: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
