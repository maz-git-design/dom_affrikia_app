part of 'activation_bloc.dart';

abstract class ActivationEvent extends Equatable {
  const ActivationEvent();

  @override
  List<Object> get props => [];
}

class ActivationActivate extends ActivationEvent {
  final String code;

  const ActivationActivate({required this.code});
}

class ActivationCreateBills extends ActivationEvent {
  final BillType billType;

  const ActivationCreateBills({required this.billType});
}

class ActivationGetBillType extends ActivationEvent {}
