import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_settings.dart';
import '../utils/quotes_helper.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize notifications
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    _initialized = true;
  }

  // Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Schedule daily reminder
  static Future<void> scheduleDailyReminder(AppSettings settings) async {
    if (!settings.notificationsEnabled) {
      await cancelAll();
      return;
    }

    await initialize();

    // Get motivational message based on style
    String message;
    switch (settings.motivationStyle) {
      case 0: // Short Tips
        message = 'Stay locked in. Check your goals! 💪';
        break;
      case 1: // Quotes
        message = QuotesHelper.getRandomQuote();
        break;
      case 2: // Custom
        message = 'Time to work on your arc! 🎯';
        break;
      default:
        message = 'Stay locked in. Check your goals! 💪';
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Daily motivation and goal reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule notification
    await _notifications.zonedSchedule(
      0, // Notification ID
      'Winter Arc Challenge 🎯',
      message,
      _nextInstanceOfTime(settings.notificationHour, settings.notificationMinute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Get next instance of time
  static TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Send immediate notification (for testing or special events)
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'instant',
      'Instant Notifications',
      channelDescription: 'Immediate notifications for special events',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Show completion celebration notification
  static Future<void> showCompletionCelebration() async {
    await showNotification(
      title: '🎉 All Goals Complete!',
      body: 'Amazing work! You conquered today\'s challenges!',
    );
  }

  // Show streak milestone notification
  static Future<void> showStreakMilestone(int streak) async {
    await showNotification(
      title: '🔥 $streak-Day Streak!',
      body: 'You\'re on fire! Keep the momentum going!',
    );
  }
}

// Timezone support (required for scheduling)
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Initialize timezone
TZDateTime get local => tz.TZDateTime.now(tz.local);

class TZDateTime extends tz.TZDateTime {
  TZDateTime(tz.Location location, int year,
      [int month = 1, int day = 1, int hour = 0, int minute = 0])
      : super(location, year, month, day, hour, minute);

  static TZDateTime now(tz.Location location) {
    return TZDateTime.fromMillisecondsSinceEpoch(location, DateTime.now().millisecondsSinceEpoch);
  }

  static TZDateTime fromMillisecondsSinceEpoch(tz.Location location, int milliseconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return tz.TZDateTime.from(dateTime, location) as TZDateTime;
  }
}

void initializeTimezones() {
  tz.initializeTimeZones();
}
