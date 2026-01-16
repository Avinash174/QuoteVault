import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';

final notificationSettingsViewModelProvider =
    StateNotifierProvider<
      NotificationSettingsViewModel,
      AsyncValue<TimeOfDay?>
    >((ref) {
      return NotificationSettingsViewModel();
    });

class NotificationSettingsViewModel
    extends StateNotifier<AsyncValue<TimeOfDay?>> {
  NotificationSettingsViewModel() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  static const String _timeKey = 'notification_time';
  final NotificationService _notificationService = NotificationService();

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_timeKey);

      if (timeString != null) {
        final parts = timeString.split(':');
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        state = AsyncValue.data(time);
      } else {
        // Default to not set or a default time
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_timeKey, '${time.hour}:${time.minute}');

      // Schedule the notification
      await _notificationService.requestPermissions();
      await _notificationService.scheduleDailyNotification(
        time.hour,
        time.minute,
      );

      state = AsyncValue.data(time);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Optional: Toggle enabled/disabled logic if we want strictly on/off without clearing time
}
