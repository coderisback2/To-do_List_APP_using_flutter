import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String sound = 'default',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'ToDo Reminders',
      channelDescription: 'Notification for task reminders',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(sound.toLowerCase().replaceAll(' ', '_')),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
