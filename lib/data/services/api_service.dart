import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import '../models/quote_model.dart';

class ApiService {
  static const String _zenQuotesUrl = 'https://zenquotes.io/api';
  static const String _dummyJsonUrl = 'https://dummyjson.com/quotes';

  // Cache for Quote of the Day
  static Quote? _cachedQod;
  static DateTime? _lastCacheTime;

  // Cache for All Quotes (ZenQuotes)
  static List<Quote>? _cachedQuotes;
  static DateTime? _lastQuotesCacheTime;

  Future<List<Quote>> getQuotes({
    String? category,
    int limit = 10,
    int skip = 0,
  }) async {
    final bool isFiltered =
        category != null && category.isNotEmpty && category != 'All Quotes';
    final Uri uri;

    if (!isFiltered) {
      if (_cachedQuotes != null && _lastQuotesCacheTime != null) {
        final difference = DateTime.now().difference(_lastQuotesCacheTime!);
        if (difference.inSeconds < 5) {
          developer.log('Returning cached quotes', name: 'ThoughtVault.API');
          return _cachedQuotes!;
        }
      }
      uri = Uri.parse('$_zenQuotesUrl/quotes');
    } else {
      uri = Uri.parse('$_dummyJsonUrl/tag/${category.toLowerCase()}');
    }

    developer.log('API Request: GET $uri', name: 'ThoughtVault.API');

    try {
      final response = await http.get(
        uri,
        headers: isFiltered
            ? {}
            : {
                'User-Agent':
                    'ThoughtVault/1.0 (Flutter App)', // Required for ZenQuotes
              },
      );

      developer.log(
        'API Response: ${response.statusCode} - ${response.reasonPhrase}',
        name: 'ThoughtVault.API',
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // Parsing logic depends on source
        if (isFiltered) {
          // DummyJSON format: { quotes: [...] }
          final List<dynamic> quotes = data['quotes'];
          if (quotes.isEmpty) return [];

          return quotes.map((json) {
            return Quote.fromJson({
              'quote': json['quote'],
              'author': json['author'],
              'categories': [category],
            });
          }).toList();
        } else {
          // ZenQuotes format: [ { q: ..., a: ... } ]
          if (data is List) {
            final quotes = data.map((json) {
              return Quote.fromJson({
                'quote': json['q'],
                'author': json['a'],
                'categories': [],
              });
            }).toList();

            _cachedQuotes = quotes;
            _lastQuotesCacheTime = DateTime.now();
            return quotes;
          }
          throw Exception('Unexpected data format from quotes server');
        }
      } else if (response.statusCode == 429) {
        throw Exception(
          'Rate limit exceeded. Please try again in a few minutes.',
        );
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('API Request Failed', name: 'ThoughtVault.API', error: e);
      rethrow;
    }
  }

  Future<List<Quote>> searchQuotes(String query) async {
    if (query.trim().isEmpty) return [];

    // DummyJSON search endpoint
    final uri = Uri.parse(
      '$_dummyJsonUrl/search',
    ).replace(queryParameters: {'q': query.trim()});

    developer.log('API Request: GET $uri', name: 'ThoughtVault.API');

    try {
      final response = await http.get(uri);

      developer.log(
        'API Response: ${response.statusCode} - ${response.reasonPhrase}',
        name: 'ThoughtVault.API',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> quotes = data['quotes'];

        return quotes.map((json) {
          return Quote.fromJson({
            'quote': json['quote'],
            'author': json['author'],
            'categories':
                [], // Search results don't explicitly return categories in this endpoint structure usually
          });
        }).toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('API Search Failed', name: 'ThoughtVault.API', error: e);
      rethrow;
    }
  }

  Future<Quote> getQuoteOfTheDay() async {
    // Check cache first (valid for 1 hour)
    if (_cachedQod != null && _lastCacheTime != null) {
      final difference = DateTime.now().difference(_lastCacheTime!);
      if (difference.inHours < 1) {
        developer.log('Returning cached QOD', name: 'ThoughtVault.API');
        return _cachedQod!;
      }
    }

    // ZenQuotes for Quote of the Day
    final uri = Uri.parse('$_zenQuotesUrl/today');

    developer.log('API Request: GET $uri', name: 'ThoughtVault.API');

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'ThoughtVault/1.0 (Flutter App)'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) throw Exception('No QOD available');

        final json = data.first;
        _cachedQod = Quote.fromJson({
          'quote': json['q'],
          'author': json['a'],
          'categories': [],
        });
        _lastCacheTime = DateTime.now();
        return _cachedQod!;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded for Daily Inspiration.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log(
        'API QOD Request Failed',
        name: 'ThoughtVault.API',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<String>> getAuthors({int limit = 20, int offset = 0}) async {
    // ZenQuotes does not support author listing in the free tier
    // Returning empty list to avoid errors/expenses
    return [];
  }
}
