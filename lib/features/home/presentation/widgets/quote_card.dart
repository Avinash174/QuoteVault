import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/quote_model.dart';
import '../../../library/presentation/providers/library_viewmodel.dart';
import 'share_bottom_sheet.dart';

class QuoteCard extends ConsumerWidget {
  final Quote quote;

  const QuoteCard({super.key, required this.quote});

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(quote: quote),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch favorite state
    final isFavorite = ref.watch(
      libraryViewModelProvider.select((items) => items.contains(quote)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image (Optional/Placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/800/600?grayscale',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) =>
                  Container(color: Theme.of(context).cardTheme.color),
              errorWidget: (context, url, error) =>
                  Container(color: Theme.of(context).cardTheme.color),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  '"${quote.text}"',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                    color: Colors
                        .white, // Always white because of dark image overlay
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "— ${quote.author}",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _showShareOptions(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(libraryViewModelProvider.notifier)
                            .toggleFavorite(quote);
                      },
                      icon:
                          Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: isFavorite ? Colors.red : Colors.white,
                              )
                              .animate(target: isFavorite ? 1 : 0)
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2),
                                duration: 200.ms,
                                curve: Curves.easeInOut,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(1, 1),
                                duration: 100.ms,
                              ),
                      label: Text(isFavorite ? 'Saved' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFavorite
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.accent,
                        foregroundColor: isFavorite ? Colors.red : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
