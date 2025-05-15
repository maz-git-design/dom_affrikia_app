import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserLoggedIn>((event, emit) => emit(UserAuthenticated()));
    on<UserLoggedOut>((event, emit) async {
      emit(UserLoading());
      await Future.delayed(const Duration(seconds: 2));

      // Logic to clear user data or perform logout actionsw
      emit(UserNotAuthenticated());
    });
  }
}
