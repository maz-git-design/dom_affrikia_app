import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initBackgroundTask() async {
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final raw = await secureStorage.read(key: 'backgroundPeriod');
  final parsed = int.tryParse(raw ?? '');
  final seconds = (parsed == null || parsed <= 0) ? 5 : parsed;
  final repeatMillis = seconds * 1000;

  await secureStorage.write(key: 'backgroundPeriod', value: seconds.toString());

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'affrikia_notification',
      channelName: 'afrrikia_notification_channel',
      channelDescription: 'Run background notification',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      enableVibration: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
      eventAction: ForegroundTaskEventAction.repeat(repeatMillis),
    ),
  );
}
