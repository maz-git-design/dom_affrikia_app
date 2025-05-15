import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  //! Session management
  Future<void> deleteUserToken();
  Future<bool> hasToken();
  Future<String?> getToken();
  Future<void> cacheToken(String accessToken);
}

const TOKEN = 'TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage localStorage;

  AuthLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheToken(String accessToken) {
    return localStorage.write(key: TOKEN, value: accessToken);
  }

  @override
  Future<void> deleteUserToken() {
    return localStorage.delete(key: TOKEN);
  }

  @override
  Future<String?> getToken() {
    return localStorage.read(key: TOKEN);
  }

  @override
  Future<bool> hasToken() {
    return localStorage.containsKey(key: TOKEN);
  }
}
