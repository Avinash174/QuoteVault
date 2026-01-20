import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/quote_card.dart';
import '../widgets/quote_card_shimmer.dart';
import '../providers/quote_viewmodel.dart';
import '../providers/authors_viewmodel.dart';
import '../../../../data/models/quote_model.dart';
import '../../../../core/widgets/error_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quoteViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
            ref.read(quoteViewModelProvider.notifier).fetchMore().catchError((
              e,
            ) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load more quotes: $e')),
              );
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: false,
              leading: null,
              automaticallyImplyLeading: false,
              title: const Text(
                'Motivation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: true,
              actions: [
                Consumer(
                  builder: (context, ref, _) {
                    return IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        try {
                          final authors = await ref.read(
                            authorsViewModelProvider.future,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Fetched ${authors.length} authors. Check console.',
                              ),
                            ),
                          );
                          print('Authors: $authors');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to fetch authors: $e'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),

            // Quote of the Day
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUOTE OF THE DAY',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final qodAsync = ref.watch(quoteOfTheDayProvider);
                        return qodAsync.when(
                          data: (quote) => QuoteCard(quote: quote),
                          loading: () => const QuoteCardShimmer(),
                          error: (error, _) => Text(
                            'Unable to load Quote of the Day',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                  ],
                ),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildFilterChip('All Quotes', selected: true),
                    const SizedBox(width: 12),
                    _buildFilterChip('Success'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Wisdom'),
                  ],
                ),
              ),
            ),

            // Live Feed Status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676), // Green dot
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE FEED',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List
            quotesAsync.when(
              data: (quotes) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return QuoteCard(quote: quotes[index]);
                }, childCount: quotes.length),
              ),
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const QuoteCardShimmer(),
                  childCount: 6,
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: ErrorView(
                  message: error.toString(),
                  onRetry: () =>
                      ref.read(quoteViewModelProvider.notifier).refresh(),
                ),
              ),
            ),

            // Bottom Padding specifically for Sliver
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white : const Color(0xFF252525),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        // Added Row for dropdown arrow if needed, keeping simple for now
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black,
            ),
          ] else ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          ],
        ],
      ),
    );
  }
}
