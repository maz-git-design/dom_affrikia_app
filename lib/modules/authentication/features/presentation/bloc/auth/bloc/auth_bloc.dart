// import 'package:bloc/bloc.dart';
// import 'package:dom_affrikia_app/injection_container.dart';
// import 'package:dom_affrikia_app/modules/authentication/features/presentation/bloc/user/bloc/user_bloc.dart';
// import 'package:equatable/equatable.dart';

// import '../../../../domain/usecases/login.dart';

// import '../../../providers/auth_data_provider.dart';

// part 'auth_event.dart';
// part 'auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final Login login;
//   final AuthController authController;
//   final AuthDataProvider authDataProvider;

//   AuthBloc({required this.login, required this.authController, required this.authDataProvider}) : super(AuthInitial()) {
//     on<AuthLoginButtonPressed>((event, emit) async {
//       emit(AuthLoginLoading());

//       // final result = await login(
//       //   LoginParams(email: authController.emailAddress.text, password: authController.passwordController.text),
//       // );

//       // result.fold((failure) => emit(AuthError(failure.toString())), (user) {
//       //   authDataProvider.user = user;
//       //   if (authDataProvider.user.userRole == UserEnum.unknown) {
//       //     emit(AuthError('You cannot get connected into the app as a(n) ${authDataProvider.user.role}'));
//       //     // emit(AuthInitial());
//       //   } else {
//       //     authDataProvider.user = user;
//       //     sl<UserBloc>().add(UserLoggedin());
//       //     emit(AuthInitial());

//       //   }
//       // });

//       sl<UserBloc>().add(UserLoggedin());
//     });
//   }
// }
