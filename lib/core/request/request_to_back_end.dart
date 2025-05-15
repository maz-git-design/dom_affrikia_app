import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

Future<T> requestToBackend<T>(Function requestFunction, Function constructor) async {
  try {
    final response = await requestFunction();
    log('Got Response');
    final responseData = jsonDecode(jsonEncode(response.data));
    final returnResponse = constructor(responseData);

    log("Response: $responseData");

    return responseData;
  } on DioException catch (error) {
    var errorData = error.response;
    // print('Dio error: ' + error.toString());
    // print('Error message:' + error.message!);
    // print('Error details:' + errorData.toString());
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw ServerException(message: 'Connection Timeout', requestOptions: error.requestOptions);
    } else if (errorData != null && errorData.statusCode == 500) {
      throw ServerException(message: 'Server Error. Try Later');
    } else if (errorData != null && errorData.statusCode == 403) {
      throw ServerException(message: error.response!.data['message'].toString());
    }
    if (errorData != null && errorData.data != null) {
      throw ServerException(message: error.response!.data['message'].toString());
    } else {
      throw ServerException(message: error.message ?? '');
    }
  }
}
