import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/quote_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.api-ninjas.com/v2/quotes';

  Future<List<Quote>> getQuotes({String? category, int limit = 10}) async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Configuration Error: API_KEY not found in .env');
    }

    final queryParameters = {
      'limit': limit.toString(),
      if (category != null && category.isNotEmpty) 'categories': category,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

    debugPrint('API Request: GET $uri');

    try {
      final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

      debugPrint(
        'API Response: ${response.statusCode} - ${response.reasonPhrase}',
      );
      // debugPrint('API Body: ${response.body}'); // Uncomment if full body logging needed

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          debugPrint('API Warning: No quotes found.');
          return [];
        }
        return data.map((json) => Quote.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('API Error: Unauthorized access.');
        throw Exception('Unauthorized: Please check your API Key.');
      } else if (response.statusCode == 429) {
        debugPrint('API Error: Rate limit exceeded.');
        throw Exception('Rate Limit Exceeded: Please try again later.');
      } else {
        debugPrint('API Error: Server returned ${response.statusCode}');
        throw Exception(
          'Server Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('API Network Error: $e');
      throw Exception('Network Error: Please check your internet connection.');
    } catch (e) {
      debugPrint('API Unexpected Error: $e');
      throw Exception('Unexpected Error: $e');
    }
  }

  Future<Quote> getQuoteOfTheDay() async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Configuration Error: API_KEY not found in .env');
    }

    final uri = Uri.parse('https://api.api-ninjas.com/v2/quoteoftheday');

    debugPrint('API Request: GET $uri');

    try {
      final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

      debugPrint(
        'API Response: ${response.statusCode} - ${response.reasonPhrase}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          debugPrint('API Warning: No QOD found.');
          throw Exception('No Quote of the Day available.');
        }
        return Quote.fromJson(data.first);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('API Error: Unauthorized.');
        throw Exception('Unauthorized: Please check your API Key.');
      } else if (response.statusCode == 429) {
        debugPrint('API Error: Rate limit exceeded.');
        throw Exception('Rate Limit Exceeded: Please try again later.');
      } else {
        debugPrint('API Error: Server returned ${response.statusCode}');
        throw Exception(
          'Server Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('API Network Error: $e');
      throw Exception('Network Error: Please check your internet connection.');
    } catch (e) {
      debugPrint('API Unexpected Error: $e');
      throw Exception('Unexpected Error: $e');
    }
  }

  Future<List<String>> getAuthors({int limit = 20, int offset = 0}) async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Configuration Error: API_KEY not found in .env');
    }

    final queryParameters = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final uri = Uri.parse(
      'https://api.api-ninjas.com/v2/quoteauthors',
    ).replace(queryParameters: queryParameters);

    debugPrint('API Request: GET $uri');

    try {
      final response = await http.get(uri, headers: {'X-Api-Key': apiKey});

      debugPrint(
        'API Response: ${response.statusCode} - ${response.reasonPhrase}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('API Success: Fetched ${data.length} authors.');
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('API Error: Unauthorized.');
        throw Exception('Unauthorized: Please check your API Key.');
      } else if (response.statusCode == 429) {
        debugPrint('API Error: Rate limit exceeded.');
        throw Exception('Rate Limit Exceeded: Please try again later.');
      } else {
        debugPrint('API Error: Server returned ${response.statusCode}');
        throw Exception(
          'Server Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('API Network Error: $e');
      throw Exception('Network Error: Please check your internet connection.');
    } catch (e) {
      debugPrint('API Unexpected Error: $e');
      throw Exception('Unexpected Error: $e');
    }
  }
}
