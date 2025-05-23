// The callback function should always be a top-level or static function.
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/core/config/config.dart';
import 'package:dom_affrikia_app/core/entities/app_update_info.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end_repo_call.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_broadcasts_plus/flutter_broadcasts.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

// void startMyBackgroundTask() async {
//   var phoneState = await MyTaskHandler._secureStorage.read(key: "phoneState");
//   var message = "Bloqué";
//   if (phoneState != null) {
//     message = getPhoneStatusFromStateString(phoneState);
//   }
//   FlutterForegroundTask.startService(
//     notificationTitle: 'Bienvenu chez afrikia',
//     notificationText: "Votre téléphone est à l'état $message",
//     notificationIcon: const NotificationIcon(
//       metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
//       backgroundColor: Color.fromRGBO(253, 172, 19, 1),
//     ),
//     callback: startCallback,
//   );
// }

Future<ServiceRequestResult> startService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    var phoneState = await MyTaskHandler._secureStorage.read(key: "phoneState");
    var message = "Bloqué";
    if (phoneState != null) {
      message = getPhoneStatusFromStateString(phoneState);
    }
    return FlutterForegroundTask.startService(
      // You can manually specify the foregroundServiceType for the service
      // to be started, as shown in the comment below.
      // serviceTypes: [
      //   ForegroundServiceTypes.dataSync,
      //   ForegroundServiceTypes.remoteMessaging,
      // ],
      serviceId: 256,
      notificationTitle: 'Bienvenu chez afrikia',
      notificationText: "Votre téléphone est à l'état $message",
      notificationIcon: const NotificationIcon(
        metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
        backgroundColor: Color.fromRGBO(253, 172, 19, 1),
      ),
      notificationInitialRoute: '/',
      callback: startCallback,
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  StreamSubscription? _downloadSubscription;

  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  static final InternetConnectionChecker internetConnectionChecker = InternetConnectionChecker.createInstance();
  StreamSubscription<TaskUpdate>? downloadListener;

  static final Options options = Options(headers: {'Content-Type': 'application/json', 'deviceTypeId': '1'});
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_URL,
      connectTimeout: const Duration(seconds: 60000),
      receiveTimeout: const Duration(seconds: 60000),
    ),
  );

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    //await init();

    //initNotifications();
    log('onStart(starter: ${starter.name})');
  }

  Future<void> sendStatustoServer() async {
    var hasStatusToSend = await _secureStorage.read(key: "hasDataToSend");

    var isConnected = await internetConnectionChecker.hasConnection;
    var phoneState = await _secureStorage.read(key: "phoneState");

    if (hasStatusToSend != null && hasStatusToSend == "1" && isConnected && phoneState != null) {
      var deviceId = await _secureStorage.read(key: "phoneIMEI");
      var status = getPhoneServerStatusFromStateString(phoneState);
      options.headers?["deviceId"] = deviceId;
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => _dio.put('/device/updateDeviceStatus?status=$status', options: options),
          (json) => json,
        ),
        internetConnectionChecker.hasConnection,
      );

      response.fold(
        (failure) => log(failure.toString(), name: "send status to server"),
        (json) async {
          if (json['ok']) {
            await _secureStorage.write(key: "hasDataToSend", value: "0");
            log("status data sent to server");
          } else {
            log("error sending data status");
          }
        },
      );
    }
  }

  Future<void> checkUpdate() async {
    var updateStatus = await _secureStorage.read(key: "updateStatus");
    if (updateStatus == null) {
      await _secureStorage.write(key: "updateStatus", value: "NoUpdate");
    }

    var isConnected = await internetConnectionChecker.hasConnection;

    if (isConnected && (updateStatus == "NoUpdate" || updateStatus == "UpdateInstalled")) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => _dio.get('/common/getUpgradeInfo?version=${packageInfo.buildNumber}', options: options),
          (json) => json,
        ),
        internetConnectionChecker.hasConnection,
      );

      response.fold(
        (failure) => log(failure.toString(), name: "get package info"),
        (json) async {
          if (json['ok']) {
            if (json['data'] != null) {
              var upgradeInfo = AppUpdateInfo.fromJson(json['data']);

              if (upgradeInfo.updateInstall == 1) {
                await _secureStorage.write(key: "updateInfo", value: upgradeInfo.toString());
                await _secureStorage.write(key: "updateStatus", value: "HasUpdate");
                final Map<String, dynamic> data = {
                  "updateStatus": "HasUpdate",
                };
                FlutterForegroundTask.sendDataToMain(data);
              } else {
                log("no force update available");
              }
            }
          } else {
            log("no update available");
          }
        },
      );
    }
  }

  Future<void> overDueHandler() async {
    var hasOverdue = await hasOverdueBill();
    log("Has overdue bill: $hasOverdue");

    if (hasOverdue != null && hasOverdue) {
      // Enable kiosk mode
      var phoneState = await _secureStorage.read(key: "phoneState");

      if (phoneState != null && phoneState == "1") {
        if (Platform.isAndroid) {
          const intent = AndroidIntent(
            action: 'com.example.dom_affrikia_app.ACTION_ADMIN',
            package: 'com.example.dom_affrikia_app',
            componentName: 'com.example.dom_affrikia_app.AdminActionReceiver',
            arguments: {'action': 'enableKioskMode'},
          );

          await intent.sendBroadcast();
          await _secureStorage.write(key: "phoneState", value: "0");
        }

        await _secureStorage.write(key: "hasDataToSend", value: "1");
        final Map<String, dynamic> data = {
          "phoneState": 0,
        };
        FlutterForegroundTask.sendDataToMain(data);
        await changeNotificationStatus(0);

        // send overdue to server
        await sendStatustoServer();
      }
    }
  }

  Future<void> updateNofification() async {
    var upcoming = await getUpcomingOverdueBillsWithin7Days();
    var phoneState = await _secureStorage.read(key: "phoneState");
    if (upcoming.isNotEmpty && phoneState != null && phoneState == "1") {
      var firstUpcoming = upcoming.first;

      var bill = firstUpcoming["bill"] as Bill;
      var daysLeft = firstUpcoming["remainingDays"];
      var hoursLeft = firstUpcoming["remainingHours"];
      var minutesLeft = firstUpcoming["remainingMinutes"];
      var secondsLeft = firstUpcoming["remainingSeconds"];
      // Send notification to the user
      FlutterForegroundTask.updateService(
        notificationTitle: 'Bienvenu chez afrikia',
        notificationText:
            "Votre facture ${bill.billNo} d'un montant de ${bill.billAmount} GNF va dépasser l'échéance de paiement dans $daysLeft j, $hoursLeft h, $minutesLeft min, et $secondsLeft s . Merci de payer avant le ${DateFormat('dd-MM-yyyy').format(bill.overdueTime!)}, sinon le téléphone sera bloqué.",
        // notificationButtons: [
        //   const NotificationButton(id: 'btn_hello', text: 'OK'),
        // ],
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
          backgroundColor: Color.fromRGBO(253, 172, 19, 1),
        ),
      );
    }
  }

  Future<void> changeNotificationStatus(int? newPhoneState) async {
    if (newPhoneState != null && newPhoneState == 1) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Bienvenu chez afrikia',
        notificationText:
            "Votre téléphone est à l'état Activé partiellement. Payez toutes les factures pour une activation complète.",
        // notificationButtons: [
        //   const NotificationButton(id: 'btn_hello', text: 'OK'),
        // ],
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
          backgroundColor: Color.fromRGBO(253, 172, 19, 1),
        ),
      );
    } else if (newPhoneState != null && newPhoneState == 2) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Bienvenu chez afrikia',
        notificationText:
            "Bravo! Votre téléphone est à présent complètement activé. Vous pouvez l'utiliser avec toutes ses fonctionnalités",
        // notificationButtons: [
        //   const NotificationButton(id: 'btn_hello', text: 'OK'),
        // ],
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
          backgroundColor: Color.fromRGBO(253, 172, 19, 1),
        ),
      );

      await Future.delayed(const Duration(hours: 1));
      await stopService();
    } else {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Bienvenu chez afrikia',
        notificationText: "Votre téléphone est à l'état Bloqué. Veuillez payer vos factures pour le débloquer.",
        // notificationButtons: [
        //   const NotificationButton(id: 'btn_hello', text: 'OK'),
        // ],
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
          backgroundColor: Color.fromRGBO(253, 172, 19, 1),
        ),
      );
    }
  }

  Future<void> downloadHandler() async {
    var updateStatus = await _secureStorage.read(key: "updateStatus");
    if (updateStatus != null && updateStatus == "HasUpdate") {
      var updateInfoString = await _secureStorage.read(key: "updateInfo");
      var updateInfo = AppUpdateInfo.fromString(updateInfoString!);
      FileDownloader().trackTasks(); //
      _downloadSubscription?.cancel(); // cancel the previous download if any
      _downloadSubscription = FileDownloader().updates.listen((update) async {
        try {
          switch (update) {
            case TaskStatusUpdate():
              // process the TaskStatusUpdate, e.g.
              switch (update.status) {
                case TaskStatus.complete:
                  var filePath = await update.task.filePath();
                  log('Task ${update.task.taskId} path: ${update.task.baseDirectory} $filePath');
                  await _secureStorage.write(key: "lastApkFilePath", value: filePath);
                  await _secureStorage.write(key: "updateStatus", value: "UpdateDownloaded");
                  final Map<String, dynamic> data = {
                    "updateStatus": "UpdateDownloaded",
                  };
                  FlutterForegroundTask.sendDataToMain(data);
                  await sendApkToBroadcastReceiver(filePath);

                  var taskIds = await FileDownloader().allTaskIds();
                  await FileDownloader().cancelTasksWithIds(taskIds);
                  _downloadSubscription?.cancel();
                  FileDownloader().destroy();

                  //startApkInstallReceiver();
                  break;
                case TaskStatus.paused:
                  log('Download was paused');
                  break;
                case TaskStatus.running:
                  // await _secureStorage.write(key: "updateStatus", value: "UpdateDownloading");
                  // final Map<String, dynamic> data = {
                  //   "updateStatus": "UpdateDownloading",
                  // };
                  // FlutterForegroundTask.sendDataToMain(data);
                  log('Download is running');
                  break;
                case TaskStatus.enqueued:
                  await _secureStorage.write(key: "updateStatus", value: "UpdateDownloading");
                  final Map<String, dynamic> data = {
                    "updateStatus": "UpdateDownloading",
                  };
                  FlutterForegroundTask.sendDataToMain(data);
                  log('Download enqueued');
                  break;
                case TaskStatus.failed:
                  await _secureStorage.write(key: "updateStatus", value: "HasUpdate");
                  final Map<String, dynamic> data = {
                    "updateStatus": "HasUpdate",
                  };
                  FlutterForegroundTask.sendDataToMain(data);
                  log('Download failed');
                  break;
                case TaskStatus.canceled:
                  await _secureStorage.write(key: "updateStatus", value: "HasUpdate");
                  final Map<String, dynamic> data = {
                    "updateStatus": "HasUpdate",
                  };
                  FlutterForegroundTask.sendDataToMain(data);
                  log('Download canceled');
                  break;
                default:
                  log('Status not configured ${update.status}');
              }

            case TaskProgressUpdate():
              // process the TaskProgressUpdate, e.g.
              log("progress: ${update.progress}");
              log("taskId ${update.task.taskId}");
              FlutterForegroundTask.sendDataToMain({
                "progress": update.progress,
                "timeRemaining": update.timeRemainingAsString,
                "hasTimeRemaining": update.hasTimeRemaining,
                "hasExpectedSize": update.hasExpectedFileSize,
                "expectedSize": update.expectedFileSize,
              });
          }
        } catch (e, stack) {
          log('Exception in update listener: $e\n$stack');
          await _secureStorage.write(key: "updateStatus", value: "HasUpdate");
          FlutterForegroundTask.sendDataToMain({
            "updateStatus": "HasUpdate",
            "error": e.toString(),
          });
        }
      });
      FileDownloader().start();

      var taskQueues = FileDownloader().taskQueues;
      log('Task queues: $taskQueues');
      if (taskQueues.isEmpty) {
        final successfullyEnqueued = await FileDownloader().enqueue(
          DownloadTask(
            url: updateInfo.url!,
            filename: updateInfo.title,
            updates: Updates.statusAndProgress,
            retries: 5,
          ),
        );
        log('Download enqueued: $successfullyEnqueued');
      }
    } else if (updateStatus != null && updateStatus == "UpdateInstallError") {
      var filePath = await _secureStorage.read(key: "lastApkFilePath");
      final fileExist = await checkAfrrikiaApkExist(filePath!);

      if (fileExist != null && fileExist) {
        await sendApkToBroadcastReceiver(filePath);
      } else {
        await _secureStorage.write(key: "updateStatus", value: "NoUpdate");
      }
    }
  }

  Future<void> updateApkHandler() async {
    var filePath = await _secureStorage.read(key: "lastApkFilePath");
    if (filePath != null) {
      var fileExist = await checkAfrrikiaApkExist(filePath);

      if (fileExist != null && fileExist) {
        var updateStatus = await _secureStorage.read(key: "updateStatus");
        if (updateStatus != "UpdateInstallError") {
          await deleteAfrrikiaApk(filePath);
        }
        return;
      } else {
        await downloadHandler();
      }
    } else {
      await downloadHandler();
    }
  }

  Future<void> deleteAfrrikiaApk(String filePath) async {
    try {
      // Get the app's documents directory
      //final dir = await getApplicationDocumentsDirectory();

      // Create a reference to the file
      final file = File(filePath);

      // Check if file exists
      if (await file.exists()) {
        await file.delete();
        log('File deleted successfully.');
      } else {
        log('File does not exist.');
      }
    } catch (e) {
      log('Error while deleting the file: $e');
    }
  }

  Future<bool?> checkAfrrikiaApkExist(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (await file.exists()) {
        log('File deleted successfully.');
        return true;
      } else {
        log('File does not exist.');
        return false;
      }
    } catch (e) {
      log('Error while deleting the file: $e');
      return null;

      //rethrow;
    }
  }

  Future<void> sendApkToBroadcastReceiver(String filePath) async {
    log('Sending APK path to BroadcastReceiver: $filePath');
    final intent = AndroidIntent(
      action: 'com.example.dom_affrikia_app.APK_INSTALL_TRIGGERED',
      package: 'com.example.dom_affrikia_app',
      componentName: 'com.example.dom_affrikia_app.ApkInstallReceiver',
      arguments: {'apkPath': filePath},
    );

    try {
      await intent.sendBroadcast();
      log('✅ Broadcast sent with APK path');
    } catch (e) {
      log('❌ Failed to send broadcast: $e');
    }
  }

  Future<void> checkAppOpenWhenPhoneBlock() async {
    var appState = await FlutterForegroundTask.isAppOnForeground;
    var phoneState = await _secureStorage.read(key: "phoneState");

    log("Phone state: $phoneState");
    log("App is on foreground: $appState");
    if (!appState && (phoneState == null || phoneState == "0")) {
      log("App is not on foreground and phone is blocked");
      FlutterForegroundTask.launchApp();
    }
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    log('onRepeatEvent(timestamp: $timestamp)');

    await checkAppOpenWhenPhoneBlock();
    // Check for overdue bills and block the phone if any are found
    await overDueHandler();
    // Send status of device to server
    await sendStatustoServer();
    // Update notifications
    await updateNofification();
    // Check for new updates
    await checkUpdate();
    // Update APK if available
    await updateApkHandler();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('onDestroy(destroyed at: $timestamp)');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) async {
    log('onReceiveData: $data');

    // You can cast it to any type you want using the Collection.cast<T> function.
    if (data is Map<String, dynamic>) {
      if (data.containsKey("phoneState")) {
        final dynamic newPhoneState = data["phoneState"];
        changeNotificationStatus(newPhoneState);
      } else if (data.containsKey('apk_event')) {
        final event = data['apk_event'];
        // log("data received from ForegroundService: $data");
        // log('ForegroundService received event: $event');
        if (event == "com.example.dom_affrikia_app.APK_INSTALL_STARTED") {
          await _secureStorage.write(key: "updateStatus", value: "UpdateInstalling");
          final Map<String, dynamic> dataToSend = {
            "installStatus": data['status'],
            "updateStatus": "UpdateInstalling",
          };
          FlutterForegroundTask.sendDataToMain(dataToSend);
        }
        if (event == "com.example.dom_affrikia_app.APK_INSTALL_PROGRESS") {
          var progress = data['progress'] as num;

          final Map<String, dynamic> dataToSend = {
            "installProgress": progress,
            "installStatus": data['status'],
          };
          FlutterForegroundTask.sendDataToMain(dataToSend);
        } else if (event == "com.example.dom_affrikia_app.APK_INSTALL_DONE") {
          final Map<String, dynamic> dataToSend = {
            "installStatus": data['status'],
            "updateStatus": "UpdateInstalled",
          };
          FlutterForegroundTask.sendDataToMain(dataToSend);
          final String? filePath = await _secureStorage.read(key: "lastApkFilePath");
          await deleteAfrrikiaApk(filePath!);
          await _secureStorage.write(key: "updateStatus", value: "UpdateInstalled");
        } else if (event == "com.example.dom_affrikia_app.APK_INSTALL_ERROR") {
          log("APK installation error: ${data['error']}");
          final Map<String, dynamic> dataToSend = {
            "installStatus": data['status'],
            "updateStatus": "UpdateInstalled",
          };
          FlutterForegroundTask.sendDataToMain(dataToSend);
          await _secureStorage.write(key: "updateStatus", value: "UpdateInstallError");
        }
      }
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    log('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    log('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    log('onNotificationDismissed');
  }

  Future<bool?> hasOverdueBill() async {
    var billsString = await _secureStorage.read(key: "bills");
    if (billsString != null) {
      final List<dynamic> jsonList = jsonDecode(billsString);
      var bills = jsonList.map((json) => Bill.fromJson(json)).toList();

      return bills.any(
          (bill) => bill.billStatus == 0 && bill.overdueTime != null && bill.overdueTime!.isBefore(DateTime.now()));
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getUpcomingOverdueBillsWithin7Days() async {
    var billsString = await _secureStorage.read(key: "bills");
    List<Map<String, dynamic>> upcomingBills = [];

    if (billsString != null) {
      final List<dynamic> jsonList = jsonDecode(billsString);
      var bills = jsonList.map((json) => Bill.fromJson(json)).toList();

      final now = DateTime.now();
      final in7Days = now.add(const Duration(days: 7));

      for (var bill in bills) {
        if (bill.billStatus == 0 && bill.overdueTime != null) {
          final overdueTime = bill.overdueTime!;
          if (overdueTime.isAfter(now) && overdueTime.isBefore(in7Days)) {
            final duration = overdueTime.difference(now);

            upcomingBills.add({
              "bill": bill,
              "remainingDays": duration.inDays,
              "remainingHours": duration.inHours % 24,
              "remainingMinutes": duration.inMinutes % 60,
              "remainingSeconds": duration.inSeconds % 60,
            });
          }
        }
      }
    }

    return upcomingBills;
  }
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}
