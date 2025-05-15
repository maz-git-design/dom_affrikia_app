part of 'customer_bloc.dart';

sealed class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class CustomerLoadInfo extends CustomerEvent {}

class CustomerLogin extends CustomerEvent {
  final String code;

  const CustomerLogin({required this.code});
}

class CustomerLogout extends CustomerEvent {}

class CustomerGetBills extends CustomerEvent {}

class CustomerPayBill extends CustomerEvent {
  final Bill billToPay;
  final String phone;

  const CustomerPayBill({required this.billToPay, required this.phone});
}

class CustomerGetTransactionStatus extends CustomerEvent {
  final String orderId;
  final int billIndex;

  const CustomerGetTransactionStatus({required this.orderId, required this.billIndex});
}
