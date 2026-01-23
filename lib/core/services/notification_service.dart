import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../data/models/quote_model.dart';
import '../../data/services/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    await requestPermissions();
    tz_data.initializeTimeZones();

    // 1. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    // Create the channel on the device (if we haven't already)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 2. Initialize Firebase Messaging
    await _initFCM();
  }

  Future<void> _initFCM() async {
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle background messages via specialized handler (usually in main.dart)

    // Get the token (for debugging/backend registration)
    try {
      String? token = await _fcm.getToken();
      developer.log(
        "🔥🔥 FCM Token: $token",
        name: 'ThoughtVault.Notification',
      );
    } catch (e) {
      developer.log(
        "Error getting FCM token: $e",
        name: 'ThoughtVault.Notification',
        error: e,
      );
    }
  }

  Future<void> requestPermissions() async {
    // Local notification permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // FCM permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _showLocalNotification(RemoteMessage message) async {
    // Try to get title & body from notification payload, fallback to data payload
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];

    // If we have no content, we can't show a meaningful notification
    if (title == null && body == null) return;

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    await flutterLocalNotificationsPlugin.show(
      notification?.hashCode ?? message.messageId.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          // Explicitly use launcher_icon if not provided in payload
          icon: android?.smallIcon ?? '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> scheduleDailyNotification(int hour, int minute) async {
    final ApiService apiService = ApiService();
    Quote? quote;
    try {
      quote = await apiService.getQuoteOfTheDay();
    } catch (_) {
      // Fallback if API fails
      quote = null;
    }

    const String title = 'Quote of the Day';
    final String body = quote != null
        ? '"${quote.text}" - ${quote.author}'
        : 'Time for your daily spark of inspiration!';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quote_channel',
          'Daily Quotes',
          channelDescription: 'Daily notification for Quote of the Day',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
