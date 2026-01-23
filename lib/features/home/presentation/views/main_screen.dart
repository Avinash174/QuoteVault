import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firestore_service.dart';
import '../views/home_view.dart';

import '../../../../features/profile/presentation/views/profile_view.dart';
import '../../../../features/library/presentation/views/library_view.dart';
import 'create_quote_view.dart';
import 'search_screen.dart';

import '../providers/bottom_nav_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Reset to Explore tab whenever MainScreen is loaded (e.g. after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavNotifierProvider.notifier).setIndex(0);
    });
    _updateUserStreak();
  }

  void _updateUserStreak() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().saveUser(user);
    }
  }

  final List<Widget> _screens = [
    const HomeView(), // Explore
    const SearchScreen(),
    const LibraryView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(bottomNavNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Main Content
            IndexedStack(index: currentIndex, children: _screens),

            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  // Gradient fade for the bottom area
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark ? Colors.black : AppColors.backgroundLight,
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Bottom Bar Background & Items
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).bottomNavigationBarTheme.backgroundColor,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildNavItem(
                              0,
                              Icons.explore_outlined,
                              Icons.explore,
                              'EXPLORE',
                              currentIndex,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              1,
                              Icons.search,
                              Icons.search,
                              'SEARCH',
                              currentIndex,
                            ),
                          ),
                          const SizedBox(width: 64), // Space for FAB
                          Expanded(
                            child: _buildNavItem(
                              2,
                              Icons.collections_bookmark_outlined,
                              Icons.collections_bookmark,
                              'LIBRARY',
                              currentIndex,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              3,
                              Icons.person_outline,
                              Icons.person,
                              'PROFILE',
                              currentIndex,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Diamond FAB
                    Positioned(
                      top: -20, // Push it up above the bar
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to Create Quote View
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateQuoteView(),
                            ),
                          );
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.fabGradientStart,
                                AppColors.fabGradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Rounded corners for "squircle"/diamond feel
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.fabGradientEnd.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          // Rotate the container to make it a diamond, then rotate child back if needed or just use icon
                          transform: Matrix4.rotationZ(
                            0.785398,
                          ), // 45 degrees in radians
                          transformAlignment: Alignment.center,
                          child: Transform.rotate(
                            angle: -0.785398, // Rotate icon back -45 degrees
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(bottomNavNotifierProvider.notifier).setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected
                ? AppColors.fabGradientStart
                : Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.fabGradientStart
                  : Theme.of(
                      context,
                    ).bottomNavigationBarTheme.unselectedItemColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
