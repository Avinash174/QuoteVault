import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/quote_card.dart';
import '../widgets/quote_card_shimmer.dart';
import '../providers/quote_viewmodel.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import 'search_screen.dart';
import '../../../notifications/presentation/providers/notification_settings_viewmodel.dart';
import 'quote_detail_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quoteViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
            ref.read(quoteViewModelProvider.notifier).fetchMore().catchError((
              e,
            ) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load more quotes: $e')),
                );
              }
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: false,
              leading: null,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon/app_logo.png',
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ThoughtVault',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
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
                    ref
                        .watch(notificationsEnabledProvider)
                        .when(
                          data: (enabled) => enabled
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DAILY INSPIRATION',
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
                                        final qodAsync = ref.watch(
                                          quoteOfTheDayProvider,
                                        );
                                        return qodAsync.when(
                                          data: (quote) =>
                                              QuoteCard(quote: quote),
                                          loading: () =>
                                              const QuoteCardShimmer(),
                                          error: (error, _) => Text(
                                            'Unable to load Daily Inspiration',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          loading: () => const QuoteCardShimmer(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
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
                  vertical: 12,
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final selectedCategory = ref.watch(
                      selectedCategoryProvider,
                    );

                    return Row(
                      children: [
                        _buildFilterChip(
                          ref,
                          context,
                          'All Quotes',
                          selectedCategory,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          ref,
                          context,
                          'Love',
                          selectedCategory,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          ref,
                          context,
                          'Life',
                          selectedCategory,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          ref,
                          context,
                          'Beauty',
                          selectedCategory,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          ref,
                          context,
                          'History',
                          selectedCategory,
                        ),
                      ],
                    );
                  },
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
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
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
              data: (quotes) {
                const adInterval = 5;
                final totalItems =
                    quotes.length + (quotes.length / adInterval).floor();

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Check if this position is for an ad
                    if ((index + 1) % (adInterval + 1) == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: BannerAdWidget(),
                      );
                    }

                    // Calculate the actual quote index
                    final quoteIndex =
                        index - (index / (adInterval + 1)).floor();
                    if (quoteIndex >= quotes.length) return null;

                    final quote = quotes[quoteIndex];
                    final heroTag = 'quote_${quote.text.hashCode}_$index';

                    return Hero(
                      tag: heroTag,
                      child: Material(
                        type: MaterialType.transparency,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuoteDetailView(
                                  quote: quote,
                                  heroTag: heroTag,
                                ),
                              ),
                            );
                          },
                          child: QuoteCard(quote: quote),
                        ),
                      ),
                    );
                  }, childCount: totalItems),
                );
              },
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

            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    BuildContext context,
    String label,
    String currentCategory,
  ) {
    final selected = currentCategory == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).setCategory(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white : AppColors.accent)
              : (isDark
                    ? const Color(0xFF252525)
                    : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.white : AppColors.accent)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 16,
                color: isDark ? Colors.black : Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
