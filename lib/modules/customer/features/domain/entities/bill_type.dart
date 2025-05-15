import 'package:equatable/equatable.dart';

class BillType extends Equatable {
  final String typeCode;
  final String typeName;
  final int timePeriod;
  final int remindPeriod;
  final int billGenerationCycle;
  final int isOpen;

  const BillType({
    required this.typeCode,
    required this.typeName,
    required this.timePeriod,
    required this.remindPeriod,
    required this.billGenerationCycle,
    required this.isOpen,
  });

  factory BillType.fromJson(Map<String, dynamic> json) {
    return BillType(
      typeCode: json['typeCode'] as String,
      typeName: json['typeName'] as String,
      timePeriod: json['timePeriod'] as int,
      remindPeriod: json['remindPeriod'] as int,
      billGenerationCycle: json['billGenerationCycle'] as int,
      isOpen: json['isOpen'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeCode': typeCode,
      'typeName': typeName,
      'timePeriod': timePeriod,
      'remindPeriod': remindPeriod,
      'billGenerationCycle': billGenerationCycle,
      'isOpen': isOpen,
    };
  }

  @override
  List<Object?> get props => [
        typeCode,
        typeName,
        timePeriod,
        remindPeriod,
        billGenerationCycle,
        isOpen,
      ];
}
