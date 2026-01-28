import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'dart:io';

class ForceUpdateView extends StatelessWidget {
  final bool allowSkip;
  final VoidCallback? onSkip;

  const ForceUpdateView({super.key, this.allowSkip = false, this.onSkip});

  // Play Store URL
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.avinashmagar.thoughtvault';

  Future<void> _launchStore() async {
    final Uri url = Uri.parse(_playStoreUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $_playStoreUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine strict theme colors manually or via context

    return PopScope(
      canPop: allowSkip, // Prevents back navigation unless allowed
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && allowSkip) {
          onSkip?.call();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon or Illustration
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  allowSkip ? "New Update Available" : "Time for an Upgrade!",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  allowSkip
                      ? "A new version of ThoughtVault is available. Update now to access the latest features and improvements."
                      : "We've made some significant changes to improve your experience. Please update the app to continue using ThoughtVault.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _launchStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "UPDATE NOW",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                if (allowSkip) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      "Skip for now",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],

                if (Platform.isIOS && !allowSkip) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Available on the App Store",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
