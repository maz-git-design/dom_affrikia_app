// The callback function should always be a top-level or static function.
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void startMyBackgroundTask() {
  FlutterForegroundTask.startService(
    notificationTitle: "Background Task",
    notificationText: "Your app is running in background",
    callback: startCallback,
  );
}

Future<ServiceRequestResult> startService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      // You can manually specify the foregroundServiceType for the service
      // to be started, as shown in the comment below.
      // serviceTypes: [
      //   ForegroundServiceTypes.dataSync,
      //   ForegroundServiceTypes.remoteMessaging,
      // ],
      serviceId: 256,
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
      notificationIcon: null,
      notificationButtons: [
        const NotificationButton(id: 'btn_hello', text: 'hello'),
      ],
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
  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    //await init();

    //initNotifications();
    log('onStart(starter: ${starter.name})');
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
    log('onRepeatEvent(timestamp: $timestamp)');

    FlutterForegroundTask.updateService(
      notificationTitle: 'Bienvenu chez afrikia',
      notificationText: timestamp.toString(),
      notificationIcon: const NotificationIcon(
        metaDataName: 'com.example.dom_affrikia_app.AFRRIKIA_ICON',
        backgroundColor: Color.fromRGBO(253, 172, 19, 1),
      ),
    );

    var hasOverdue = await hasOverdueBill();

    log("Has overdue bill: $hasOverdue");

    if (hasOverdue != null && hasOverdue) {
      // Enable kiosk mode
       var phoneState = await _secureStorage.read(key: "phoneState");

       if(phoneState !=null && phoneState == "1") {
        if (Platform.isAndroid) {
        const intent = AndroidIntent(
          action: 'com.example.dom_affrikia_app.ACTION_ADMIN',
          package: 'com.example.dom_affrikia_app', // Replace with your actual package name
          componentName: 'com.example.dom_affrikia_app.AdminActionReceiver',
          arguments: {
            'action': 'enableKioskMode',
          },
        );

        await intent.sendBroadcast();
      }
       }
      
    }
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('onDestroy(destroyed at: $timestamp)');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    log('onReceiveData: $data');
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
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}
