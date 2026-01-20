import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/library_viewmodel.dart';
import '../providers/collection_viewmodel.dart';
import 'collection_detail_view.dart';
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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(libraryViewModelProvider);
    final collections = ref.watch(collectionViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            Text(
                  'My Library',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.2, end: 0),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : AppColors.accent,
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

          // Collections Tab
          collections.when(
            data: (data) => data.isEmpty
                ? _buildEmptyState(
                    'No collections yet',
                    Icons.collections_bookmark_outlined,
                    onAction: () => _showCreateCollectionDialog(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final collection = data[index];
                      return ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CollectionDetailView(
                                  collection: collection,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: AppColors.accent,
                              ),
                            ),
                            title: Text(
                              collection.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '${collection.quotes.length} quotes',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (100 * index).ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showCreateCollectionDialog(context, ref),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ).animate().scale()
          : null,
    );
  }

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'New Collection',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Collection Name',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey : Colors.grey[400],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(collectionViewModelProvider.notifier)
                    .createCollection(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String message,
    IconData icon, {
    VoidCallback? onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                icon,
                size: 64,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 16,
            ),
          ).animate().fadeIn(duration: 800.ms),
        ],
      ),
    );
  }
}
