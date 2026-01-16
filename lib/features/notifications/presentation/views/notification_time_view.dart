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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Time',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Pick your daily spark',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose the moment you want QuoteVault to inspire you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const Spacer(),

            // Custom Clock/Time Picker placeholder
            // Building a full custom clock is complex, using standard TimePicker for functionality
            // but wrapping it or styling it could be good.
            // For now, let's display the time big and use standard picker on tap.
            GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.fabGradientStart,
                          onPrimary: Colors.white,
                          surface: AppColors.card,
                          onSurface: Colors.white,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.fabGradientStart,
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
                  // Clock Visual Placeholder (Static for now to match vibe)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background, // Inner dark
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.royalStart.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Clock face markers roughly
                        Positioned(
                          top: 20,
                          child: Text(
                            '12',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          child: Text(
                            '6',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          child: Text(
                            '9',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),

                        // Center dot
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Hand (Static Visual)
                        Transform.rotate(
                          angle: -0.5, // Just visual
                          child: Container(
                            width: 4,
                            height: 70,
                            margin: const EdgeInsets.only(bottom: 50),
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
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

            const Spacer(),

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
