// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';

// import '../../../../../../../core/errors/failures.dart';
// import '../../../../../../../core/usecases/usecases.dart';
// import '../repositories/auth_repository.dart';

// class CacheToken implements UseCase<void, CacheTokenParams> {
//   final AuthRepository authRepository;

//   CacheToken(this.authRepository);

//   @override
//   Future<Either<Failure, void>> call(CacheTokenParams params) async {
//     return await authRepository.cacheToken(params.accessToken);
//   }
// }

// class CacheTokenParams extends Equatable {
//   final String accessToken;

//   const CacheTokenParams({
//     required this.accessToken,
//   });

//   @override
//   List<Object> get props => [accessToken];
// }
