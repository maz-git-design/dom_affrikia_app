import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'customer_bill_event.dart';
part 'customer_bill_state.dart';

class CustomerBillBloc extends Bloc<CustomerBillEvent, CustomerBillState> {
  CustomerBillBloc() : super(CustomerBillInitial()) {
    on<CustomerBillEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
