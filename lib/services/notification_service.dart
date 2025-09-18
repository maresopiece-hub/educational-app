import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter/material.dart';
import 'dart:math';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    // Initialize timezone database for scheduled notifications.
    try {
      tzdata.initializeTimeZones();
    } catch (_) {}
  }

  Future<void> showSimpleNotification(int id, String title, String body) async {
    const android = AndroidNotificationDetails('default', 'Default', importance: Importance.defaultImportance);
    const ios = DarwinNotificationDetails();
    await _plugin.show(id, title, body, const NotificationDetails(android: android, iOS: ios));
  }

  /// Schedule a daily nudge notification if the user's completion percent is
  /// below [progressThreshold]. The caller is expected to check the user's
  /// current percent and only call this when necessary, but this helper will
  /// schedule a repeating daily notification at 9am local time.
  Future<void> scheduleNudge(BuildContext context, int progressThreshold, String msg) async {
    // For simplicity, schedule a daily notification at 09:00 local time.
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    final id = Random().nextInt(1 << 31);
    const android = AndroidNotificationDetails('nudge', 'Nudges', importance: Importance.high);
    const ios = DarwinNotificationDetails();
    await _plugin.zonedSchedule(
      id,
      'Study reminder',
      msg,
      scheduled,
      const NotificationDetails(android: android, iOS: ios),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'nudge',
    );
  }
}
