part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserAuthenticated extends UserState {}

class UserNotAuthenticated extends UserState {}

class UserLoading extends UserState {}
