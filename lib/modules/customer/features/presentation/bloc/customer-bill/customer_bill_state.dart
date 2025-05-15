part of 'customer_bill_bloc.dart';

sealed class CustomerBillState extends Equatable {
  const CustomerBillState();
  
  @override
  List<Object> get props => [];
}

final class CustomerBillInitial extends CustomerBillState {}
