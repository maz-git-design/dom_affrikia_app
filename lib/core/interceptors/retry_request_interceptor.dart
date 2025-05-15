import 'dart:async';
import 'package:dom_affrikia_app/core/errors/bloc/error_bloc.dart';

import 'package:dio/dio.dart';

import '../../injection_container.dart';
import 'dio_connectivity_request_retrier.dart';

class AppInterceptors extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;
  //final AuthLocalDataSource authLocalDataSource;

  AppInterceptors({
    required this.requestRetrier,
    //required this.authLocalDataSource,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (await _shouldRetry(err)) {
      String message = '';
      if (err.type == DioExceptionType.connectionTimeout) {
        message = 'Connection Timeout. Retrying...';
      }
      sl<ErrorBloc>().add(ErrorOccured(message));

      try {
        var response = await requestRetrier.scheduleRequestRetry(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        rethrow;
      }
    } else {
      handler.next(err);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // var accessToken = await authLocalDataSource.getToken();

    // if (accessToken != null) {
    //   options.headers['Authorization'] = 'Bearer $accessToken';
    // }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // if (response.headers['x-auth-token'] != null) {
    //   var accessToken = response.headers['x-auth-token']![0];
    //   authLocalDataSource.cacheToken(accessToken);
    // }
    return handler.next(response);
  }

  FutureOr<bool> _shouldRetry(DioException error) {
    var hasRetry = (error.type != DioExceptionType.badResponse) &&
        (error.type != DioExceptionType.unknown) &&
        (error.type != DioExceptionType.cancel);

    //return hasRetry && sl<AuthRamDS>().shouldRetry;

    return hasRetry;
  }
}
