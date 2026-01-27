import '../widgets/collection_grid_item.dart';
// import '../../../../data/models/quote_collection.dart'; // Removed or cleaner removal
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
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
  final Set<String> _selectedItems = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Exit selection mode when switching tabs
        if (_isSelectionMode) {
          setState(() {
            _isSelectionMode = false;
            _selectedItems.clear();
          });
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedItems.add(id);
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedItems.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Delete ${count > 1 ? "Collections" : "Collection"}?',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'Are you sure you want to delete $count selected ${count > 1 ? "items" : "item"}? This cannot be undone.',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final idsToDelete = _selectedItems.toList();
      // Optimistic update done by Riverpod usually, but we call VM
      for (final id in idsToDelete) {
        ref.read(collectionViewModelProvider.notifier).deleteCollection(id);
      }

      setState(() {
        _isSelectionMode = false;
        _selectedItems.clear();
      });

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Deleted Successfully',
          'Deleted $count ${count > 1 ? "collections" : "collection"}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(libraryViewModelProvider);
    final collections = ref.watch(collectionViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCollectionsTab = _tabController.index == 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedItems.clear();
                  });
                },
              )
            : null,
        title: _isSelectionMode
            ? Text(
                '${_selectedItems.length} Selected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              )
            : Text(
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
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _deleteSelected,
            )
          else if (isCollectionsTab)
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? Colors.white : AppColors.accent,
                size: 28,
              ),
              onPressed: () => _showCreateCollectionDialog(context, ref),
            ),
          const SizedBox(width: 8),
        ],
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
            data: (data) {
              if (data.isEmpty) {
                return _buildEmptyState(
                  'No collections yet',
                  Icons.collections_bookmark_outlined,
                  onAction: () => _showCreateCollectionDialog(context, ref),
                );
              }

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search collections or quotes',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),

                  // Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 100,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final collection = data[index];
                        final isSelected = _selectedItems.contains(
                          collection.id,
                        );

                        return CollectionGridItem(
                              collection: collection,
                              isSelectionMode: _isSelectionMode,
                              isSelected: isSelected,
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(collection.id);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CollectionDetailView(
                                            collection: collection,
                                          ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  _enterSelectionMode(collection.id);
                                }
                              },
                            )
                            .animate(target: _isSelectionMode ? 1 : 0)
                            .shimmer(
                              duration: 1.seconds,
                              delay: 500.ms,
                            ) // Usage hint
                            .animate()
                            .fadeIn(delay: (50 * index).ms)
                            .scale(begin: const Offset(0.9, 0.9));
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      // FAB only for Favorites (optional, or remove completely per request)
      // User asked to remove "add collection button from collection tab"
      // We moved it to AppBar. For favorites, we might not need an action button?
      // I'll leave FAB as null for both for standard look, or keep it only for favorites?
      // Favorites usually don't have a "Create" FAB. So null is safer.
      floatingActionButton: null,
    );
  }

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    // ... (Keep existing implementation)
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
    // ... (Keep existing implementation)
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
          if (onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create Collection'),
            ),
          ],
        ],
      ),
    );
  }
}
