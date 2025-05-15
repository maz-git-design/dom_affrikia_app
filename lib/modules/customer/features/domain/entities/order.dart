import 'dart:convert';

class Order {
  final String? id;
  final String? orderSn;
  final String? businessNo;
  final String? customerId;
  final double? amount;
  final int? payType;
  final int? status;
  final String? paySn;
  final DateTime? createTime;
  final DateTime? completionTime;
  final String? note;
  final String? failNote;

  const Order({
    this.id,
    this.orderSn,
    this.businessNo,
    this.customerId,
    this.amount,
    this.payType,
    this.status,
    this.paySn,
    this.createTime,
    this.completionTime,
    this.note,
    this.failNote,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      orderSn: json['orderSn'] as String?,
      businessNo: json['businessNo'] as String?,
      customerId: json['customerId']?.toString(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      payType: json['payType'] as int?,
      status: json['status'] as int?,
      paySn: json['paySn'] as String?,
      createTime: json['createTime'] != null ? DateTime.parse(json['createTime']) : null,
      completionTime: json['completionTime'] != null ? DateTime.parse(json['completionTime']) : null,
      note: json['note'] as String?,
      failNote: json['failNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderSn': orderSn,
      'businessNo': businessNo,
      'customerId': customerId,
      'amount': amount,
      'payType': payType,
      'status': status,
      'paySn': paySn,
      'createTime': createTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'note': note,
      'failNote': failNote,
    };
  }

  factory Order.fromString(String jsonString) {
    return Order.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
