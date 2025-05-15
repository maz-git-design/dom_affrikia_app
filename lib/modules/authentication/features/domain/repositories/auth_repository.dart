// import 'package:dartz/dartz.dart';

// import '../../../../../../core/errors/failures.dart';
// import '../entities/user.dart';

// abstract class AuthRepository {
//   //! ----------------Local Data Source----------------
//   Future<Either<Failure, void>> cacheToken(String accessToken);
//   Future<Either<Failure, void>> deleteUserToken();
//   Future<Either<Failure, bool>> hasToken();
//   Future<Either<Failure, String?>> getToken();
//   //! ---------------Remote Data Source----------------
//   Future<Either<Failure, User>> login({required String email, required String password});
//   Future<Either<Failure, User>> verify({required String userId, required String pinCode});
//   Future<Either<Failure, void>> signup({required User user});
//   Future<Either<Failure, User>> update({required User user});

//   Future<Either<Failure, User>> forgotPassword({required String phone});
//   Future<Either<Failure, User>> resetPassword({
//     required String userId,
//     required String pinCode,
//     required String password,
//   });
// }
