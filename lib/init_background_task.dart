import 'package:flutter_foreground_task/flutter_foreground_task.dart';

initBackgroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'affrikia_notification',
      channelName: 'afrrikia_notification_channel',
      channelDescription: 'Runs background notification',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      enableVibration: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
      eventAction: ForegroundTaskEventAction.repeat(5000),
    ),
  );
}
