import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'middleware_event.dart';
part 'middleware_state.dart';

class MiddlewareBloc extends Bloc<MiddlewareEvent, MiddlewareState> {
  MiddlewareBloc() : super(MiddlewareInitial()) {
    on<MiddlewareEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
