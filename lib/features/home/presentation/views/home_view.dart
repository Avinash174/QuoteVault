import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/quote_card.dart';
import '../providers/quote_viewmodel.dart';
import '../../../../data/models/quote_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quoteViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {}, // No back navigation in main home usually
        ),
        title: const Text(
          'Motivation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Popular', selected: true),
                const SizedBox(width: 12),
                _buildFilterChip('Newest'),
                const SizedBox(width: 12),
                _buildFilterChip('Short'),
              ],
            ),
          ),

          // Sync Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  'API SYNCED', // Updated from 'SUPABASE SYNCED'
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

          // List
          Expanded(
            child: quotesAsync.when(
              data: (quotes) => NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent) {
                    ref.read(quoteViewModelProvider.notifier).fetchMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    return QuoteCard(quote: quotes[index]);
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      // Removed redundant FloatingActionButton as MainScreen handles it
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
