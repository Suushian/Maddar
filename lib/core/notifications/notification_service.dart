import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:madaar/core/database/models.dart';
import 'package:timezone/timezone.dart' as tz;

/// یادآور محلی کاملاً روی دستگاه؛ هیچ اطلاعاتی از دستگاه خارج نمیشود.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int journalReminderId = 101;
  static const int focusReminderId = 102;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
    _initialized = true;
  }

  /// مجوز اعلان در اندروید ۱۳ به بالا را درخواست میکند.
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }
    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncSchedule(SettingsModel settings) async {
    await initialize();
    await _plugin.cancel(journalReminderId);
    await _plugin.cancel(focusReminderId);

    final String? time = settings.dailyReminderTime;
    if (time != null) {
      final List<String> parts = time.split(':');
      if (parts.length == 2) {
        final int? hour = int.tryParse(parts.first);
        final int? minute = int.tryParse(parts.last);
        if (hour != null &&
            minute != null &&
            hour >= 0 &&
            hour < 24 &&
            minute >= 0 &&
            minute < 60) {
          await _schedule(
            id: journalReminderId,
            title: 'مدار — یادداشت شبانه',
            body: 'سه خط بنویس و امروز را آرام تمام کن.',
            hour: hour,
            minute: minute,
          );
        }
      }
    }

    // یادآور ثابت تمرکزهای امروز، ساعت ۰۸:۰۰ به وقت تهران.
    await _schedule(
      id: focusReminderId,
      title: 'مدار — تمرکز امروز',
      body: 'سه کار مهم امروز را در مدار پین کن.',
      hour: 8,
      minute: 0,
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day, hour, minute);
    if (!date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
    }
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'madaar-reminders',
      'یادآورهای مدار',
      channelDescription: 'یادآور ژورنال و تمرکزهای امروز',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
