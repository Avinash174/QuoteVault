import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/stats_provider.dart';

class EditGoalView extends ConsumerStatefulWidget {
  const EditGoalView({super.key});

  @override
  ConsumerState<EditGoalView> createState() => _EditGoalViewState();
}

class _EditGoalViewState extends ConsumerState<EditGoalView> {
  int _currentGoal = 10;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    // Watch the current stats to initialize
    final statsAsync = ref.watch(userStatsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize with current value once
    if (!_initialized && statsAsync.hasValue) {
      _currentGoal = statsAsync.value!.dailyGoal;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Daily Reading Goal',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              '$_currentGoal',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            Text(
              'QUOTES PER DAY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'Set your daily target',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIncrementButton(
                        icon: Icons.remove,
                        onPressed: () {
                          setState(() {
                            if (_currentGoal > 1) _currentGoal--;
                          });
                        },
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: AppColors.accent.withValues(
                              alpha: 0.2,
                            ),
                            thumbColor: Colors.white,
                            overlayColor: AppColors.accent.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: _currentGoal.toDouble(),
                            min: 1,
                            max: 50,
                            divisions: 49,
                            onChanged: (value) {
                              setState(() => _currentGoal = value.round());
                            },
                          ),
                        ),
                      ),
                      _buildIncrementButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() {
                            if (_currentGoal < 50) _currentGoal++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(userStatsNotifierProvider.notifier)
                      .updateDailyGoal(_currentGoal);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
