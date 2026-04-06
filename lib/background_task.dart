// The callback function should always be a top-level or static function.
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/core/config/config.dart';
import 'package:dom_affrikia_app/core/entities/app_update_info.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end_repo_call.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _kManagedUpdateUrl = 'md_update_apk_url';
  static const String _kManagedUpdateInProgress = 'md_update_in_progress';
  static const String _kManagedUpdatePercent = 'md_update_percent';
  static const String _kManagedUpdateFromBuild = 'md_update_from_build';
  static const String _kManagedUpdateDownloaded = 'md_update_downloaded';
  static const String _kManagedUpdateInstalled = 'md_update_installed';
  static const String _kManagedInstallTriggered = 'md_install_triggered';
  static const String _kManagedInstallRetryAfterMs =
      'md_install_retry_after_ms';
  static const String _kMainServiceEnabledFlag = 'mainServiceEnabledFlag';
  static const String _kSuppressForegroundLaunchUntilMs =
      'suppressForegroundLaunchUntilMs';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  static final InternetConnectionChecker internetConnectionChecker =
      InternetConnectionChecker.createInstance();
  StreamSubscription<TaskUpdate>? downloadListener;
  bool _isDownloadListenerAttached = false;

  static final Options options = Options(
      headers: {'Content-Type': 'application/json', 'deviceTypeId': '1'});
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_URL,
      connectTimeout: const Duration(seconds: 60000),
      receiveTimeout: const Duration(seconds: 60000),
    ),
  );
  static final Dio _managedDeviceDio = Dio(
    BaseOptions(
      baseUrl: API_URL,
      connectTimeout: const Duration(seconds: 60000),
      receiveTimeout: const Duration(seconds: 60000),
    ),
  );

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('onStart(starter: ${starter.name})');
    await _recoverStaleUpdatingStateAfterUpgrade();
    await ensureManagedDeviceBootstrapIfNeeded();
    await sendPendingRebootAckIfNeeded();
    await processPendingCommandsQueue();
    await sendManagedDeviceStateSnapshot();
  }

  Future<void> _recoverStaleUpdatingStateAfterUpgrade() async {
    final inProgress =
        await _secureStorage.read(key: _kManagedUpdateInProgress);
    if (inProgress != '1') return;

    final fromBuild = await _secureStorage.read(key: _kManagedUpdateFromBuild);
    final updateStatus = await _secureStorage.read(key: 'updateStatus');

    String? currentBuild;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentBuild = packageInfo.buildNumber;
    } catch (_) {}

    final appWasUpgraded =
        fromBuild != null && currentBuild != null && fromBuild != currentBuild;
    final markedAsInstalled = updateStatus == 'UpdateInstalled';

    if (appWasUpgraded || markedAsInstalled) {
      await _secureStorage.write(key: _kManagedUpdateInProgress, value: '0');
      await _secureStorage.write(key: _kManagedUpdatePercent, value: '100');
      await _secureStorage.delete(key: _kManagedUpdateUrl);
      await _secureStorage.delete(key: _kManagedUpdateFromBuild);
      if (updateStatus != 'UpdateInstalled') {
        await _secureStorage.write(
            key: 'updateStatus', value: 'UpdateInstalled');
      }
      log('Recovered stale managed update state after app upgrade. build=$currentBuild');
    }
  }

  Future<bool?> _readAdminStatusViaBroadcast(String action) async {
    if (!Platform.isAndroid) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final tsKey = '${action}_ts';
      final beforeTs = int.tryParse(prefs.getString(tsKey) ?? '0') ?? 0;

      final intent = AndroidIntent(
        action: 'com.example.dom_affrikia_app.ACTION_ADMIN',
        package: 'com.example.dom_affrikia_app',
        componentName: 'com.example.dom_affrikia_app.AdminActionReceiver',
        arguments: {'action': action},
      );
      await intent.sendBroadcast();

      // Wait until receiver writes a fresh value (avoid stale read).
      for (var i = 0; i < 8; i++) {
        await Future.delayed(const Duration(milliseconds: 120));
        await prefs.reload();
        final afterTs = int.tryParse(prefs.getString(tsKey) ?? '0') ?? 0;
        if (afterTs > beforeTs) {
          return prefs.getBool(action);
        }
      }

      return prefs.getBool(action);
    } catch (e) {
      log('Failed to read admin status for $action: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _collectManagedPhoneState() async {
    final mappings = <Map<String, dynamic>>[
      {
        'action': 'getFactoryResetStatus',
        'field': 'factoryResetEnabled',
        'invert': true
      },
      {'action': 'getKioskStatus', 'field': 'kioskModeEnable', 'invert': false},
      {'action': 'getAdbDebuggingStatus', 'field': 'adbEnable', 'invert': true},
      {
        'action': 'getUsbTransferStatus',
        'field': 'usbftransfertEnabled',
        'invert': true
      },
      {
        'action': 'getUninstallAppsStatus',
        'field': 'uninstallEnabled',
        'invert': true
      },
      {
        'action': 'getInstallAppsStatus',
        'field': 'installappsEnabled',
        'invert': true
      },
      {
        'action': 'getSafeBootStatus',
        'field': 'safebootEnabled',
        'invert': true
      },
      {
        'action': 'getTetheringStatus',
        'field': 'tetheringEnabled',
        'invert': true
      },
      {'action': 'getAddUserStatus', 'field': 'addUserenabled', 'invert': true},
      {
        'action': 'getDateTimeStatus',
        'field': 'updateDateEnabled',
        'invert': true
      },
      {
        'action': 'getAdbFeaturesStatus',
        'field': 'devOptionsEnabled',
        'invert': true
      },
      {
        'action': 'getAppsControlStatus',
        'field': 'appsControlEnabled',
        'invert': true
      },
    ];

    final state = <String, dynamic>{};
    for (final mapping in mappings) {
      final raw =
          await _readAdminStatusViaBroadcast(mapping['action'] as String);
      final invert = mapping['invert'] as bool;
      final liveValue = raw == null ? false : (invert ? !raw : raw);
      state[mapping['field'] as String] = liveValue;
    }

    state['mainServiceEnabled'] = await FlutterForegroundTask.isRunningService;
    return state;
  }

  Future<void> ensureManagedDeviceBootstrapIfNeeded() async {
    final isConnected = await internetConnectionChecker.hasConnection;
    if (!isConnected) return;
    final imei = await _secureStorage.read(key: 'phoneIMEI');
    if (imei == null || imei.isEmpty) return;

    final enrolled = await _secureStorage.read(key: 'enrolled');
    if (enrolled == '1') {
      final existsInBackend = await _managedDeviceExistsInBackend(imei);
      if (existsInBackend) {
        return;
      }
      // Local flag is stale (app reinstalled / backend cleaned): force a fresh bootstrap.
      await _secureStorage.delete(key: 'enrolled');
      log('Managed device enrolled flag was local-only stale. Rebootstrapping imei=$imei');
    }

    final customerCode = await _secureStorage.read(key: 'customerCode');
    final adminPassword = await _secureStorage.read(key: 'adminPassword');
    final fcmToken = await _secureStorage.read(key: 'fcmToken');
    final backgroundPeriodRaw =
        await _secureStorage.read(key: 'backgroundPeriod');
    final backgroundPeriod = int.tryParse(backgroundPeriodRaw ?? '') ?? 5;

    String? appVersion;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {}
    String model = 'ANDROID_DEVICE';
    String androidVersion = Platform.operatingSystemVersion;
    try {
      final android = await DeviceInfoPlugin().androidInfo;
      model = '${android.brand} ${android.model}'.trim();
      androidVersion = android.version.release;
    } catch (_) {}

    options.headers?['deviceId'] = imei;
    try {
      await _managedDeviceDio.post(
        '/managed-device/bootstrap',
        data: {
          'model': model,
          'fcmToken': fcmToken,
          'deviceStatus': 'CONNECTED',
          'phoneLockState': await _resolvePhoneLockState(),
          'phoneState': await _collectManagedPhoneState(),
          'deviceAdminPassword': adminPassword,
          'backgroundPeriod': backgroundPeriod,
          'onboardingState': {
            'value': customerCode != null && customerCode.trim().isNotEmpty,
            'code': customerCode,
          },
          'androidVersion': androidVersion,
          'appVersion': appVersion,
        },
        options: options,
      );
      await _secureStorage.write(key: 'enrolled', value: '1');
    } catch (e) {
      log('Managed bootstrap failed: $e');
    }
  }

  Future<bool> _managedDeviceExistsInBackend(String imei) async {
    options.headers?['deviceId'] = imei;
    try {
      final response =
          await _managedDeviceDio.get('/managed-device/imei', options: options);
      final data = response.data;
      if (data is Map) {
        final id = data['id'];
        if (id != null) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _resolvePhoneLockState() async {
    final phoneState = await _secureStorage.read(key: 'phoneState');
    if (phoneState == '0') return 'LOCKED';
    if (phoneState == '1') return 'PARTIALLY_UNLOCKED';
    if (phoneState == '2') return 'UNLOCKED';
    return null;
  }

  Future<void> sendManagedDeviceStateSnapshot({String? overrideStatus}) async {
    final isConnected = await internetConnectionChecker.hasConnection;
    if (!isConnected) return;
    final imei = await _secureStorage.read(key: 'phoneIMEI');
    if (imei == null || imei.isEmpty) return;
    final customerCode = await _secureStorage.read(key: 'customerCode');
    final adminPassword = await _secureStorage.read(key: 'adminPassword');
    final backgroundPeriodRaw =
        await _secureStorage.read(key: 'backgroundPeriod');
    final backgroundPeriod = int.tryParse(backgroundPeriodRaw ?? '') ?? 5;
    final managedUpdateInProgress =
        await _secureStorage.read(key: _kManagedUpdateInProgress);
    final updatePercentRaw =
        await _secureStorage.read(key: _kManagedUpdatePercent);
    final updatePercent = int.tryParse(updatePercentRaw ?? '');
    String? appVersion;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {}

    options.headers?['deviceId'] = imei;
    try {
      await _managedDeviceDio.put(
        '/managed-device/state/imei',
        data: {
          'deviceStatus': overrideStatus ??
              (managedUpdateInProgress == '1' ? 'UPDATING' : 'CONNECTED'),
          'phoneLockState': await _resolvePhoneLockState(),
          'phoneState': await _collectManagedPhoneState(),
          'deviceAdminPassword': adminPassword,
          'backgroundPeriod': backgroundPeriod,
          'updatePercent': updatePercent,
          'onboardingState': {
            'value': customerCode != null && customerCode.trim().isNotEmpty,
            'code': (customerCode != null && customerCode.trim().isNotEmpty)
                ? customerCode
                : null,
          },
          'androidVersion': Platform.operatingSystemVersion,
          'appVersion': appVersion,
        },
        options: options,
      );
    } catch (e) {
      log('Managed state snapshot failed: $e');
    }
  }

  Future<List<dynamic>> _fetchPendingCommands() async {
    final imei = await _secureStorage.read(key: 'phoneIMEI');
    if (imei == null || imei.isEmpty) return <dynamic>[];
    options.headers?['deviceId'] = imei;
    try {
      final response = await _managedDeviceDio
          .get('/device-command/pending/by-imei', options: options);
      final data = response.data;
      if (data is List) return data;
      return <dynamic>[];
    } catch (e) {
      log('Fetch pending commands failed: $e');
      return <dynamic>[];
    }
  }

  String _normalizeCommandType(dynamic raw) {
    return (raw ?? '')
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  Future<bool> _ackCommand(dynamic commandId, String status) async {
    if (commandId == null) return false;
    final imei = await _secureStorage.read(key: 'phoneIMEI');
    if (imei == null || imei.isEmpty) return false;
    options.headers?['deviceId'] = imei;
    try {
      await _managedDeviceDio.post('/device-command/ack/$commandId',
          data: {'status': status}, options: options);
      return true;
    } catch (e) {
      log('Ack command failed id=$commandId status=$status error=$e');
      return false;
    }
  }

  Future<void> _markPendingRebootAck(dynamic commandId) async {
    if (commandId == null) return;
    await _secureStorage.write(key: 'rebooted', value: '1');
    await _secureStorage.write(
        key: 'rebootCommandId', value: commandId.toString());
  }

  Future<void> sendPendingRebootAckIfNeeded() async {
    final rebooted = await _secureStorage.read(key: 'rebooted');
    if (rebooted != '1') return;
    final commandId = await _secureStorage.read(key: 'rebootCommandId');
    var acked = false;
    if (commandId != null && commandId.isNotEmpty) {
      acked = await _ackCommand(commandId, 'EXECUTED');
    }
    if (acked) {
      await _secureStorage.delete(key: 'rebooted');
      await _secureStorage.delete(key: 'rebootCommandId');
    } else {
      log('Reboot ACK not sent yet; keeping reboot flags for retry.');
    }
  }

  Future<bool> _executeCommandLocally(String commandType,
      {String? commandValue, dynamic commandId}) async {
    final type = _normalizeCommandType(commandType);
    final actionMap = <String, String>{
      'LOCK_DEVICE': 'enableKioskMode',
      'UNLOCK_DEVICE': 'disableKioskModePartially',
      'WIPE': 'wipeDevice',
      'REBOOT': 'rebootDevice',
      'ENABLE_FACTORY_RESET': 'allowFactoryReset',
      'DISABLE_FACTORY_RESET': 'blockFactoryReset2',
      'ENABLE_KIOSK_MODE': 'enableKioskMode',
      'DISABLE_KIOSK_MODE': 'disableKioskModePartially',
      'ENABLE_ADB': 'allowAdbDebugging',
      'DISABLE_ADB': 'blockAdbDebugging',
      'ENABLE_USB_TRANSFER': 'allowUsbTransfer',
      'DISABLE_USB_TRANSFER': 'blockUsbTransfer',
      'ENABLE_UNINSTALL': 'allowUninstallApps',
      'DISABLE_UNINSTALL': 'blockUninstallApps',
      'ENABLE_INSTALL_APPS': 'allowInstallApps',
      'DISABLE_INSTALL_APPS': 'blockInstallApps',
      'ENABLE_SAFE_BOOT': 'allowSafeBoot',
      'DISABLE_SAFE_BOOT': 'blockSafeBoot',
      'ENABLE_TETHERING': 'allowTethering',
      'DISABLE_TETHERING': 'blockTethering',
      'ENABLE_ADD_USER': 'allowAddUser',
      'DISABLE_ADD_USER': 'blockAddUser',
      'ENABLE_UPDATE_DATE': 'allowDateConfig',
      'DISABLE_UPDATE_DATE': 'blockDateConfig',
      'ENABLE_DEV_OPTIONS': 'allowAdbFeatures',
      'DISABLE_DEV_OPTIONS': 'blockAdbFeatures',
      'ENABLE_APPS_CONTROL': 'allowAppsControl',
      'DISABLE_APPS_CONTROL': 'blockAppsControl',
      'UNREGISTER_DEVICE': 'disableAdmin',
      'UNREGISTER_ONBOARDING': 'disableAdmin',
    };

    if (type == 'STATUS') {
      await sendManagedDeviceStateSnapshot();
      return true;
    }
    if (type == 'ENABLE_MAIN_SERVICE') {
      await _secureStorage.write(key: _kMainServiceEnabledFlag, value: '1');
      // Service is already running in this execution context.
      return true;
    }
    if (type == 'DISABLE_MAIN_SERVICE') {
      await _secureStorage.write(key: _kMainServiceEnabledFlag, value: '0');
      // Stop service after ACK to avoid losing command acknowledgment.
      await _secureStorage.write(key: 'mainServiceStopRequested', value: '1');
      return true;
    }
    if (type == 'CHANGE_ADMIN_PASSWORD') {
      if (commandValue == null || commandValue.trim().isEmpty) return false;
      await _secureStorage.write(
          key: 'adminPassword', value: commandValue.trim());
      await sendManagedDeviceStateSnapshot();
      return true;
    }
    if (type == 'CHANGE_BACKGROUND_PERIOD') {
      if (commandValue == null || int.tryParse(commandValue.trim()) == null)
        return false;
      await _secureStorage.write(
          key: 'backgroundPeriod', value: commandValue.trim());
      await sendManagedDeviceStateSnapshot();
      return true;
    }
    if (type == 'UPDATE' || type == 'START_UPDATE') {
      if (commandValue == null || commandValue.trim().isEmpty) return false;
      await _secureStorage.write(
          key: _kManagedUpdateUrl, value: commandValue.trim());
      await _secureStorage.write(key: _kManagedUpdateInProgress, value: '1');
      await _secureStorage.write(key: _kManagedUpdatePercent, value: '0');
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        await _secureStorage.write(
            key: _kManagedUpdateFromBuild, value: packageInfo.buildNumber);
      } catch (_) {}
      await _secureStorage.write(key: 'updateStatus', value: 'HasUpdate');
      await sendManagedDeviceStateSnapshot(overrideStatus: 'UPDATING');
      await updateApkHandler();
      return true;
    }
    if (type == 'INTERRUPT_UPDATE') {
      await _secureStorage.delete(key: _kManagedUpdateUrl);
      await _secureStorage.write(key: _kManagedUpdateInProgress, value: '0');
      await _secureStorage.write(key: _kManagedUpdatePercent, value: '0');
      await sendManagedDeviceStateSnapshot(overrideStatus: 'CONNECTED');
      return true;
    }

    final action = actionMap[type];
    if (action == null) return false;
    if (!Platform.isAndroid) return false;
    try {
      if (type == 'REBOOT') {
        // Persist ACK marker before triggering reboot broadcast to avoid
        // process termination before the marker is written.
        await _markPendingRebootAck(commandId);
      }

      final intent = AndroidIntent(
        action: 'com.example.dom_affrikia_app.ACTION_ADMIN',
        package: 'com.example.dom_affrikia_app',
        componentName: 'com.example.dom_affrikia_app.AdminActionReceiver',
        arguments: {'action': action},
      );
      await intent.sendBroadcast();
      return true;
    } catch (e) {
      if (type == 'REBOOT') {
        // Rollback stale marker when reboot command could not be dispatched.
        await _secureStorage.delete(key: 'rebooted');
        await _secureStorage.delete(key: 'rebootCommandId');
      }
      log('Execute command failed type=$type error=$e');
      return false;
    }
  }

  Future<void> processPendingCommandsQueue() async {
    final commands = await _fetchPendingCommands();
    if (commands.isEmpty) return;
    var shouldStopMainService = false;
    for (final item in commands) {
      dynamic id;
      String type = '';
      String? value;
      if (item is Map) {
        id = item['id'] ?? item['commandId'];
        type = (item['commandType'] ?? '').toString();
        final raw = item['commandValue'];
        value = raw == null ? null : raw.toString();
      }
      if (id == null || type.isEmpty) continue;
      final normalizedType = _normalizeCommandType(type);

      final ok = await _executeCommandLocally(type,
          commandValue: value, commandId: id);
      if (normalizedType != 'REBOOT') {
        await _ackCommand(id, ok ? 'EXECUTED' : 'FAILED');
      }
      if (normalizedType == 'DISABLE_MAIN_SERVICE' && ok) {
        shouldStopMainService = true;
      }
    }
    if (shouldStopMainService) {
      await FlutterForegroundTask.stopService();
    }
  }

  Future<void> sendStatustoServer() async {
    var hasStatusToSend = await _secureStorage.read(key: "hasDataToSend");

    var isConnected = await internetConnectionChecker.hasConnection;
    var phoneState = await _secureStorage.read(key: "phoneState");

    if (hasStatusToSend != null &&
        hasStatusToSend == "1" &&
        isConnected &&
        phoneState != null) {
      var deviceId = await _secureStorage.read(key: "phoneIMEI");
      var status = getPhoneServerStatusFromStateString(phoneState);
      options.headers?["deviceId"] = deviceId;
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => _dio.put('/device/updateDeviceStatus?status=$status',
              options: options),
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
      updateStatus = "NoUpdate";
    }

    final managedUpdateUrl = await _secureStorage.read(key: _kManagedUpdateUrl);
    if (managedUpdateUrl != null && managedUpdateUrl.trim().isNotEmpty) {
      final fileName = managedUpdateUrl.split('/').last.trim().isEmpty
          ? 'afrrikia-managed-update.apk'
          : managedUpdateUrl.split('/').last.trim();
      final forcedInfo = AppUpdateInfo(
        id: 'managed-command',
        url: managedUpdateUrl.trim(),
        title: fileName,
        updateInstall: 1,
      );
      await _secureStorage.write(
          key: "updateInfo", value: forcedInfo.toString());
      await _secureStorage.write(key: "updateStatus", value: "HasUpdate");
      await _secureStorage.write(key: _kManagedUpdateDownloaded, value: '0');
      await _secureStorage.write(key: _kManagedUpdateInstalled, value: '0');
      await _secureStorage.write(key: _kManagedInstallTriggered, value: '0');
      await _secureStorage.write(key: _kManagedInstallRetryAfterMs, value: '0');
      FlutterForegroundTask.sendDataToMain({"updateStatus": "HasUpdate"});
      return;
    }

    var isConnected = await internetConnectionChecker.hasConnection;

    if (isConnected &&
        (updateStatus == "NoUpdate" || updateStatus == "UpdateInstalled")) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => _dio.get(
              '/common/getUpgradeInfo?version=${packageInfo.buildNumber}',
              options: options),
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
                await _secureStorage.write(
                    key: "updateInfo", value: upgradeInfo.toString());
                await _secureStorage.write(
                    key: "updateStatus", value: "HasUpdate");
                await _secureStorage.write(
                    key: _kManagedUpdateDownloaded, value: '0');
                await _secureStorage.write(
                    key: _kManagedUpdateInstalled, value: '0');
                await _secureStorage.write(
                    key: _kManagedInstallTriggered, value: '0');
                await _secureStorage.write(
                    key: _kManagedInstallRetryAfterMs, value: '0');
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
        notificationText:
            "Votre téléphone est à l'état Bloqué. Veuillez payer vos factures pour le débloquer.",
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
      if (!_isDownloadListenerAttached) {
        _downloadSubscription = FileDownloader().updates.listen((update) async {
          try {
            switch (update) {
              case TaskStatusUpdate():
                // process the TaskStatusUpdate, e.g.
                switch (update.status) {
                  case TaskStatus.complete:
                    var filePath = await update.task.filePath();
                    log('Task ${update.task.taskId} path: ${update.task.baseDirectory} $filePath');
                    await _secureStorage.write(
                        key: "lastApkFilePath", value: filePath);
                    await _secureStorage.write(
                        key: "updateStatus", value: "UpdateDownloaded");
                    await _secureStorage.write(
                        key: _kManagedUpdateDownloaded, value: '1');
                    await _secureStorage.write(
                        key: _kManagedUpdateInstalled, value: '0');
                    await _secureStorage.write(
                        key: _kManagedInstallTriggered, value: '0');
                    final Map<String, dynamic> data = {
                      "updateStatus": "UpdateDownloaded",
                    };
                    FlutterForegroundTask.sendDataToMain(data);
                    await sendApkToBroadcastReceiver(filePath);

                    var taskIds = await FileDownloader().allTaskIds();
                    await FileDownloader().cancelTasksWithIds(taskIds);
                    await _downloadSubscription?.cancel();
                    _downloadSubscription = null;
                    _isDownloadListenerAttached = false;
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
                    await _secureStorage.write(
                        key: "updateStatus", value: "UpdateDownloading");
                    final Map<String, dynamic> data = {
                      "updateStatus": "UpdateDownloading",
                    };
                    FlutterForegroundTask.sendDataToMain(data);
                    log('Download enqueued');
                    break;
                  case TaskStatus.failed:
                    await _secureStorage.write(
                        key: "updateStatus", value: "HasUpdate");
                    await _secureStorage.write(
                        key: _kManagedUpdateDownloaded, value: '0');
                    await _secureStorage.write(
                        key: _kManagedInstallTriggered, value: '0');
                    final Map<String, dynamic> data = {
                      "updateStatus": "HasUpdate",
                    };
                    FlutterForegroundTask.sendDataToMain(data);
                    log('Download failed');
                    break;
                  case TaskStatus.canceled:
                    await _secureStorage.write(
                        key: "updateStatus", value: "HasUpdate");
                    await _secureStorage.write(
                        key: _kManagedUpdateDownloaded, value: '0');
                    await _secureStorage.write(
                        key: _kManagedInstallTriggered, value: '0');
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
        _isDownloadListenerAttached = true;
      }
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
      if (filePath == null || filePath.isEmpty) return;
      final fileExist = await checkAfrrikiaApkExist(filePath);

      if (fileExist != null && fileExist) {
        final retryAfterRaw =
            await _secureStorage.read(key: _kManagedInstallRetryAfterMs);
        final retryAfter = int.tryParse(retryAfterRaw ?? '') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now >= retryAfter) {
          await _secureStorage.write(
              key: _kManagedInstallTriggered, value: '1');
          await _secureStorage.write(
              key: _kManagedInstallRetryAfterMs, value: '0');
          await _secureStorage.write(
              key: "updateStatus", value: "UpdateInstalling");
          await sendApkToBroadcastReceiver(filePath);
        }
      } else {
        await _secureStorage.write(key: "updateStatus", value: "NoUpdate");
        await _secureStorage.write(key: _kManagedUpdateDownloaded, value: '0');
        await _secureStorage.write(key: _kManagedInstallTriggered, value: '0');
      }
    }
  }

  Future<void> updateApkHandler() async {
    final updateStatus = await _secureStorage.read(key: "updateStatus");
    final filePath = await _secureStorage.read(key: "lastApkFilePath");
    final downloaded =
        await _secureStorage.read(key: _kManagedUpdateDownloaded);
    final installed = await _secureStorage.read(key: _kManagedUpdateInstalled);
    final installTriggered =
        await _secureStorage.read(key: _kManagedInstallTriggered);

    if (installed == '1' && updateStatus != 'HasUpdate') {
      return;
    }

    if (filePath != null && filePath.isNotEmpty) {
      final fileExist = await checkAfrrikiaApkExist(filePath);
      if (fileExist == true && downloaded == '1') {
        if (updateStatus == 'UpdateInstalling' || installTriggered == '1') {
          return;
        }
        await _secureStorage.write(key: _kManagedInstallTriggered, value: '1');
        await _secureStorage.write(
            key: "updateStatus", value: "UpdateInstalling");
        await sendApkToBroadcastReceiver(filePath);
        return;
      }
    }

    await _secureStorage.write(key: _kManagedUpdateDownloaded, value: '0');
    await _secureStorage.write(key: _kManagedInstallTriggered, value: '0');
    await downloadHandler();
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
    final suppressUntilRaw =
        await _secureStorage.read(key: _kSuppressForegroundLaunchUntilMs);
    final suppressUntil = int.tryParse(suppressUntilRaw ?? '');
    if (suppressUntil != null &&
        DateTime.now().millisecondsSinceEpoch < suppressUntil) {
      return;
    }

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
    await processPendingCommandsQueue();
    // Check for overdue bills and block the phone if any are found
    await overDueHandler();
    // Send status of device to server
    await sendStatustoServer();
    await sendManagedDeviceStateSnapshot();
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
          await _secureStorage.write(
              key: "updateStatus", value: "UpdateInstalling");
          await _secureStorage.write(
              key: _kManagedUpdateInProgress, value: '1');
          await _secureStorage.write(key: _kManagedUpdatePercent, value: '1');
          await _secureStorage.write(
              key: _kManagedInstallTriggered, value: '1');
          await sendManagedDeviceStateSnapshot(overrideStatus: 'UPDATING');
          final Map<String, dynamic> dataToSend = {
            "installStatus": data['status'],
            "updateStatus": "UpdateInstalling",
          };
          FlutterForegroundTask.sendDataToMain(dataToSend);
        }
        if (event == "com.example.dom_affrikia_app.APK_INSTALL_PROGRESS") {
          var progress = data['progress'] as num;
          final percent = (progress * 100).clamp(0, 100).toInt();
          await _secureStorage.write(
              key: _kManagedUpdatePercent, value: percent.toString());
          await sendManagedDeviceStateSnapshot(overrideStatus: 'UPDATING');

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
          final String? filePath =
              await _secureStorage.read(key: "lastApkFilePath");
          await deleteAfrrikiaApk(filePath!);
          await _secureStorage.write(
              key: "updateStatus", value: "UpdateInstalled");
          await _secureStorage.write(
              key: _kManagedUpdateInProgress, value: '0');
          await _secureStorage.write(key: _kManagedUpdatePercent, value: '100');
          await _secureStorage.write(
              key: _kManagedUpdateDownloaded, value: '0');
          await _secureStorage.write(key: _kManagedUpdateInstalled, value: '1');
          await _secureStorage.write(
              key: _kManagedInstallTriggered, value: '0');
          await _secureStorage.write(
              key: _kManagedInstallRetryAfterMs, value: '0');
          await _secureStorage.delete(key: _kManagedUpdateUrl);
          await _secureStorage.delete(key: _kManagedUpdateFromBuild);
          await sendManagedDeviceStateSnapshot(overrideStatus: 'CONNECTED');
          await Future.delayed(const Duration(seconds: 2));
          FlutterForegroundTask.launchApp();
        } else if (event == "com.example.dom_affrikia_app.APK_INSTALL_ERROR") {
          log("APK installation error: ${data['error']}");
          final Map<String, dynamic> dataToSend = {
            "installStatus": data['status'],
            "updateStatus": "UpdateInstallError",
          };
          FlutterForegroundTask.sendDataToMain(dataToSend);
          await _secureStorage.write(
              key: "updateStatus", value: "UpdateInstallError");
          await _secureStorage.write(
              key: _kManagedUpdateInProgress, value: '0');
          await _secureStorage.write(key: _kManagedUpdatePercent, value: '0');
          await _secureStorage.write(key: _kManagedUpdateInstalled, value: '0');
          await _secureStorage.write(
              key: _kManagedInstallTriggered, value: '0');
          await _secureStorage.write(
              key: _kManagedInstallRetryAfterMs,
              value: (DateTime.now().millisecondsSinceEpoch +
                      const Duration(minutes: 2).inMilliseconds)
                  .toString());
          await _secureStorage.delete(key: _kManagedUpdateFromBuild);
          await sendManagedDeviceStateSnapshot(overrideStatus: 'CONNECTED');
        }
      } else if (data.containsKey('managed_update_url')) {
        final updateUrl = (data['managed_update_url'] ?? '').toString();
        if (updateUrl.isNotEmpty) {
          await _secureStorage.write(key: _kManagedUpdateUrl, value: updateUrl);
          await _secureStorage.write(
              key: _kManagedUpdateInProgress, value: '1');
          await _secureStorage.write(key: _kManagedUpdatePercent, value: '0');
          await _secureStorage.write(
              key: _kManagedUpdateDownloaded, value: '0');
          await _secureStorage.write(key: _kManagedUpdateInstalled, value: '0');
          await _secureStorage.write(
              key: _kManagedInstallTriggered, value: '0');
          await _secureStorage.write(
              key: _kManagedInstallRetryAfterMs, value: '0');
          try {
            final packageInfo = await PackageInfo.fromPlatform();
            await _secureStorage.write(
                key: _kManagedUpdateFromBuild, value: packageInfo.buildNumber);
          } catch (_) {}
          await sendManagedDeviceStateSnapshot(overrideStatus: 'UPDATING');
          await downloadHandler();
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

      return bills.any((bill) =>
          bill.billStatus == 0 &&
          bill.overdueTime != null &&
          bill.overdueTime!.isBefore(DateTime.now()));
    }

    return null;
  }

  Future<List<Map<String, dynamic>>>
      getUpcomingOverdueBillsWithin7Days() async {
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
