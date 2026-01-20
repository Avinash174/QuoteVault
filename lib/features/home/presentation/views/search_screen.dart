import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/quote_card.dart';
import '../widgets/quote_card_shimmer.dart';
import '../providers/search_viewmodel.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce can be added here if needed, but for now direct call
    ref.read(searchViewModelProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Search quotes or authors...',
            hintStyle: TextStyle(
              color: (isDark ? Colors.white : AppColors.textPrimaryLight)
                  .withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildQuickSearchChip(context, 'Love'),
                const SizedBox(width: 8),
                _buildQuickSearchChip(context, 'Life'),
                const SizedBox(width: 8),
                _buildQuickSearchChip(context, 'Wisdom'),
                const SizedBox(width: 8),
                _buildQuickSearchChip(context, 'Success'),
                const SizedBox(width: 8),
                _buildQuickSearchChip(context, 'History'),
              ],
            ),
          ),

          Divider(color: isDark ? Colors.white12 : Colors.black12),

          Expanded(
            child: searchState.when(
              data: (quotes) {
                if (quotes.isEmpty) {
                  if (_searchController.text.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for inspiration',
                            style: TextStyle(
                              color:
                                  (isDark
                                          ? Colors.white
                                          : AppColors.textPrimaryLight)
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        color:
                            (isDark ? Colors.white : AppColors.textPrimaryLight)
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    return QuoteCard(quote: quotes[index])
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => const QuoteCardShimmer(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      label: Text(label),
      backgroundColor: isDark
          ? const Color(0xFF252525)
          : Colors.black.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }
}
