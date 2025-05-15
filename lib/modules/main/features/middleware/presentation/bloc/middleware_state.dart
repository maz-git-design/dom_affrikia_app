part of 'middleware_bloc.dart';

abstract class MiddlewareState extends Equatable {
  const MiddlewareState();  

  @override
  List<Object> get props => [];
}
class MiddlewareInitial extends MiddlewareState {}
