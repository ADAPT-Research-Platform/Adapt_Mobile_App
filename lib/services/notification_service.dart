import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/app_routes.dart';
import 'localization_service.dart';

class NotificationService {
  static final log = Logger('NotificationService');

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

    if(!await secureStorage.containsKey(key: notificationMuteKey)){
      await setBool(notificationMuteKey, false);
    }

    if(!await secureStorage.containsKey(key: notificationSoundKey)){
      await setBool(notificationSoundKey, true);
    }
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

  static Future<void> toggleMuteNotifications(bool value) async {
    await setBool(notificationMuteKey, value);

    if (value) {
      await flutterLocalNotificationsPlugin.cancelAll();
      log.info('All notifications muted');
    } else {
      scheduleNextMoodNotification();
      log.info('Notifications unmuted and rescheduled');
    }
  }

  static Future<void> toggleSoundNotifications(bool value) async {
    await setBool(notificationSoundKey, value);
    log.info('Notification Sound Enable: $value');

    // If sound is disabled)
    scheduleNextMoodNotification();
  }

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {
    log.info("Notification tapped: ${notificationResponse.id}");

    scheduleNextMoodNotification();
  }

  static Future<void> scheduleNextMoodNotification() async {
    final pNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (final pNotification in pNotifications) {
      await flutterLocalNotificationsPlugin.cancel(pNotification.id);
      log.info('Cancelled pending notification with ID: ${pNotification.id}');
    }

    _scheduleNextNotification(
        LocalizationService().get("notification_title"),
        LocalizationService().get("notification_text")
    );
  }

  //---------------------------- Private Methods -----------------------------//
  static Future<void> _scheduleNextNotification(String title, String body) async {
    if (await getBool(notificationMuteKey)) return;

    final tz.TZDateTime sTime = await _getNextNotificationTime();

    // Generate a unique ID based on the date (e.g., 20251017).
    final int uniqueId = int.parse('${sTime.year}${sTime.month.toString().padLeft(2, '0')}${sTime.day.toString().padLeft(2, '0')}');
    log.info('Scheduling Next Notification ID: $uniqueId Time: $sTime');

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      uniqueId,
      title,
      body,
      sTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'adapt_notification_channel_id',
          'Adapt Notifications',
          channelDescription: 'Notifications that trigger daily at scheduled time',
          importance: Importance.max,
          priority: Priority.high,
          playSound: await getBool(notificationSoundKey)
        ),
        iOS: DarwinNotificationDetails(
            presentSound: await getBool(notificationSoundKey)
        )
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<tz.TZDateTime> _getNextNotificationTime() async {
    final lastSubmittedTime = await getLastSubmittedTime();
    final scheduledTime = await getScheduledTime();
    log.info('Last Submitted Time: $lastSubmittedTime Scheduled Time: $scheduledTime');

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
  static Future<tz.TZDateTime?> getLastSubmittedTime() async {
    final storedTime = await secureStorage.read(key: lastSubmittedTimeKey);

    if (storedTime == null) return null;

    try {
      final dt = DateTime.parse(storedTime);
      return tz.TZDateTime.from(dt, tz.local);
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