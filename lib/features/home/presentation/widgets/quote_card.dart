import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../library/presentation/providers/library_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/quote_model.dart';
import '../../../library/presentation/widgets/add_to_collection_sheet.dart';
import 'share_bottom_sheet.dart';

class QuoteCard extends ConsumerWidget {
  final Quote quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardTheme = Theme.of(context).cardTheme;
    final favorites = ref.watch(libraryViewModelProvider);
    final isFavorite = favorites.any(
      (q) => q.text == quote.text && q.author == quote.author,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardTheme.color,
        borderRadius: (cardTheme.shape as RoundedRectangleBorder).borderRadius,
        border: Border.fromBorderSide(
          (cardTheme.shape as RoundedRectangleBorder).side,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 32,
            color: AppColors.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            quote.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '- ${quote.author}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white70
                        : AppColors.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildActionButton(
                    context,
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    isDark: isDark,
                    color: isFavorite ? Colors.redAccent : null,
                    onPressed: () {
                      ref
                          .read(libraryViewModelProvider.notifier)
                          .toggleFavorite(quote);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.collections_bookmark_outlined,
                    isDark: isDark,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) =>
                            AddToCollectionSheet(quote: quote),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.share_outlined,
                    isDark: isDark,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => ShareBottomSheet(quote: quote),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : AppColors.accent.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: color ?? (isDark ? Colors.white : AppColors.textPrimaryLight),
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
