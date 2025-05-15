part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationLogin extends NavigationState {}

class NavigationSignup extends NavigationState {}

class NavigationResetPassword1 extends NavigationState {}

class NavigationResetPassword2 extends NavigationState {}

class NavigationSignupSuccess extends NavigationState {}

class NavigationResetPasswordSuccess extends NavigationState {}

class NavigationOtp extends NavigationState {}
