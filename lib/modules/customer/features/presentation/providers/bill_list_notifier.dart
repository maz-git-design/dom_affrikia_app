import 'dart:developer';

import 'package:dom_affrikia_app/background_task.dart';
import 'package:dom_affrikia_app/core/enums/phone-state.enum.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BillListNotifier extends ChangeNotifier {
  final List<Bill> _bills = [];
  final MainDataProvider mainDataProvider;
  final MethodChannel methodChannel;
  final FlutterSecureStorage secureStorage;

  BillListNotifier({required this.mainDataProvider, required this.methodChannel, required this.secureStorage});

  List<Bill> get bills => List.unmodifiable(_bills);

  void addBill(Bill bill) {
    _bills.add(bill);
    _onChange();
  }

  void addManyBills(List<Bill> bills) {
    _bills.addAll(bills);
    _onChange();
  }

  void removeBill(Bill bill) {
    _bills.remove(bill);
    _onChange();
  }

  void changeAllBills(List<Bill> bills) {
    _bills.clear();
    _bills.addAll(bills);
    _onChange();
  }

  void updateBill(int index, Bill newBill) {
    if (index >= 0 && index < _bills.length) {
      _bills[index] = newBill;
      _onChange();
    }
  }

  void clearBills() {
    _bills.clear();
    _onChange();
  }

  void _sendDataToTask() {
    // Main(UI) -> TaskHandler
    //
    // The Map collection can only be sent in json format, such as Map<String, dynamic>.
    FlutterForegroundTask.sendDataToTask(Object);
  }

  calculatePhoneState() async {
    if (hasBillTopay() && !hasBillOverdue()) {
      mainDataProvider.phoneState = PhoneStateEnum.unlockPartially;
      await secureStorage.write(key: "phoneState", value: PhoneStateEnum.unlockPartially.index.toString());

      final Map<String, dynamic> data = {
        "phoneState": 1,
      };
      FlutterForegroundTask.sendDataToTask(data);
      await disableKioskModePartially();
      log("phone unlocked partially");
    } else if (hasBillTopay() && hasBillOverdue()) {
      mainDataProvider.phoneState = PhoneStateEnum.lock;
      await secureStorage.write(key: "phoneState", value: PhoneStateEnum.lock.index.toString());
      // final Map<String, dynamic> data = {
      //   "phoneState": 0,
      // };
      // FlutterForegroundTask.sendDataToTask(data);
      await enableKioskMode();
      log("phone locked");
    } else if (paidAllBill()) {
      mainDataProvider.phoneState = PhoneStateEnum.unlock;
      await secureStorage.write(key: "phoneState", value: PhoneStateEnum.unlock.index.toString());

      final Map<String, dynamic> data = {
        "phoneState": 2,
      };
      FlutterForegroundTask.sendDataToTask(data);
      await Future.delayed(const Duration(seconds: 2));
      await disableKioskMode();
      log("phone unlocked completely");
    }
  }

  hasBillTopay() {
    return bills.any((bill) => bill.billStatus == 0 || bill.billStatus == 1 || bill.billStatus == 3);
  }

  hasBillOverdue() {
    return bills
        .any((bill) => bill.billStatus == 0 && bill.overdueTime != null && bill.overdueTime!.isBefore(DateTime.now()));
  }

  paidAllBill() {
    return bills.every((bill) => bill.billStatus == 2);
  }

  void _onChange() {
    notifyListeners(); // Triggers any UI listening
    _runBackgroundJob(); // Your custom handler
  }

  void _runBackgroundJob() async {
    log("List changed — running background handler...");

    calculatePhoneState(); // Your custom logic to calculate phone state

    //var currentPhoneState = await secureStorage.read(key: "phoneState");
    // if (mainDataProvider.phoneState == PhoneStateEnum.lock) {
    //   await enableKioskMode();
    //   log("phone locked");
    // } else if (mainDataProvider.phoneState == PhoneStateEnum.unlockPartially) {
    //   await disableKioskModePartially();
    //   log("phone unlocked partially");
    // } else if (mainDataProvider.phoneState == PhoneStateEnum.unlock) {
    //   await disableKioskMode();
    //   log("phone unlocked completely");
    // }
  }

  Future<void> enableKioskMode() async {
    try {
      var message = await methodChannel.invokeMethod<String>('enableKioskMode');
      log("Phone disabled from notifier: $message");
    } catch (e) {
      log("Error enabling Kiosk Mode: $e");
    }
  }

  Future<void> disableKioskMode() async {
    try {
      var message = await methodChannel.invokeMethod<String>('disableKioskMode');
      log("Phone disabled from notifier: $message");
      //await methodChannel.invokeMethod("disableKioskMode");
    } catch (e) {
      log("Error enabling Kiosk Mode: $e");
    }
  }

  Future<void> disableKioskModePartially() async {
    try {
      var message = await methodChannel.invokeMethod<String>('disableKioskModePartially');
      log("Phone disabled partially from notifier: $message");
      //await methodChannel.invokeMethod("disableKioskMode");
    } catch (e) {
      log("Error enabling Kiosk Mode: $e");
    }
  }
}
