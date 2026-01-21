import 'package:flutter/material.dart';
import '../../../../data/models/quote_collection.dart';
import '../../../../core/theme/app_colors.dart';

class CollectionGridItem extends StatelessWidget {
  final QuoteCollection collection;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Optional delete callback
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const CollectionGridItem({
    super.key,
    required this.collection,
    required this.onTap,
    this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
  });

  // ... (keep helper methods same)
  // A palette of vibrant colors similar to the image
  static const List<Color> _collectionColors = [
    Color(0xFF5B4DFF), // Blue/Purple like "Monday Motivation"
    Color(0xFF00A86B), // Green like "Book Project"
    Color(0xFF4A4A4A), // Dark Grey like "Stoicism" or just Dark
    Color(0xFFE88A1A), // Orange like "Wisdom"
    Color(0xFF9C42D3), // Purple like "Morning Ritual"
    Color(0xFFD33644), // Red like "Love & Kindness"
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF4081), // Pink
  ];

  // Deterministic color generation based on collection name/id
  Color _getCollectionColor(String id) {
    // Use hash to pick a stable color for the same ID
    final index = id.hashCode.abs() % _collectionColors.length;
    return _collectionColors[index];
  }

  // Helper to pick an icon based on name (simple keyword matching)
  IconData _getCollectionIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('love')) return Icons.favorite;
    if (lower.contains('book') || lower.contains('read')) {
      return Icons.menu_book;
    }
    if (lower.contains('work') || lower.contains('job')) return Icons.work;
    if (lower.contains('sun') || lower.contains('morning')) {
      return Icons.wb_sunny;
    }
    if (lower.contains('moon') || lower.contains('night')) {
      return Icons.nights_stay;
    }
    if (lower.contains('idea') || lower.contains('mind')) {
      return Icons.psychology;
    }
    if (lower.contains('gym') || lower.contains('fit')) {
      return Icons.fitness_center;
    }
    if (lower.contains('stoic')) return Icons.balance;
    return Icons.folder_open; // Default
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCollectionColor(collection.id);
    final icon = _getCollectionIcon(collection.name);
    final count = collection.quotes.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isSelected || isSelectionMode
            ? Matrix4.identity().scaled(0.95)
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Main Icon
                        Center(
                          child: Icon(icon, size: 48, color: Colors.white),
                        ),

                        // Count Badge (Bottom Right)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count QUOTES',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection Overlay
                  if (isSelectionMode)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : Colors.black26,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: isSelected
                              ? Icon(Icons.check, size: 16, color: cardColor)
                              : const SizedBox(width: 16, height: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              collection.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),

            // Subtitle (Timestamp)
            Text(
              _formatDate(collection.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    // Simple relative time logic or just date
    // For now returning simple string, can be improved with intl or timeago
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return 'Updated ${diff.inDays} days ago';
    if (diff.inHours > 0) return 'Updated ${diff.inHours} hours ago';
    return 'Updated just now';
  }
}
