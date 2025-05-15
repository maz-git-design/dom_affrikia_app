part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigationAdmin extends NavigationEvent {}

class NavigationLaunchCustomerActivation extends NavigationEvent {}

class NavigationLaunchCustomerLogin extends NavigationEvent {}
