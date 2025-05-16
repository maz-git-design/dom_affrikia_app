import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:dom_affrikia_app/modules/admin/features/providers/admin_data_provider.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/activation_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/providers/bill_list_notifier.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/config/config.dart';
import 'core/errors/bloc/error_bloc.dart';
import 'core/interceptors/dio_connectivity_request_retrier.dart';
import 'core/platform/network_info.dart';
import 'core/interceptors/retry_request_interceptor.dart';
import 'core/ui/themes/app_themes.dart';
import 'core/ui/themes/bloc/theme_bloc.dart';
import 'core/ui/widgets/dialog_box.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Feature  - Theming
  sl.registerLazySingleton(() {
    var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return AppThemes(brightness == Brightness.dark);
  });

  sl.registerLazySingleton(() => ThemeBloc());
  sl.registerLazySingleton(() => ErrorBloc());

  //! Feature  - Dialog Box
  sl.registerLazySingleton(() => DialogBox());

  //! Features  - Authentification

  //! Blocs
  sl.registerLazySingleton(() => NavigationBloc(sl()));
  // sl.registerLazySingleton(() => AuthBloc(login: sl(), authController: sl(), authDataProvider: sl()));
  sl.registerLazySingleton(() => UserBloc());
  // sl.registerLazySingleton(() => AttendanceBloc(getAgents: sl(), postAttendance: sl()));

  // //! Controllers
  // sl.registerLazySingleton(() => AuthController());

  // // //! Providers
  // sl.registerLazySingleton(() => AuthDataProvider());
  // sl.registerLazySingleton(() => AttendanceDataProvider());
  sl.registerLazySingleton(() => MainDataProvider(connectivity: sl(), internetConnectionChecker: sl()));
  sl.registerLazySingleton(() => AdminDataProvider());

  sl.registerLazySingleton(() => AdminBloc(methodChannel: sl(), adminDataProvider: sl(), secureStorage: sl()));
  sl.registerLazySingleton(() => ActivationBloc(sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => CustomerBloc(sl(), sl(), sl(), sl(), sl(), sl()));

  sl.registerLazySingleton(() => BillListNotifier(mainDataProvider: sl(), methodChannel: sl(), secureStorage: sl()));
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // //! Usecases
  // sl.registerLazySingleton(() => Login(sl()));
  // sl.registerLazySingleton(() => HasToken(sl()));
  // sl.registerLazySingleton(() => GetToken(sl()));
  // sl.registerLazySingleton(() => CacheToken(sl()));
  // sl.registerLazySingleton(() => GetAgents(sl()));
  // sl.registerLazySingleton(() => PostAttendance(sl()));
  // // sl.registerLazySingleton(() => ForgotPassword(sl()));
  // // sl.registerLazySingleton(() => ResetPassword(sl()));
  // // sl.registerLazySingleton(() => Update(sl()));

  // //! Repository
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl(), localDataSource: sl()),
  // );

  // sl.registerLazySingleton<AttendanceRepository>(
  //   () => AttendanceRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  // );

  // // //! Data sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(dioClient: sl(), options: sl(), appInterceptors: sl()),
  // );

  // sl.registerLazySingleton<AttendanceRemoteDataSource>(
  //   () => AttendanceRemoteDataSourceImpl(dioClient: sl(), options: sl()),
  // );

  // sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(localStorage: sl()));

  AndroidOptions getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
  sl.registerLazySingleton(() => FlutterSecureStorage(aOptions: getAndroidOptions()));
  sl.registerLazySingleton(() => const MethodChannel("device_admin"));
  sl.registerLazySingleton(() => FlutterDeviceImei.instance);
  sl.registerLazySingleton(() => DeviceInfoPlugin());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: API_URL,
        connectTimeout: const Duration(seconds: 60000),
        receiveTimeout: const Duration(seconds: 60000),
      ),
    ),
  );

  sl.registerLazySingleton(() => Options(headers: {'Content-Type': 'application/json'}));
  sl.registerLazySingleton(() => DioConnectivityRequestRetrier(connectivity: sl(), dio: sl()));

  sl.registerLazySingleton(() => AppInterceptors(requestRetrier: sl()));
}
