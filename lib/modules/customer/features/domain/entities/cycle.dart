import 'package:dom_affrikia_app/core/enums/cycle.enum.dart';
import 'package:equatable/equatable.dart';

class Cycle extends Equatable {
  final String name;
  final CycleEnum? value;
  final int count;
  final CycleDurationEnum duration;

  const Cycle({required this.name, this.value, this.duration = CycleDurationEnum.unknown, this.count = 0});

  @override
  List<Object?> get props => [name, value, duration];
}
