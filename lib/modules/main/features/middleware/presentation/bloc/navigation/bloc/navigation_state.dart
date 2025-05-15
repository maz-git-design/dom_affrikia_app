part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationAdminLogin extends NavigationState {}

class NavigationCustomerLogin extends NavigationState {}

class NavigationCustomerActivation extends NavigationState {}

class NavigationLoading extends NavigationState {}
