import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/authentication/features/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserLoggedin>((event, emit) => emit(UserAuthenticated()));
    on<UserLoggedout>((event, emit) async {
      emit(UserLogoutLoading());
      await Future.delayed(const Duration(seconds: 2));

      sl<NavigationBloc>().add(NavigationLoginButtonPressed());
      emit(UserUnAuthenticated());
    });
  }
}
