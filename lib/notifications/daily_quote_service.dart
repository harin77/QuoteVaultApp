import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/supabase_client.dart';
import '../core/constants.dart';
import '../quotes/quote_model.dart';
import '../quotes/quote_service.dart';

/// Service for daily quotes and notifications
class DailyQuoteService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  /// Get daily quote (deterministic based on date)
  static Future<Quote?> getDailyQuote() async {
    try {
      final quotes = await QuoteService.fetchQuotes();
      if (quotes.isEmpty) return null;

      // Use date as seed for deterministic selection
      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      final random = Random(seed);
      final index = random.nextInt(quotes.length);

      return quotes[index];
    } catch (e) {
      return null;
    }
  }

  /// Schedule daily notification
  static Future<void> scheduleDailyNotification(String time) async {
    try {
      await _notifications.cancelAll();

      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      const androidDetails = AndroidNotificationDetails(
        'daily_quote_channel',
        'Daily Quote',
        channelDescription: 'Daily inspirational quote notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        0,
        'Your Daily Quote',
        'Tap to see today\'s inspiration',
        _nextInstanceOfTime(hour, minute),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      throw Exception('Failed to schedule notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get next instance of specified time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
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

  /// Show notification immediately (for testing)
  static Future<void> showNotification(Quote quote) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quote',
      channelDescription: 'Daily inspirational quote notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Your Daily Quote',
      '${quote.text.substring(0, quote.text.length > 50 ? 50 : quote.text.length)}... - ${quote.author}',
      notificationDetails,
    );
  }
}
