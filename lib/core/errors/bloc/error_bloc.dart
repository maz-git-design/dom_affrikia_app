import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'error_event.dart';
part 'error_state.dart';

class ErrorBloc extends Bloc<ErrorEvent, ErrorState> {
  ErrorBloc() : super(ErrorInitial()) {
    on<ErrorOccured>((event, emit) async {
      emit(Error(event.errorMessage));
      await Future.delayed(const Duration(seconds: 1));
      emit(ErrorInitial());
    });
  }
}
