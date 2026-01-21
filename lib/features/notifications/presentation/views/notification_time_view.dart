import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/notification_settings_viewmodel.dart';

class NotificationTimeView extends ConsumerStatefulWidget {
  const NotificationTimeView({super.key});

  @override
  ConsumerState<NotificationTimeView> createState() =>
      _NotificationTimeViewState();
}

class _NotificationTimeViewState extends ConsumerState<NotificationTimeView> {
  // We'll use local state for the interactive picker before saving
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);

  @override
  void initState() {
    super.initState();
    // Initialize with saved time if available
    final savedTimeAsync = ref.read(notificationSettingsViewModelProvider);
    if (savedTimeAsync.hasValue && savedTimeAsync.value != null) {
      _selectedTime = savedTimeAsync.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes to update UI if needed
    ref.listen(notificationSettingsViewModelProvider, (previous, next) {
      next.whenData((time) {
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      });
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Notification Time')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Pick your daily spark',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose the moment you want ThoughtVault to inspire you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              // Custom Clock/Time Picker placeholder
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark
                              ? const ColorScheme.dark(
                                  primary: AppColors.fabGradientStart,
                                  onPrimary: Colors.white,
                                  surface: AppColors.card,
                                  onSurface: Colors.white,
                                )
                              : const ColorScheme.light(
                                  primary: AppColors.accent,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppColors.textPrimaryLight,
                                ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? AppColors.fabGradientStart
                                  : AppColors.accent,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && picked != _selectedTime) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  }
                },
                child: Column(
                  children: [
                    // Clock Visual Placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardTheme.color,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 20,
                            child: Text(
                              '12',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Text(
                              '6',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            child: Text(
                              '9',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 20,
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Transform.rotate(
                            angle: -0.5,
                            child: Container(
                              width: 4,
                              height: 70,
                              margin: const EdgeInsets.only(bottom: 50),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.card
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAmPmToggle(
                            'AM',
                            _selectedTime.period == DayPeriod.am,
                          ),
                          _buildAmPmToggle(
                            'PM',
                            _selectedTime.period == DayPeriod.pm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(notificationSettingsViewModelProvider.notifier)
                        .setNotificationTime(_selectedTime);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification preference saved!'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Preference',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmPmToggle(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
