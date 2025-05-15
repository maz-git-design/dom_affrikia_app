part of 'admin_bloc.dart';

sealed class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

final class AdminInitial extends AdminState {}

final class AdminLoading extends AdminState {}

final class AdminError extends AdminState {
  final String message;

  const AdminError({required this.message});
}

final class AdminLoaded extends AdminState {}

final class AdminConfigChanged extends AdminState {
  final String message;

  const AdminConfigChanged({required this.message});
}

class AdminLoginSuccess extends AdminState {}
