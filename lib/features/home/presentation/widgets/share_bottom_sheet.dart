import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' as sp;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../data/models/quote_model.dart';
import '../views/quote_generator_view.dart';

class ShareBottomSheet extends StatelessWidget {
  final Quote quote;

  const ShareBottomSheet({super.key, required this.quote});

  void _shareAsText(BuildContext context) {
    AdService().showRewardedAd(
      context: context,
      onAdDismissed: () {
        // Nothing special to do when dismissed without reward
      },
      onUserEarnedReward: () {
        // ignore: deprecated_member_use
        sp.Share.share(
          '"${quote.text}" - ${quote.author}\n\nDownload ThoughtVault: https://play.google.com/store/apps/details?id=com.avinashmagar.thoughtvault',
        );
      },
    );
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
    final navigator = Navigator.of(context);
    AdService().showRewardedAd(
      context: context,
      onAdDismissed: () {
        // Optional: still navigate or allow access even if dismissed?
        // Usually, to be user friendly, we allow it or show another ad.
        // For now, let's proceed to ensure functionality.
        if (navigator.canPop()) navigator.pop();
        navigator.push(
          MaterialPageRoute(
            builder: (context) => QuoteGeneratorView(quote: quote),
          ),
        );
      },
      onUserEarnedReward: () {
        if (navigator.canPop()) navigator.pop();
        navigator.push(
          MaterialPageRoute(
            builder: (context) => QuoteGeneratorView(quote: quote),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Share Options',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'THOUGHTVAULT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 32),

          // Quote Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${quote.text}"',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
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
                backgroundColor: const Color(0xFFFF4081),
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
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).disabledColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
        trailing: traitWrapper
            ? const CircleAvatar(
                backgroundColor: AppColors.success,
                radius: 10,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              )
            : Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
      ),
    );
  }
}
