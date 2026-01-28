import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class IntroductionView extends ConsumerStatefulWidget {
  const IntroductionView({super.key});

  @override
  ConsumerState<IntroductionView> createState() => _IntroductionViewState();
}

class _IntroductionViewState extends ConsumerState<IntroductionView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      title: "Discover Wisdom",
      description:
          "Dive into a vast ocean of curated thoughts. Find inspiration, challenge your perspective, and ignite your daily motivation.",
      quoteText: "The only true wisdom is in knowing you know nothing.",
      quoteAuthor: "Socrates",
    ),
    const OnboardingSlide(
      title: "Your Personal Vault",
      description:
          "Save the quotes that resonate with your soul. Build a collection of timeless wisdom that stays with you, safe and sound.",
      quoteText:
          "Keep your face always toward the sunshine—and shadows will fall behind you.",
      quoteAuthor: "Walt Whitman",
    ),
    const OnboardingSlide(
      title: "Share the Light",
      description:
          "Inspire your community. Share profound insights seamlessly with friends and family, spreading the light of knowledge.",
      quoteText:
          "Happiness quite unshared can scarcely be called happiness; it has no taste.",
      quoteAuthor: "Charlotte Brontë",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Column(
                children: [
                  // Top Spacer
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),

                  // Quote Card Section (Replaces Image)
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child:
                            _MockQuoteCard(
                                  text: slide.quoteText,
                                  author: slide.quoteAuthor,
                                )
                                .animate(key: ValueKey('card_$index'))
                                .fadeIn(duration: 800.ms)
                                .scale(
                                  begin: const Offset(0.95, 0.95),
                                  end: const Offset(1.0, 1.0),
                                  duration: 1200.ms,
                                  curve: Curves.easeOut,
                                ),
                      ),
                    ),
                  ),

                  // Text Section
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                    letterSpacing: 0.5,
                                  ),
                                )
                                .animate(key: ValueKey('title_$index'))
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 16),
                            Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.8),
                                    height: 1.5,
                                  ),
                                )
                                .animate(key: ValueKey('desc_$index'))
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(
                              height: 80,
                            ), // Space for bottom controls
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip Button (Top Right)
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: TextButton(
                onPressed: () {
                  ref.read(onboardingProvider.notifier).completeOnboarding();
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                ),
                child: const Text("SKIP"),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: 500.ms,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        ref
                            .read(onboardingProvider.notifier)
                            .completeOnboarding();
                      }
                    },
                    child:
                        AnimatedContainer(
                              duration: 300.ms,
                              padding: EdgeInsets.symmetric(
                                horizontal: _currentPage == _slides.length - 1
                                    ? 32
                                    : 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_currentPage == _slides.length - 1) ...[
                                    const Text(
                                      "GET STARTED",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ] else ...[
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            )
                            .animate(
                              target: _currentPage == _slides.length - 1
                                  ? 1
                                  : 0,
                            )
                            .shimmer(duration: 1500.ms)
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              curve: Curves.easeInOut,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String quoteText;
  final String quoteAuthor;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.quoteText,
    required this.quoteAuthor,
  });
}

class _MockQuoteCard extends StatelessWidget {
  final String text;
  final String author;

  const _MockQuoteCard({required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardTheme = Theme.of(context).cardTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardTheme.color,
        borderRadius: (cardTheme.shape as RoundedRectangleBorder).borderRadius,
        border: Border.fromBorderSide(
          (cardTheme.shape as RoundedRectangleBorder).side,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote,
            size: 32,
            color: AppColors.accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '- $author',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white70
                        : AppColors.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildMockIcon(context, Icons.favorite_border, isDark),
                  const SizedBox(width: 8),
                  _buildMockIcon(
                    context,
                    Icons.collections_bookmark_outlined,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildMockIcon(context, Icons.share_outlined, isDark),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockIcon(BuildContext context, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.accent.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        color: isDark ? Colors.white : AppColors.textPrimaryLight,
        size: 20,
      ),
    );
  }
}
