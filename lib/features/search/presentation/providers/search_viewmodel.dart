import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// State for recent searches (Mocked for now, can be persisted later)
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
