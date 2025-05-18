// The callback function should always be a top-level or static function.
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/core/config/config.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end_repo_call.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:flutter/material.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

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
  //BroadcastReceiver? _apkReceiver;
  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  static final InternetConnectionChecker internetConnectionChecker = InternetConnectionChecker.createInstance();

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
      log('sendStatus');
      log("status: $status");
      log("deviceId: $deviceId");
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

  Future<void> updateApkHandler() async {
    const intent = AndroidIntent(
      action: 'com.example.dom_affrikia_app.ACTION_ADMIN',
      package: 'com.example.dom_affrikia_app',
      componentName: 'com.example.dom_affrikia_app.AdminActionReceiver',
      arguments: {
        'action': 'installApk',
        'apkUrl': 'https://example.com/path/to/your.apk',
      },
    );

    await intent.sendBroadcast();
  }

  // void startApkInstallReceiver() {
  //   _apkReceiver = BroadcastReceiver(
  //     names: [
  //       'com.example.dom_affrikia_app.APK_DOWNLOAD_STARTED',
  //       'com.example.dom_affrikia_app.APK_DOWNLOAD_PROGRESS',
  //       'com.example.dom_affrikia_app.APK_DOWNLOAD_DONE',
  //       'com.example.dom_affrikia_app.APK_DOWNLOAD_ERROR',
  //     ],
  //   );

  //   _apkReceiver!.messages.listen((message) {
  //     final action = message.name;
  //     final data = message.data;

  //     if (action == 'com.example.dom_affrikia_app.APK_DOWNLOAD_PROGRESS') {
  //       final progress = data?['progress'] ?? 0;
  //       log('Download Progress: $progress%');
  //     } else if (action == 'com.example.dom_affrikia_app.APK_DOWNLOAD_ERROR') {
  //       final error = data?['error'] ?? 'Unknown error';
  //       log('Installation Error: $error');
  //       stopApkInstallReceiver();
  //     } else if (action == 'com.example.dom_affrikia_app.APK_DOWNLOAD_DONE') {
  //       log('Installation completed.');
  //       stopApkInstallReceiver();
  //     }
  //   });

  //   _apkReceiver!.start();
  // }

  // void stopApkInstallReceiver() {
  //   _apkReceiver?.stop();
  //   _apkReceiver = null;
  // }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    //FlutterForegroundTask.sendDataToMain(data);
    log('onRepeatEvent(timestamp: $timestamp)');

    // Update notifications
    await updateNofification();
    // Send status of device to server
    await sendStatustoServer();
    // Check for overdue bills and block the phone if any are found
    await overDueHandler();
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
      final dynamic newPhoneState = data["phoneState"];
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
