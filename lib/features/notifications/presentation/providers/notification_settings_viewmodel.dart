import 'dart:developer' as developer;
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
  static const String _enabledKey = 'notifications_enabled';
  final NotificationService _notificationService = NotificationService();

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_timeKey);
      final isEnabled = prefs.getBool(_enabledKey) ?? true;

      TimeOfDay? time;
      if (timeString != null) {
        final parts = timeString.split(':');
        time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        time = const TimeOfDay(hour: 8, minute: 30); // Default
      }

      state = AsyncValue.data(time);

      // If enabled, ensure they are scheduled
      if (isEnabled) {
        await _notificationService.scheduleDailyNotification(
          time.hour,
          time.minute,
        );
      } else {
        await _notificationService.cancelDailyNotification();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool get isNotificationsEnabled {
    // We don't store enabled status in state directly, let's use shared prefs or state.
    // For simplicity, let's assume if it's in data, we can check a separate provider or this one.
    // Let's add a separate provider for enabled status to make it easier for settings view.
    return true; // Placeholder
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

  Future<void> toggleNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);

      if (enabled) {
        final time = state.value ?? const TimeOfDay(hour: 8, minute: 30);
        await _notificationService.scheduleDailyNotification(
          time.hour,
          time.minute,
        );
      } else {
        await _notificationService.cancelDailyNotification();
      }
      // Re-trigger load to refresh all listeners if needed,
      // or just trust the local storage update.
    } catch (e) {
      developer.log("Error toggling notifications", error: e);
    }
  }
}

final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notifications_enabled') ?? true;
});
