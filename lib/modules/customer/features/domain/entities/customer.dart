import 'dart:convert';

class Customer {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? relativesPhoneNumber;
  final String? idCard;
  final String? email;
  final String? country;
  final String? city;
  final String? address;
  final int? overdueTimes;
  final double? overdueAmount;
  final int? repaymentTimes;
  final double? repaymentAmount;
  final DateTime? createTime;
  final String? birth;
  final String? momoAccount;
  final String? activeCode;
  final int? clerkId;
  final String? clerkName;
  final String? pic;
  final String? faceIdCardPic;
  final String? fingerPrint;

  const Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.relativesPhoneNumber,
    this.idCard,
    this.email,
    this.country,
    this.city,
    this.address,
    this.overdueTimes,
    this.overdueAmount,
    this.repaymentTimes,
    this.repaymentAmount,
    this.createTime,
    this.birth,
    this.momoAccount,
    this.activeCode,
    this.clerkId,
    this.clerkName,
    this.pic,
    this.faceIdCardPic,
    this.fingerPrint,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      relativesPhoneNumber: json['relativesPhoneNumber'] as String?,
      idCard: json['idCard'] as String?,
      email: json['email'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      overdueTimes: json['overdueTimes'] as int?,
      overdueAmount: json['overdueAmount'] != null ? (json['overdueAmount'] as num).toDouble() : null,
      repaymentTimes: json['repaymentTimes'] as int?,
      repaymentAmount: json['repaymentAmount'] != null ? (json['repaymentAmount'] as num).toDouble() : null,
      createTime: json['createTime'] != null ? DateTime.parse(json['createTime'] as String) : null,
      birth: json['birth'] as String?,
      momoAccount: json['momoAccount'] as String?,
      activeCode: json['activeCode'] as String?,
      clerkId: json['clerkId'] as int?,
      clerkName: json['clerkName'] as String?,
      pic: json['pic'] as String?,
      faceIdCardPic: json['faceIdCardPic'] as String?,
      fingerPrint: json['fingerPrint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'relativesPhoneNumber': relativesPhoneNumber,
      'idCard': idCard,
      'email': email,
      'country': country,
      'city': city,
      'address': address,
      'overdueTimes': overdueTimes,
      'overdueAmount': overdueAmount,
      'repaymentTimes': repaymentTimes,
      'repaymentAmount': repaymentAmount,
      'createTime': createTime?.toIso8601String(),
      'birth': birth,
      'momoAccount': momoAccount,
      'activeCode': activeCode,
      'clerkId': clerkId,
      'clerkName': clerkName,
      'pic': pic,
      'faceIdCardPic': faceIdCardPic,
      'fingerPrint': fingerPrint,
    };
  }

  factory Customer.fromString(String jsonString) {
    return Customer.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
