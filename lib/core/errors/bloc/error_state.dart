part of 'error_bloc.dart';

abstract class ErrorState extends Equatable {
  const ErrorState();

  @override
  List<Object> get props => [];
}

class ErrorInitial extends ErrorState {}

class Error extends ErrorState {
  final String message;

  const Error(this.message);
}
