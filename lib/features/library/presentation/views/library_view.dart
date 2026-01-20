import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/library_viewmodel.dart';
import '../../../../features/home/presentation/widgets/quote_card.dart';

class LibraryView extends ConsumerStatefulWidget {
  const LibraryView({super.key});

  @override
  ConsumerState<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends ConsumerState<LibraryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(libraryViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            const Text(
                  'My Library',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.2, end: 0),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Favorites'),
            Tab(text: 'Collections'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorites Tab
          favorites.isEmpty
              ? _buildEmptyState('No favorites yet', Icons.favorite_border)
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 100),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final quote = favorites[index];
                    return QuoteCard(quote: quote)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                        .slideY(begin: 0.2, end: 0);
                  },
                ),

          // Collections Tab (Placeholder)
          _buildEmptyState(
            'No collections yet',
            Icons.collections_bookmark_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[800])
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ).animate().fadeIn(duration: 800.ms),
        ],
      ),
    );
  }
}
