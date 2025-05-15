// import 'package:dartz/dartz.dart';

// import '../../../../../../core/errors/exceptions.dart';
// import '../../../../../../core/errors/failures.dart';
// import '../../../../../../core/platform/network_info.dart';
// import '../../../../../../core/request/request_to_back_end_repo_call.dart';
// import '../../domain/entities/user.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../datasources/auth_local_data_source.dart';
// import '../datasources/auth_remote_data_source.dart';
// import '../models/user_model.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDataSource remoteDataSource;
//   final AuthLocalDataSource localDataSource;
//   final NetworkInfo networkInfo;

//   AuthRepositoryImpl({
//     required this.remoteDataSource,
//     required this.localDataSource,
//     required this.networkInfo,
//   });

//   //! Authentication--------------------

//   @override
//   Future<Either<Failure, User>> login({required String email, required String password}) {
//     return remoteDataSourceCall<UserModel>(
//       () => remoteDataSource.login(email: email, password: password),
//       networkInfo.isConnected,
//     );
//   }

//   @override
//   Future<Either<Failure, void>> signup({required User user}) {
//     return remoteDataSourceCall<void>(
//       () => remoteDataSource.signup(user: user),
//       networkInfo.isConnected,
//     );
//   }

//   @override
//   Future<Either<Failure, User>> verify({required String userId, required String pinCode}) {
//     return remoteDataSourceCall<UserModel>(
//       () => remoteDataSource.verify(userId: userId, pinCode: pinCode),
//       networkInfo.isConnected,
//     );
//   }

//   @override
//   Future<Either<Failure, User>> update({required User user}) {
//     return remoteDataSourceCall<UserModel>(
//       () => remoteDataSource.update(user: user),
//       networkInfo.isConnected,
//     );
//   }

//   @override
//   Future<Either<Failure, User>> forgotPassword({required String phone}) {
//     return remoteDataSourceCall<UserModel>(
//       () => remoteDataSource.forgotPassword(phone: phone),
//       networkInfo.isConnected,
//     );
//   }

//   @override
//   Future<Either<Failure, User>> resetPassword(
//       {required String userId, required String pinCode, required String password}) {
//     return remoteDataSourceCall<UserModel>(
//       () => remoteDataSource.resetPassword(userId: userId, pinCode: pinCode, password: password),
//       networkInfo.isConnected,
//     );
//   }

//   @override
//   Future<Either<Failure, void>> cacheToken(String accessToken) {
//     return localDataSourceCall<void>(() => localDataSource.cacheToken(accessToken));
//   }

//   @override
//   Future<Either<Failure, void>> deleteUserToken() {
//     return localDataSourceCall<void>(() => localDataSource.deleteUserToken());
//   }

//   @override
//   Future<Either<Failure, String?>> getToken() {
//     return localDataSourceCall<String?>(() => localDataSource.getToken());
//   }

//   @override
//   Future<Either<Failure, bool>> hasToken() {
//     return localDataSourceCall<bool>(() => localDataSource.hasToken());
//   }

//   //! Utils Function----------------

//   Future<Either<Failure, T>> localDataSourceCall<T>(Function function) async {
//     try {
//       final result = await function();
//       return Right(result);
//     } on CacheException catch (error) {
//       return Left(CacheFailure(error.toString()));
//     }
//   }
// }
