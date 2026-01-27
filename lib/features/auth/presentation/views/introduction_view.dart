import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/theme/app_colors.dart';

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
          "Explore a curated collection of thoughts that inspire, challenge, and enlighten.",
      imagePath: "assets/onboarding/discover.png",
      color: AppColors.accent,
    ),
    const OnboardingSlide(
      title: "Secure Your Vault",
      description:
          "Collect your favorite insights and keep them safe in your personal digital vault.",
      imagePath: "assets/onboarding/vault.png",
      color: AppColors.royalStart,
    ),
    const OnboardingSlide(
      title: "Connect & Share",
      description:
          "Spread the light of knowledge by sharing profound quotes with your community.",
      imagePath: "assets/onboarding/connect.png",
      color: AppColors.fabGradientStart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Column(
                children: [
                  Expanded(
                    flex: 6,
                    child:
                        Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(slide.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            .animate(key: ValueKey(index))
                            .fadeIn(duration: 800.ms)
                            .scale(
                              begin: const Offset(1.1, 1.1),
                              end: const Offset(1.0, 1.0),
                              duration: 1200.ms,
                              curve: Curves.easeOut,
                            ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                ),
                              )
                              .animate(key: ValueKey(index))
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 16),
                          Text(
                                slide.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondaryLight,
                                  height: 1.5,
                                ),
                              )
                              .animate(key: ValueKey(index))
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
                              ? AppColors.accent
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Action Button
                  ElevatedButton(
                        onPressed: () {
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
                          elevation: 8,
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? "GET STARTED"
                              : "NEXT",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                      .animate(
                        target: _currentPage == _slides.length - 1 ? 1 : 0,
                      )
                      .shimmer(duration: 1500.ms)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        curve: Curves.easeInOut,
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
  final String imagePath;
  final Color color;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}
