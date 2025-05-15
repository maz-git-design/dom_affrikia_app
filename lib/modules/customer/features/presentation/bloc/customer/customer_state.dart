part of 'customer_bloc.dart';

sealed class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

final class CustomerInitial extends CustomerState {}

final class CustomerInfoLoaded extends CustomerState {}

final class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);
}

final class CustomerPaymentError extends CustomerState {
  final String message;

  const CustomerPaymentError(this.message);
}

final class CustomerLoading extends CustomerState {}

final class CustomerPaymentSuccess extends CustomerState {
  final String message;

  const CustomerPaymentSuccess(this.message);
}

final class CustomerGetPaymentStatusSuccess extends CustomerState {
  final String message;

  const CustomerGetPaymentStatusSuccess(this.message);
}

final class CustomerLoginSuccess extends CustomerState {}
