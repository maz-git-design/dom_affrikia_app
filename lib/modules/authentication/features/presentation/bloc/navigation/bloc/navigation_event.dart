part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigationLoginButtonPressed extends NavigationEvent {}

class NavigationSignupButtonPressed extends NavigationEvent {}

class NavigationResetPasswordSucceeded extends NavigationEvent {}

class NavigationLoginSucceeded extends NavigationEvent {}

class NavigationSendResetCodePassed extends NavigationEvent {}

class NavigationSignupSucceeded extends NavigationEvent {}

class NavigationForgotPasswordButtonPressed extends NavigationEvent {}
