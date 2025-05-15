import 'dart:convert';

class Device {
  final String? id;
  final String? deviceCode;
  final String? deviceImei;
  final double? devicePrice;
  final double? activationFee;
  final String? deviceBindPhones;
  final String? bindCustomerId;
  final String? bindCustomerName;
  final int? deviceStatus;
  final String? deviceBindAgent;
  final double? latitude;
  final double? longitude;
  final String? fireToken;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? deviceTypeId;

  const Device({
    this.id,
    this.deviceCode,
    this.deviceImei,
    this.devicePrice,
    this.activationFee,
    this.deviceBindPhones,
    this.bindCustomerId,
    this.bindCustomerName,
    this.deviceStatus,
    this.deviceBindAgent,
    this.latitude,
    this.longitude,
    this.fireToken,
    this.createTime,
    this.updateTime,
    this.deviceTypeId,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString(),
      deviceCode: json['deviceCode'] as String?,
      deviceImei: json['deviceImei'] as String?,
      devicePrice: json['devicePrice'] != null ? (json['devicePrice'] as num).toDouble() : null,
      activationFee: json['activationFee'] != null ? (json['activationFee'] as num).toDouble() : null,
      deviceBindPhones: json['deviceBindPhones'] as String?,
      bindCustomerId: json['bindCustomerId']?.toString(),
      bindCustomerName: json['bindCustomerName'] as String?,
      deviceStatus: json['deviceStatus'] as int?,
      deviceBindAgent: json['deviceBindAgent']?.toString(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      fireToken: json['fireToken'] as String?,
      createTime: json['createTime'] != null ? DateTime.parse(json['createTime']) : null,
      updateTime: json['updateTime'] != null ? DateTime.parse(json['updateTime']) : null,
      deviceTypeId: json['deviceTypeId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceCode': deviceCode,
      'deviceImei': deviceImei,
      'devicePrice': devicePrice,
      'activationFee': activationFee,
      'deviceBindPhones': deviceBindPhones,
      'bindCustomerId': bindCustomerId,
      'bindCustomerName': bindCustomerName,
      'deviceStatus': deviceStatus,
      'deviceBindAgent': deviceBindAgent,
      'latitude': latitude,
      'longitude': longitude,
      'fireToken': fireToken,
      'createTime': createTime?.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'deviceTypeId': deviceTypeId,
    };
  }

  factory Device.fromString(String jsonString) {
    return Device.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
