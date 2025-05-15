import 'dart:developer';

import 'package:dom_affrikia_app/core/errors/failures.dart';
import 'package:dom_affrikia_app/core/errors/exceptions.dart';
import 'package:dartz/dartz.dart';

Future<Either<Failure, T>> remoteDataSourceCall<T>(Function function, Future<bool> isConnected) async {
  if (await isConnected) {
    try {
      final remoteData = await function();
      log(" in remote $remoteData");
      return Right(remoteData);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }

  return Left(InternetConnectionFailure());
}
