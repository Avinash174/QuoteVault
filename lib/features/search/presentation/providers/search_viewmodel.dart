import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/quote_repository.dart';

import '../../../library/presentation/providers/collection_viewmodel.dart';

// Search Filter Enum
enum SearchFilter { all, quotes, authors, collections }

// State for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// State for current filter
final searchFilterProvider = StateProvider<SearchFilter>(
  (ref) => SearchFilter.all,
);

// State for recent searches
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
      return RecentSearchesNotifier();
    });

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier()
    : super(['Existentialism', 'Margaret Atwood', 'The Alchemist']);

  void addSearch(String query) {
    if (query.isNotEmpty && !state.contains(query)) {
      state = [query, ...state];
    }
  }

  void removeSearch(String query) {
    state = state.where((item) => item != query).toList();
  }

  void clearAll() {
    state = [];
  }
}

// Search Results Provider
final searchResultsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(searchFilterProvider);
  final repository = ref.read(quoteRepositoryProvider);
  final collections = ref.watch(collectionViewModelProvider).valueOrNull ?? [];

  if (query.isEmpty) return [];

  List<dynamic> results = [];

  // Search Quotes & Authors
  if (filter == SearchFilter.all ||
      filter == SearchFilter.quotes ||
      filter == SearchFilter.authors) {
    try {
      final quotes = await repository.searchQuotes(query);

      if (filter == SearchFilter.authors) {
        // Filter strictly for authors if that's the selected filter
        // The API might return quotes that match the author name, so we can use that
        results.addAll(
          quotes.where((q) => q.author.toLowerCase().contains(query)),
        );
      } else {
        results.addAll(quotes);
      }
    } catch (e) {
      // Handle error or return empty
    }
  }

  // Search Collections
  if (filter == SearchFilter.all || filter == SearchFilter.collections) {
    final matchingCollections = collections
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
    results.addAll(matchingCollections);
  }

  return results;
});

// Mock Data for Trending Authors
final trendingAuthorsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {
      'name': 'Marcus\nAurelius',
      'image': 'assets/images/marcus.png',
    }, // Placeholder paths
    {'name': 'Maya\nAngelou', 'image': 'assets/images/maya.png'},
    {'name': 'Steve\nJobs', 'image': 'assets/images/steve.png'},
    {'name': 'Albert\nCamus', 'image': 'assets/images/albert.png'},
  ];
});

// Mock Data for Trending Searches
final trendingSearchesProvider = Provider<List<String>>((ref) {
  return ['Stoicism', 'Motivation', 'Leadership', 'Wisdom'];
});
