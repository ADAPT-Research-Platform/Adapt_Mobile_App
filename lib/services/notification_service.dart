import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;

import 'localization_service.dart';

class NotificationService {
  static final log = Logger('NotificationService');

  static const int moodNotifyId = 1;
  static const TimeOfDay moodNotifyDefaultTime = TimeOfDay(hour: 8, minute: 0);

  static const String dailyNotificationTimeKey = 'daily_notification_time';
  static const String lastSubmittedTimeKey = 'last_submitted_time';

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iOSInitializationSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> updateMoodScheduledTime({ TimeOfDay? newScheduledTime, bool isSoundEnabled = true }) async {
    if (newScheduledTime != null) {
      setScheduledTime(newScheduledTime);
    }

    // Reschedule with the new Scheduled Time
    _scheduleNextNotification(
        moodNotifyId,
        LocalizationService().get("notification_title"),
        LocalizationService().get("notification_text"),
        isSoundEnabled: isSoundEnabled
    );
  }

  static Future<void> updateMoodLastSubmitTime() async {
    setLastSubmittedTime(tz.TZDateTime.now(tz.local));

    // Reschedule with the new Last Submitted Time
    _scheduleNextNotification(
        moodNotifyId,
        LocalizationService().get("notification_title"),
        LocalizationService().get("notification_text")
    );
  }

  static Future<void> toggleMuteNotifications(bool isMuted) async {
    if (isMuted) {
      await flutterLocalNotificationsPlugin.cancelAll();
      log.info('All notifications muted.');
    } else {
      await updateMoodScheduledTime();
      log.info('Notifications unmuted and rescheduled.');
    }
  }

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {
    log.info("Notification received: ${notificationResponse.id} ${notificationResponse.payload}");
    if(notificationResponse.id == moodNotifyId){
      updateMoodScheduledTime();
    }
  }

  //---------------------------- Private Methods -----------------------------//
  static Future<void> _scheduleNextNotification(int id, String title, String body, { bool isSoundEnabled = true }) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    log.info('Notification with id: $id canceled');

    final tz.TZDateTime scheduledTime = await _getNextNotificationTime();
    log.info('Next Notification Scheduled time: $scheduledTime');

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'adapt_notification_channel_id',
          'Adapt Notifications',
          channelDescription: 'Notifications that trigger daily at scheduled time',
          importance: Importance.max,
          priority: Priority.high,
          playSound: isSoundEnabled
        ),
        iOS: DarwinNotificationDetails(
            presentSound: isSoundEnabled
        )
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<tz.TZDateTime> _getNextNotificationTime() async {
    final lastSubmitted = await getLastSubmittedTime(tz.local);
    final scheduledTime = await getScheduledTime();

    final now = tz.TZDateTime.now(tz.local);

    // Scheduled time for today
    tz.TZDateTime scheduledToday = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (lastSubmitted != null && !lastSubmitted.isBefore(scheduledToday)) {
      // Case 1: lastSubmitted is today or later → schedule tomorrow
      scheduledToday = scheduledToday.add(const Duration(days: 1));
    } else if (scheduledToday.isBefore(now)) {
      // Case 2: scheduled time today already passed → schedule tomorrow
      scheduledToday = scheduledToday.add(const Duration(days: 1));
    }

    // Case 3: scheduled time today is still in future → keep today
    return scheduledToday;
  }

  //-------------------------- Secure Storage Operations ----------------------//

  // Save TimeOfDay
  static Future<void> setScheduledTime(TimeOfDay time) async {
    final formatted = '${time.hour}:${time.minute}';

    await secureStorage.write(key: dailyNotificationTimeKey, value: formatted);
  }

  // Retrieve TimeOfDay
  static Future<TimeOfDay> getScheduledTime() async {
    final storedTime = await secureStorage.read(key: dailyNotificationTimeKey);

    if (storedTime == null) {
      return moodNotifyDefaultTime; // Default 08:00 AM
    }

    try {
      final parts = storedTime.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return moodNotifyDefaultTime;
    }
  }

  // Save DateTime using standard ISO serialization
  static Future<void> setLastSubmittedTime(tz.TZDateTime dateTime) async {
    await secureStorage.write(
      key: lastSubmittedTimeKey,
      value: dateTime.toIso8601String(),
    );
  }

  // Retrieve DateTime safely
  static Future<tz.TZDateTime?> getLastSubmittedTime(tz.Location location) async {
    final storedTime = await secureStorage.read(key: lastSubmittedTimeKey);

    if (storedTime == null) return null;

    try {
      final dt = DateTime.parse(storedTime);
      return tz.TZDateTime.from(dt, location);
    } catch (_) {
      return null;
    }
  }
}