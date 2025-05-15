// import 'dart:convert';

// import 'package:dio/dio.dart';

// import '../../../../../../core/interceptors/retry_request_interceptor.dart';
// import '../../../../../../core/request/request_to_back_end.dart';
// import '../../domain/entities/user.dart';
// import '../models/user_model.dart';

// abstract class AuthRemoteDataSource {
//   //! ---------------Remote Data Source----------------
//   //! Analysis
//   Future<UserModel> login({required String email, required String password});
//   Future<void> signup({required User user});
//   Future<UserModel> verify({required String userId, required String pinCode});
//   Future<UserModel> update({required User user});

//   Future<UserModel> forgotPassword({required String phone});
//   Future<UserModel> resetPassword({required String userId, required String pinCode, required String password});
// }

// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   final Dio dioClient;
//   final Options options;
//   final AppInterceptors appInterceptors;

//   AuthRemoteDataSourceImpl({required this.dioClient, required this.options, required this.appInterceptors});

//   @override
//   Future<UserModel> login({required String email, required String password}) {
//     final data = jsonEncode({"email": email, "password": password});

//     //dioClient.interceptors.add(appInterceptors);
//     return requestToBackend<UserModel>(() => dioClient.post('/auth/login', data: data, options: options), (json) {
//       return UserModel.fromJson(json['data']);
//     });
//   }

//   @override
//   Future<void> signup({required User user}) {
//     final data = jsonEncode(user.toJson());

//     return requestToBackend<void>(() => dioClient.post('/authm/register', options: options, data: data), (json) => {});
//   }

//   @override
//   Future<UserModel> verify({required String userId, required String pinCode}) {
//     final data = jsonEncode({"pinCode": pinCode});

//     return requestToBackend<UserModel>(() => dioClient.post('/authm/verify/$userId', data: data, options: options), (
//       json,
//     ) {
//       return UserModel.fromJson(json['user']);
//     });
//   }

//   @override
//   Future<UserModel> forgotPassword({required String phone}) {
//     final data = jsonEncode({"phone": "+243$phone"});

//     return requestToBackend<UserModel>(() => dioClient.post('/auth/forgotpassword', data: data, options: options), (
//       json,
//     ) {
//       return UserModel.fromJson(json['data']);
//     });
//   }

//   @override
//   Future<UserModel> resetPassword({required String userId, required String pinCode, required String password}) {
//     final data = jsonEncode({"pinCode": pinCode, "password": password});

//     return requestToBackend<UserModel>(
//       () => dioClient.post('/auth/resetpassword/$userId', data: data, options: options),
//       (json) {
//         return UserModel.fromJson(json['data']);
//       },
//     );
//   }

//   @override
//   Future<UserModel> update({required User user}) {
//     final data = jsonEncode(user.toEditJson());

//     return requestToBackend<UserModel>(
//       () => dioClient.put('/authm/update/${user.id}', options: options, data: data),
//       (json) => UserModel.fromJson(json['msg']),
//     );
//   }
// }
