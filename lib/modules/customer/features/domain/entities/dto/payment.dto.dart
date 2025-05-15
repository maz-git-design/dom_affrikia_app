import 'dart:convert';

class Payment {
  final String? billNo;
  final double? payAmount;
  final String? mobile;
  final String? description;

  const Payment({
    this.billNo,
    this.payAmount,
    this.mobile,
    this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      billNo: json['billNo']?.toString(),
      payAmount: json['payAmount'] != null ? (json['payAmount'] as num).toDouble() : null,
      mobile: json['mobile'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billNo': billNo,
      'payAmount': payAmount,
      'mobile': mobile,
      'description': description,
    };
  }

  factory Payment.fromString(String jsonString) {
    return Payment.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
