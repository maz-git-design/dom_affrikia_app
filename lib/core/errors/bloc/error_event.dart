part of 'error_bloc.dart';

abstract class ErrorEvent extends Equatable {
  const ErrorEvent();

  @override
  List<Object> get props => [];
}

class ErrorOccured extends ErrorEvent {
  final String errorMessage;

  const ErrorOccured(this.errorMessage);
}
