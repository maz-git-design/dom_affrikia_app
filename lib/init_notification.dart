import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    log('notification payload: $payload');
  }
}

initNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final WindowsInitializationSettings initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Flutter Local Notifications Example',
      appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
      // Search online for GUID generators to make your own
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
}
