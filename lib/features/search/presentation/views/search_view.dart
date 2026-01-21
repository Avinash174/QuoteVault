import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/search_viewmodel.dart';
import '../../../../core/widgets/fade_slide_transition.dart';
import '../../../home/presentation/views/quote_detail_view.dart';
import '../../../../data/models/quote_model.dart';
import '../../../../data/models/quote_collection.dart';

class SearchView extends ConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final currentFilter = ref.watch(searchFilterProvider);
    final searchController = TextEditingController(text: searchQuery);

    // Ensure cursor is at the end if the text matches
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: searchController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search quotes, authors...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                        suffix: searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                  searchController.clear();
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).hintColor,
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          ref
                              .read(recentSearchesProvider.notifier)
                              .addSearch(value);
                        }
                      },
                    ),

                    // Filters
                    if (searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: SearchFilter.values.map((filter) {
                            final isSelected = currentFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  filter.name.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref
                                            .read(searchFilterProvider.notifier)
                                            .state =
                                        filter;
                                  }
                                },
                                backgroundColor: Theme.of(
                                  context,
                                ).cardTheme.color,
                                selectedColor: AppColors.accent,
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.accent
                                        : Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Expanded(
                child: searchQuery.isEmpty
                    ? _buildTrendingSection(context, ref)
                    : searchResultsAsync.when(
                        data: (results) {
                          if (results.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No results found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              Widget content;

                              if (item is Quote) {
                                final heroTag =
                                    'search_quote_${item.text.hashCode}_$index';
                                content = Hero(
                                  tag: heroTag,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuoteDetailView(
                                                  quote: item,
                                                  heroTag: heroTag,
                                                ),
                                          ),
                                        );
                                      },
                                      child: _buildResultItem(
                                        context,
                                        title: item.text,
                                        subtitle: item.author,
                                        icon: Icons.format_quote,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (item is QuoteCollection) {
                                content = _buildResultItem(
                                  context,
                                  title: item.name,
                                  subtitle: '${item.quotes.length} quotes',
                                  icon: Icons.folder,
                                );
                              } else {
                                content = _buildResultItem(
                                  context,
                                  title: item.toString(),
                                  subtitle: '',
                                  icon: Icons.article,
                                );
                              }

                              return FadeSlideTransition(
                                index: index,
                                child: content,
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final trendingAuthors = ref.watch(trendingAuthorsProvider);
    final trendingSearches = ref.watch(trendingSearchesProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Authors
            Text(
              'Trending Authors',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trendingAuthors.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final author = trendingAuthors[index];
                  final nameParts = author['name']!.split(' ');
                  final initials = nameParts.length > 1
                      ? '${nameParts[0][0]}${nameParts[1][0]}'
                      : nameParts[0].substring(0, 2);

                  return GestureDetector(
                    onTap: () {
                      ref.read(searchQueryProvider.notifier).state =
                          author['name']!.replaceAll('\n', ' ');
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).cardTheme.color,
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          author['name']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Trending Searches
            Text(
              'Trending Searches',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: trendingSearches.map((search) {
                final isAccent = search == 'Stoicism';
                return GestureDetector(
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).state = search;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isAccent
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(25),
                      border: isAccent
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAccent) ...[
                          Icon(
                            Icons.trending_up,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          search,
                          style: TextStyle(
                            color: isAccent
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Recent Searches
            if (recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(recentSearchesProvider.notifier).clearAll();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: recentSearches.map((search) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.history,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withValues(alpha: 0.5),
                          ),
                          title: Text(
                            search,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () {
                            ref.read(searchQueryProvider.notifier).state =
                                search;
                          },
                          trailing: GestureDetector(
                            onTap: () {
                              ref
                                  .read(recentSearchesProvider.notifier)
                                  .removeSearch(search);
                            },
                            child: Icon(
                              Icons.close,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.5),
                              size: 18,
                            ),
                          ),
                        ),
                        if (search != recentSearches.last)
                          Divider(
                            color: Theme.of(context).dividerColor,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
