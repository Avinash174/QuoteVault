import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/quote_model.dart';
import '../views/quote_generator_view.dart';

class ShareBottomSheet extends StatelessWidget {
  final Quote quote;

  const ShareBottomSheet({super.key, required this.quote});

  void _shareAsText(BuildContext context) {
    Share.share('"${quote.text}" - ${quote.author}');
    Navigator.pop(context);
  }

  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: '"${quote.text}" - ${quote.author}'),
    );
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quote copied to clipboard!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _generateQuoteCard(BuildContext context) {
    Navigator.pop(context); // Close the sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuoteGeneratorView(quote: quote)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Share Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'THOUGHTVAULT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 32),

          // Quote Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${quote.text}"',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quote.author.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      color: AppColors.accent,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          _buildActionTile(
            context,
            icon: Icons.share_outlined,
            title: 'Share as Text',
            subtitle: 'Send via Messages or Mail',
            onTap: () => _shareAsText(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: Icons.copy,
            title: 'Copy to Clipboard',
            subtitle: 'Save to your system pasteboard',
            onTap: () => _copyToClipboard(context),
            traitWrapper: true,
          ),
          const SizedBox(height: 24),

          // Main CTA
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _generateQuoteCard(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFFFF4081,
                ), // Pink-ish color from screenshot
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text(
                    'Generate Quote Card',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool traitWrapper = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[900]!),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: traitWrapper
            ? const CircleAvatar(
                backgroundColor: Color(0xFF00C851),
                radius: 10,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
