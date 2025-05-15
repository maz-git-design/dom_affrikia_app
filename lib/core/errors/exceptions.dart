import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Either<List<String>, String>? error;
  final RequestOptions? requestOptions;

  ServerException({
    required this.message,
    this.requestOptions,
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return message;
  }
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() {
    return message;
  }
}
