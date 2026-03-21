import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/core/config/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

FlutterSecureStorage secureStorage =
    const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
InternetConnectionChecker internetConnectionChecker = InternetConnectionChecker.createInstance();

Options options = Options(headers: {'Content-Type': 'application/json', 'deviceTypeId': '1'});
Dio dio = Dio(
  BaseOptions(
    baseUrl: API_URL,
    connectTimeout: const Duration(seconds: 60000),
    receiveTimeout: const Duration(seconds: 60000),
  ),
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
