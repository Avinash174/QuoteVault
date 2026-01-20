import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/quote_collection.dart';
import '../../../../features/home/presentation/widgets/quote_card.dart';
import '../providers/collection_viewmodel.dart';

class CollectionDetailView extends ConsumerWidget {
  final QuoteCollection collection;

  const CollectionDetailView({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the collection in the state to stay in sync if a quote is removed
    // Watch the collection in the state to stay in sync if a quote is removed
    final asyncCollections = ref.watch(collectionViewModelProvider);
    final currentCollection = asyncCollections.maybeWhen(
      data: (collections) => collections.firstWhere(
        (c) => c.id == collection.id,
        orElse: () => collection,
      ),
      orElse: () => collection,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentCollection.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: currentCollection.quotes.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              itemCount: currentCollection.quotes.length,
              itemBuilder: (context, index) {
                final quote = currentCollection.quotes[index];
                return Dismissible(
                  key: Key('${quote.text}_${quote.author}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(collectionViewModelProvider.notifier)
                        .removeQuoteFromCollection(currentCollection.id, quote);
                  },
                  child: QuoteCard(quote: quote)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                      .slideX(begin: 0.1, end: 0),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote,
            size: 64,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'This collection is empty',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Collection?',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${collection.name}"?',
          style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(collectionViewModelProvider.notifier)
                  .deleteCollection(collection.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop detail view
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
