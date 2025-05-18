import 'dart:developer';

import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initImei() async {
  try {
    var imei = await sl<MethodChannel>().invokeMethod<String?>("getIMEI");
    if (imei != null) {
      sl<MainDataProvider>().deviceID = imei;
    } else {
      log("Failed to get IMEI, falling back to default");
      sl<MainDataProvider>().deviceID = await sl<FlutterDeviceImei>().getIMEI();
    }

    await sl<FlutterSecureStorage>().write(key: "phoneIMEI", value: sl<MainDataProvider>().deviceID);
  } catch (e) {
    log("Failed to get IMEI: $e");
    sl<MainDataProvider>().deviceID = await sl<FlutterDeviceImei>().getIMEI();
  }
}
