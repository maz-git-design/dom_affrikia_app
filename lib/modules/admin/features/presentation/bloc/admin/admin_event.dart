part of 'admin_bloc.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class AdminToggleOption extends AdminEvent {
  final AdminConfig option;
  final bool newState;
  final int optionIndex;
  const AdminToggleOption({
    required this.option,
    required this.newState,
    required this.optionIndex,
  });
}

class AdminGetAdminConfigs extends AdminEvent {}

class AdminLoadData extends AdminEvent {}

class AdminLogin extends AdminEvent {
  final String code;

  const AdminLogin({required this.code});
}

class AdminCleanData extends AdminEvent {}
