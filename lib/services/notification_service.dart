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
  static const String notificationSoundKey = 'notification_sound';
  static const String notificationMuteKey = 'notification_mute';

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    )
  );

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

    await setBool(notificationMuteKey, false);
    await setBool(notificationSoundKey, true);
  }

  static Future<void> updateMoodScheduledTime(TimeOfDay newScheduledTime) async {
    setScheduledTime(newScheduledTime);

    // Reschedule with the new Scheduled Time
    scheduleNextMoodNotification();
  }

  static Future<void> updateMoodLastSubmitTime() async {
    setLastSubmittedTime(tz.TZDateTime.now(tz.local));

    // Reschedule with the new Last Submitted Time
    scheduleNextMoodNotification();
  }

  static Future<void> toggleMuteNotifications() async {
    await setBool(notificationMuteKey, !await getBool(notificationMuteKey));

    if (await getBool(notificationMuteKey)) {
      await flutterLocalNotificationsPlugin.cancelAll();
      log.info('All notifications muted.');
    } else {
      scheduleNextMoodNotification();
      log.info('Notifications unmuted and rescheduled.');
    }
  }

  static Future<void> toggleSoundNotifications() async {
    await setBool(notificationSoundKey, !await getBool(notificationSoundKey));
    log.info('Notification Sound Enable: ${await getBool(notificationSoundKey)}');

    // If sound is disabled)
    scheduleNextMoodNotification();
  }

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {
    log.info("Notification received: ${notificationResponse.id} ${notificationResponse.payload}");
    if(notificationResponse.id == moodNotifyId){
      scheduleNextMoodNotification();
    }
  }

  static Future<void> scheduleNextMoodNotification() async {
    _scheduleNextNotification(
        moodNotifyId,
        LocalizationService().get("notification_title"),
        LocalizationService().get("notification_text"),
        await getBool(notificationSoundKey)
    );
  }

  //---------------------------- Private Methods -----------------------------//
  static Future<void> _scheduleNextNotification(int id, String title, String body, bool isSoundEnabled) async {
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
    final lastSubmittedTime = await getLastSubmittedTime(tz.local);
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

    if (lastSubmittedTime != null && scheduledToday.difference(lastSubmittedTime).inDays < 1) {
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
    log.info('Notification ScheduledTime Saved: $formatted');
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
    await secureStorage.write(key: lastSubmittedTimeKey, value: dateTime.toString());
    log.info('Notification LastSubmittedTime Saved: ${dateTime.toString()}');
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

  // Save boolean value by key
  static Future<void> setBool(String key, bool value) async {
    await secureStorage.write(key: key, value: value.toString());
  }

  // Read boolean value by key
  static Future<bool> getBool(String key) async {
    final value = await secureStorage.read(key: key);
    return value?.toLowerCase() == 'true';
  }
}