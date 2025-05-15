import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

class ServerFailure extends Failure {
  final String message;
  final RequestOptions? requestOptions;

  const ServerFailure({
    required this.message,
    this.requestOptions,
  });

  @override
  String toString() {
    return message;
  }

  @override
  List<Object?> get props => [message];
}

class InternetConnectionFailure extends Failure {
  final String message = 'No Internet Connection';

  @override
  String toString() {
    return message;
  }

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  const CacheFailure(this.message);

  @override
  String toString() {
    return message;
  }

  @override
  List<Object?> get props => [message];
}
