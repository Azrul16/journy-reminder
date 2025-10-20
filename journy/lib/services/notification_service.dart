import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'journy_channel',
        channelName: 'Journy Notifications',
        channelDescription: 'Reminders and streak updates',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    ]);

    // Ask for permission on first launch
    bool allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> startProfileCompletionReminders() async {
    await AwesomeNotifications().cancelAll();

    await showInstant(
      id: 1,
      title: 'Welcome to Journy!',
      body: 'Complete your profile now to get started with your journey.',
    );

    // Schedule recurring notifications that work even when app is closed
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'journy_channel',
        title: 'Complete Your Profile!',
        body: 'Take a moment to complete your profile and unlock all features.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      schedule: NotificationInterval(
        interval: const Duration(minutes: 15),
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> stopAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'journy_channel',
        title: title,
        body: body,
      ),
    );
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'journy_channel',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar(hour: hour, minute: minute, repeats: true),
    );
  }

  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
