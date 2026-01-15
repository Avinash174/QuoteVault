import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../views/home_view.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(), // Explore
    const Center(
      child: Text('Search', style: TextStyle(color: Colors.white)),
    ),
    const Center(
      child: Text('Library', style: TextStyle(color: Colors.white)),
    ),
    const Center(
      child: Text('Profile', style: TextStyle(color: Colors.white)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          IndexedStack(index: _currentIndex, children: _screens),

          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                // Gradient fade for the bottom area
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.5],
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
                    decoration: const BoxDecoration(
                      color: AppColors
                          .background, // Match app background or slightly lighter
                      border: Border(
                        top: BorderSide(color: Colors.white10, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Side
                        _buildNavItem(
                          0,
                          Icons.explore_outlined,
                          Icons.explore,
                          'EXPLORE',
                        ),
                        _buildNavItem(1, Icons.search, Icons.search, 'SEARCH'),

                        const SizedBox(width: 48), // Space for FAB
                        // Right Side
                        _buildNavItem(
                          2,
                          Icons.collections_bookmark_outlined,
                          Icons.collections_bookmark,
                          'LIBRARY',
                        ),
                        _buildNavItem(
                          3,
                          Icons.person_outline,
                          Icons.person,
                          'PROFILE',
                        ),
                      ],
                    ),
                  ),

                  // Diamond FAB
                  Positioned(
                    top: -20, // Push it up above the bar
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Handle FAB action
                        debugPrint('FAB Tapped');
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
                              color: AppColors.fabGradientEnd.withOpacity(0.4),
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
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected
                ? AppColors.fabGradientStart
                : Colors.grey, // Active color matches FAB
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.fabGradientStart : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
