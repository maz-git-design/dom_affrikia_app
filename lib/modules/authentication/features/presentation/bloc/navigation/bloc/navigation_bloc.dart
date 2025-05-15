import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationLogin()) {
    on<NavigationLoginButtonPressed>((event, emit) => emit(NavigationLogin()));

    on<NavigationSignupButtonPressed>(
        (event, emit) => emit(NavigationSignup()));

    on<NavigationForgotPasswordButtonPressed>(
        (event, emit) => emit(NavigationResetPassword1()));

    on<NavigationResetPasswordSucceeded>(
        (event, emit) => emit(NavigationResetPasswordSuccess()));

    on<NavigationSendResetCodePassed>(
        (event, emit) => emit(NavigationResetPassword2()));

    on<NavigationLoginSucceeded>((event, emit) => emit(NavigationOtp()));

    on<NavigationSignupSucceeded>(
        (event, emit) => emit(NavigationSignupSuccess()));
  }
}
