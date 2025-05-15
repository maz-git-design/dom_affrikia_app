import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final MainDataProvider mainDataProvider;
  NavigationBloc(this.mainDataProvider)
      : super(
            mainDataProvider.isPhoneCompletelyActivated ? NavigationCustomerLogin() : NavigationCustomerActivation()) {
    on<NavigationAdmin>((event, emit) => emit(NavigationAdminLogin()));
    on<NavigationLaunchCustomerActivation>((event, emit) => emit(NavigationCustomerActivation()));
    on<NavigationLaunchCustomerLogin>((event, emit) => emit(NavigationCustomerLogin()));
  }
}
