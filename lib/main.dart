import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/background_task.dart' show startService;
import 'package:dom_affrikia_app/core/errors/bloc/error_bloc.dart';
import 'package:dom_affrikia_app/core/ui/themes/app_themes.dart';
import 'package:dom_affrikia_app/core/ui/themes/bloc/theme_bloc.dart';
import 'package:dom_affrikia_app/get_imei.dart';
import 'package:dom_affrikia_app/init_background_task.dart';
import 'package:dom_affrikia_app/init_download.dart';
import 'package:dom_affrikia_app/init_storage.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/activation_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/about_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/authenticated_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/contract_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/home_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/main_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/config/config.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true));
const String _kMainServiceEnabledFlag = 'mainServiceEnabledFlag';
//final InternetConnectionChecker _internetConnectionChecker = InternetConnectionChecker.createInstance();
final Options _options =
    Options(headers: {'Content-Type': 'application/json', 'deviceTypeId': '1'});
final Dio _managedDio = Dio(
  BaseOptions(
    baseUrl: API_URL,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ),
);

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
  final deviceId = await _secureStorage.read(key: 'phoneIMEI');
  if (deviceId == null || deviceId.isEmpty) return false;
  _options.headers?['deviceId'] = deviceId;
  try {
    await _managedDio.post('/device-command/ack/$commandId',
        data: {'status': status}, options: _options);
    return true;
  } catch (e) {
    log('ACK failed for commandId=$commandId status=$status error=$e');
    return false;
  }
}

Future<List<dynamic>> _fetchPendingCommands() async {
  final deviceId = await _secureStorage.read(key: 'phoneIMEI');
  if (deviceId == null || deviceId.isEmpty) return <dynamic>[];
  _options.headers?['deviceId'] = deviceId;
  try {
    final response = await _managedDio.get('/device-command/pending/by-imei',
        options: _options);
    final body = response.data;
    if (body is List) return body;
  } catch (e) {
    log('Failed to fetch pending commands: $e');
  }
  return <dynamic>[];
}

Future<void> _broadcastAdminAction(String action) async {
  if (!Platform.isAndroid) return;
  final intent = AndroidIntent(
    action: 'com.example.dom_affrikia_app.ACTION_ADMIN',
    package: 'com.example.dom_affrikia_app',
    componentName: 'com.example.dom_affrikia_app.AdminActionReceiver',
    arguments: {'action': action},
  );
  await intent.sendBroadcast();
}

Future<bool> _executeCommand(dynamic command) async {
  if (command is! Map) return false;
  final commandType = _normalizeCommandType(command['commandType']);
  final commandValue = command['commandValue']?.toString();
  final commandId = command['id'] ?? command['commandId'];

  final actions = <String, String>{
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

  try {
    if (commandType == 'ENABLE_MAIN_SERVICE') {
      await _secureStorage.write(key: _kMainServiceEnabledFlag, value: '1');
      await startService();
      return true;
    }
    if (commandType == 'DISABLE_MAIN_SERVICE') {
      await _secureStorage.write(key: _kMainServiceEnabledFlag, value: '0');
      await FlutterForegroundTask.stopService();
      return true;
    }
    if (commandType == 'CHANGE_ADMIN_PASSWORD') {
      if (commandValue == null || commandValue.trim().isEmpty) return false;
      await _secureStorage.write(
          key: 'adminPassword', value: commandValue.trim());
      return true;
    }
    if (commandType == 'CHANGE_BACKGROUND_PERIOD') {
      if (commandValue == null || int.tryParse(commandValue.trim()) == null)
        return false;
      await _secureStorage.write(
          key: 'backgroundPeriod', value: commandValue.trim());
      return true;
    }
    if (commandType == 'UPDATE' || commandType == 'START_UPDATE') {
      if (commandValue == null || commandValue.trim().isEmpty) return false;
      await _secureStorage.write(
          key: 'md_update_apk_url', value: commandValue.trim());
      await _secureStorage.write(key: 'md_update_in_progress', value: '1');
      await _secureStorage.write(key: 'md_update_percent', value: '0');
      return true;
    }
    if (commandType == 'INTERRUPT_UPDATE') {
      await _secureStorage.delete(key: 'md_update_apk_url');
      await _secureStorage.write(key: 'md_update_in_progress', value: '0');
      await _secureStorage.write(key: 'md_update_percent', value: '0');
      return true;
    }
    if (commandType == 'STATUS') {
      return true;
    }
    final action = actions[commandType];
    if (action == null) return false;
    if (commandType == 'REBOOT') {
      // Persist ACK marker before triggering reboot broadcast to avoid
      // process termination before marker write.
      await _secureStorage.write(key: 'rebooted', value: '1');
      await _secureStorage.write(
          key: 'rebootCommandId', value: commandId.toString());
    }
    await _broadcastAdminAction(action);
    return true;
  } catch (e) {
    if (commandType == 'REBOOT') {
      await _secureStorage.delete(key: 'rebooted');
      await _secureStorage.delete(key: 'rebootCommandId');
    }
    log('Command execution error type=$commandType: $e');
    return false;
  }
}

Future<void> _processPendingCommandsQueue() async {
  final commands = await _fetchPendingCommands();
  if (commands.isEmpty) return;
  var shouldStopMainService = false;
  for (final command in commands) {
    final commandId =
        (command is Map) ? (command['id'] ?? command['commandId']) : null;
    final type =
        (command is Map) ? _normalizeCommandType(command['commandType']) : '';

    final ok = await _executeCommand(command);
    if (type != 'REBOOT') {
      await _ackCommand(commandId, ok ? 'EXECUTED' : 'FAILED');
    }
    if (type == 'DISABLE_MAIN_SERVICE' && ok) {
      shouldStopMainService = true;
    }
  }
  if (shouldStopMainService) {
    await FlutterForegroundTask.stopService();
  }
}

Future<void> _sendPendingRebootAckIfNeeded() async {
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _processPendingCommandsQueue();
}

Future<void> _initFirebaseAndCommandListeners() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? token;

  try {
    token = await messaging.getToken();
  } catch (e) {
    log('Failed to get FCM token: $e');
  }

  if (token != null && token.isNotEmpty) {
    await _secureStorage.write(key: 'fcmToken', value: token);
    final deviceId = await _secureStorage.read(key: 'phoneIMEI');
    if (deviceId != null && deviceId.isNotEmpty) {
      _options.headers?['deviceId'] = deviceId;
      try {
        await _managedDio.post('/managed-device/fcm-token/imei?fcmToken=$token',
            options: _options);
      } catch (e) {
        log('Failed to sync FCM token: $e');
      }
    }
  }
  FirebaseMessaging.onMessage.listen((_) async {
    await _sendPendingRebootAckIfNeeded();
    await _processPendingCommandsQueue();
  });
  FirebaseMessaging.onMessageOpenedApp.listen((_) async {
    await _sendPendingRebootAckIfNeeded();
    await _processPendingCommandsQueue();
  });
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) log(change.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(transition.toString());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // initialize instances
  init();

  //await stopService();

  sl<MainDataProvider>().androidDeviceInfo =
      await sl<DeviceInfoPlugin>().androidInfo;
  await initImei();
  //PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //log("App version: $packageInfo");

  //sl<FlutterSecureStorage>().deleteAll();
  // init storage
  await initStorage();
  await initDownload();
  await initBackgroundTask();
  await _initFirebaseAndCommandListeners();
  await _sendPendingRebootAckIfNeeded();
  await _processPendingCommandsQueue();

  FlutterForegroundTask.initCommunicationPort();

  // // Local notification initialization
  // const AndroidInitializationSettings initializationSettingsAndroid =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');

  // const InitializationSettings initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  // );

  // await sl<FlutterLocalNotificationsPlugin>().initialize(initializationSettings);

  Bloc.observer = AppBlocObserver();

  // await sl<AdminBloc>().add(AdminLoad());
  //DartPluginRegistrant.ensureInitialized();
  runApp(const MyApp());
  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        BlocProvider<ErrorBloc>(create: (_) => sl<ErrorBloc>()),
        BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
        BlocProvider<NavigationBloc>(create: (_) => sl<NavigationBloc>()),
        BlocProvider<AdminBloc>(create: (_) => sl<AdminBloc>()),
        BlocProvider<ActivationBloc>(create: (_) => sl<ActivationBloc>()),
        BlocProvider<CustomerBloc>(create: (_) => sl<CustomerBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        builder: (context, _) => BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent),
              child: MaterialApp(
                // localizationsDelegates: context.localizationDelegates,
                // supportedLocales: context.supportedLocales,
                // locale: context.locale,
                locale: DevicePreview.locale(context), // Add the locale here
                title: 'Afrrikia Device Manager',
                builder: DevicePreview.appBuilder,

                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                home: const MainScreen(),
                routes: {
                  HomeScreen.routeName: (context) => const HomeScreen(),
                  AuthenticatedScreen.routeName: (context) =>
                      const AuthenticatedScreen(),
                  MainScreen.routeName: (context) => const MainScreen(),
                  ContractScreen.routeName: (context) => const ContractScreen(),
                  AboutScreen.routeName: (context) => const AboutScreen(),
                  // EditProfileScreen.routeName: (context) => const EditProfileScreen(),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
