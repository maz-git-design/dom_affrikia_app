part of 'activation_bloc.dart';

abstract class ActivationState extends Equatable {
  const ActivationState();

  @override
  List<Object> get props => [];
}

class ActivationInitial extends ActivationState {}

class ActivationDone extends ActivationState {
  final String message;
  const ActivationDone(this.message);
}

class ActivationLoading extends ActivationState {}

class ActivationBillTypesLoaded extends ActivationState {}

class ActivationError extends ActivationState {
  final String message;

  const ActivationError(this.message);
}
