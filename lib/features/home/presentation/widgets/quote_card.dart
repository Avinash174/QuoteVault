import 'package:flutter/material.dart';
import '../../../../core/utils/snackbar_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../library/presentation/providers/library_viewmodel.dart';
import '../providers/quote_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/quote_model.dart';
import '../../../library/presentation/widgets/add_to_collection_sheet.dart';
import 'share_bottom_sheet.dart';

class QuoteCard extends ConsumerStatefulWidget {
  final Quote quote;

  const QuoteCard({super.key, required this.quote});

  @override
  ConsumerState<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends ConsumerState<QuoteCard> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    // Confirm deletion with a fun dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Melt this Quote?'),
        content: const Text(
          'This will permanently dissolve this thought from the community.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('KEEP IT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'MELT',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();
      setState(() => _isDeleting = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardTheme = Theme.of(context).cardTheme;
    final favorites = ref.watch(libraryViewModelProvider);
    final isFavorite = favorites.any(
      (q) => q.text == quote.text && q.author == quote.author,
    );
    final isOwned =
        quote.userId != null &&
        FirebaseAuth.instance.currentUser?.uid == quote.userId;

    Widget cardContent = GestureDetector(
      child:
          Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardTheme.color,
                  borderRadius:
                      (cardTheme.shape as RoundedRectangleBorder).borderRadius,
                  border: Border.fromBorderSide(
                    (cardTheme.shape as RoundedRectangleBorder).side,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.03,
                      ),
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
                      color: AppColors.accent.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    if (quote.categories.contains('Community')) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'COMMUNITY',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      quote.text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
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
                              icon: isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              isDark: isDark,
                              color: isFavorite ? AppColors.error : null,
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
                                  builder: (context) =>
                                      ShareBottomSheet(quote: quote),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate() // Entry animation
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0)
              .animate(
                target: _isDeleting ? 1 : 0,
                onComplete: (controller) {
                  if (_isDeleting) {
                    _performDelete(quote);
                  }
                },
              ) // Deletion animation
              .shake(duration: 400.ms, hz: 10, curve: Curves.easeInOut)
              .tint(color: AppColors.error, end: 0.6, duration: 400.ms)
              .blur(
                end: const Offset(10, 10),
                duration: 600.ms,
                curve: Curves.easeIn,
              )
              .scale(
                end: const Offset(0.4, 0.4),
                duration: 600.ms,
                curve: Curves.easeIn,
              )
              .fadeOut(duration: 600.ms),
    );

    if (isOwned) {
      return Dismissible(
        key: ValueKey('dismiss_${quote.id}_${quote.text.hashCode}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child:
              const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.error,
                    size: 32,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1500.ms),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          // Use the existing _handleDelete logic which includes the confirmation dialog
          await _handleDelete();
          // If _isDeleting is true, it means the user confirmed and the animation will handle the removal.
          // We return false here so the Dismissible doesn't immediately remove the item,
          // allowing our custom animation to play out.
          return false;
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Future<void> _performDelete(Quote quote) async {
    try {
      await ref.read(quoteViewModelProvider.notifier).deleteQuote(quote);
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Quote Melted',
          'It has returned to the ether.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false); // Revert animation
        SnackbarUtils.showError(
          context,
          'Melt Failed',
          'Could not delete quote. Please try again.',
        );
      }
    }
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
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.accent.withValues(alpha: 0.05),
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
