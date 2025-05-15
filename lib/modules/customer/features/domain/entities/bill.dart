import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Bill extends Equatable {
  final String? id;
  final String? billTypeCode;
  final String? billNo;
  final String? customerId;
  final double? billAmount;
  final String? deviceId;
  final int? billStatus;
  final DateTime? createTime;
  final DateTime? notifyTime;
  final DateTime? overdueTime;
  final DateTime? payTime;
  final double? settledAmount;
  final String? customerName;
  final String? deviceCode;
  final String? lastOrderId;

  const Bill({
    this.id,
    this.billTypeCode,
    this.billNo,
    this.customerId,
    this.billAmount,
    this.deviceId,
    this.billStatus,
    this.createTime,
    this.notifyTime,
    this.overdueTime,
    this.payTime,
    this.settledAmount,
    this.customerName,
    this.deviceCode,
    this.lastOrderId,
  });

  /// copyWith method
  Bill copyWith({
    String? id,
    String? billTypeCode,
    String? billNo,
    String? customerId,
    double? billAmount,
    String? deviceId,
    int? billStatus,
    DateTime? createTime,
    DateTime? notifyTime,
    DateTime? overdueTime,
    DateTime? payTime,
    double? settledAmount,
    String? customerName,
    String? deviceCode,
    String? lastOrderId,
  }) {
    return Bill(
      id: id ?? this.id,
      billTypeCode: billTypeCode ?? this.billTypeCode,
      billNo: billNo ?? this.billNo,
      customerId: customerId ?? this.customerId,
      billAmount: billAmount ?? this.billAmount,
      deviceId: deviceId ?? this.deviceId,
      billStatus: billStatus ?? this.billStatus,
      createTime: createTime ?? this.createTime,
      notifyTime: notifyTime ?? this.notifyTime,
      overdueTime: overdueTime ?? this.overdueTime,
      payTime: payTime ?? this.payTime,
      settledAmount: settledAmount ?? this.settledAmount,
      customerName: customerName ?? this.customerName,
      deviceCode: deviceCode ?? this.deviceCode,
      lastOrderId: lastOrderId ?? this.lastOrderId,
    );
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String?,
      billTypeCode: json['billTypeCode'] as String?,
      billNo: json['billNo'] as String?,
      customerId: json['customerId'] as String?,
      billAmount: json['billAmount'] != null ? (json['billAmount'] as num).toDouble() : null,
      deviceId: json['deviceId'] as String?,
      billStatus: json['billStatus'] as int?,
      createTime: json['createTime'] != null ? DateTime.parse(json['createTime'] as String) : null,
      notifyTime: json['notifyTime'] != null ? DateTime.parse(json['notifyTime'] as String) : null,
      overdueTime: json['overdueTime'] != null ? DateTime.parse(json['overdueTime'] as String) : null,
      payTime: json['payTime'] != null ? DateTime.parse(json['payTime'] as String) : null,
      settledAmount: json['settledAmount'] != null ? (json['settledAmount'] as num).toDouble() : null,
      customerName: json['customerName'] as String?,
      deviceCode: json['deviceCode'] as String?,
      lastOrderId: json['lastOrderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billTypeCode': billTypeCode,
      'billNo': billNo,
      'customerId': customerId,
      'billAmount': billAmount,
      'deviceId': deviceId,
      'billStatus': billStatus,
      'createTime': createTime?.toIso8601String(),
      'notifyTime': notifyTime?.toIso8601String(),
      'overdueTime': overdueTime?.toIso8601String(),
      'payTime': payTime?.toIso8601String(),
      'settledAmount': settledAmount,
      'customerName': customerName,
      'deviceCode': deviceCode,
      'lastOrderId': lastOrderId,
    };
  }

  @override
  List<Object?> get props => [id];

  // bool get isOverdue => overdueTime!= null && overdueTime.isBefore(DateTime.now());
  bool get hasOverdue => overdueTime != null;
  String get getOverDueDate => overdueTime != null ? DateFormat('dd-MM-yyyy').format(overdueTime!) : "Pas de date";
  String get getBillAmount =>
      billAmount != null ? NumberFormat.currency(symbol: "GNF ", locale: 'fr').format(billAmount!) : "Pas trouvé";
}
