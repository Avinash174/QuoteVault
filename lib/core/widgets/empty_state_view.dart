import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../theme/app_colors.dart';

class EmptyStateView extends StatelessWidget {
  final String? message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateView({
    super.key,
    this.message,
    this.onAction,
    this.actionLabel,
  });

  static const List<String> _interestingMessages = [
    "The vault is silent, waiting for your next big thought.",
    "Even the greatest minds take breaks. Your feed will be back soon.",
    "Searching for wisdom... meanwhile, why not create your own?",
    "A blank canvas for your imagination. Add a thought!",
    "Quiet moments often lead to the loudest realizations.",
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayMessage =
        message ??
        _interestingMessages[Random().nextInt(_interestingMessages.length)];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: 64,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 2000.ms,
                  color: AppColors.accent.withValues(alpha: 0.2),
                )
                .shake(hz: 2, curve: Curves.easeInOut),
            const SizedBox(height: 32),
            Text(
              "Nothing here yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  actionLabel ?? "Create Change",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
            ],
          ],
        ),
      ),
    );
  }
}
