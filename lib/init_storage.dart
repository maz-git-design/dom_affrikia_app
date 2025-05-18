import 'dart:developer';

import 'package:dom_affrikia_app/core/config/config.dart';
import 'package:dom_affrikia_app/core/enums/phone-state.enum.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/device.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initStorage() async {
  var phoneIMEI = sl<MainDataProvider>().deviceID;

  await sl<FlutterSecureStorage>().write(key: "phoneIMEI", value: phoneIMEI);
  var hasActivation = await sl<FlutterSecureStorage>().containsKey(key: "isActivated");
  if (hasActivation) {
    var activation = await sl<FlutterSecureStorage>().read(key: "isActivated");

    sl<MainDataProvider>().phoneIsActivated = activation == "true";
  } else {
    await sl<FlutterSecureStorage>().write(key: "isActivated", value: "false");
    sl<MainDataProvider>().phoneIsActivated = false;
  }
  var hasActivationStep = await sl<FlutterSecureStorage>().containsKey(key: "activationStep");
  if (!hasActivationStep) {
    if (sl<MainDataProvider>().phoneIsActivated) {
      await sl<FlutterSecureStorage>().write(key: "activationStep", value: "3");
      sl<MainDataProvider>().activationStep = "3";
    } else {
      await sl<FlutterSecureStorage>().write(key: "activationStep", value: "1");
      sl<MainDataProvider>().activationStep = "1";
    }
  } else {
    sl<MainDataProvider>().activationStep = await sl<FlutterSecureStorage>().read(key: "activationStep") ?? "";
  }

  var hasBills = await sl<FlutterSecureStorage>().containsKey(key: "bills");

  if (hasBills) {
    var billsString = await sl<FlutterSecureStorage>().read(key: "bills");

    sl<MainDataProvider>().loadBillsFromJson(billsString!);
  }

  var hasBillType = await sl<FlutterSecureStorage>().containsKey(key: "billType");
  if (hasBillType) {
    var billTypeString = await sl<FlutterSecureStorage>().read(key: "billType");

    sl<MainDataProvider>().billType = billTypeString!;
  }

  //create admin password if not exists
  var hasAdminPassword = await sl<FlutterSecureStorage>().containsKey(key: "adminPassword");
  if (!hasAdminPassword) {
    await sl<FlutterSecureStorage>().write(key: "adminPassword", value: ADMIN_PASSWORD);
  }

  var activationCode = await sl<FlutterSecureStorage>().read(key: "customerCode");
  sl<MainDataProvider>().activationCode = activationCode ?? "Pas de code";

  var device = await sl<FlutterSecureStorage>().read(key: "device");
  sl<MainDataProvider>().device = device == null ? null : Device.fromString(device);

  var phoneState = await sl<FlutterSecureStorage>().read(key: "phoneState");
  if (phoneState != null) {
    log("Phone state from storage: $phoneState");
    sl<MainDataProvider>().phoneState =
        int.tryParse(phoneState) == null ? PhoneStateEnum.lock : getPhoneState(int.tryParse(phoneState)!)!;

    if (sl<MainDataProvider>().phoneState == PhoneStateEnum.lock) {
      var message = await sl<MethodChannel>().invokeMethod<String>('enableKioskMode');
      log("Phone disabled from init storage: $message");
    }
  } else {
    var message = await sl<MethodChannel>().invokeMethod<String>('enableKioskMode');
    log("Phone disabled from init storage: $message");
  }
}
