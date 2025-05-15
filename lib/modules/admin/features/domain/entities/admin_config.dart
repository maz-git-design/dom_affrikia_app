import 'package:dom_affrikia_app/core/enums/admin.config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class AdminConfig extends Equatable {
  final String title;
  final AdminConfigEnum config;
  final String? description;
  final bool state;
  final bool loading;
  final String methodName;
  final IconData? icon;

  const AdminConfig({
    required this.title,
    this.icon,
    this.description,
    required this.state,
    required this.methodName,
    this.loading = false,
    required this.config,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "config": config.toString(),
        "description": description,
        "state": state,
        "methodName": methodName,
      };

  factory AdminConfig.fromJson(Map<String, dynamic> json) => AdminConfig(
        title: json["title"],
        config: AdminConfigEnum.values.firstWhere((e) => e.toString() == json["config"]),
        description: json["description"],
        state: json["state"],
        methodName: json["methodName"],
      );

  AdminConfig copyWith(
      {String? title,
      AdminConfigEnum? config,
      String? description,
      bool? state,
      bool? loading,
      String? methodName,
      IconData? icon}) {
    return AdminConfig(
      title: title ?? this.title,
      config: config ?? this.config,
      description: description ?? this.description,
      state: state ?? this.state,
      loading: loading ?? this.loading,
      methodName: methodName ?? this.methodName,
      icon: icon ?? this.icon,
    );
  }

  bool get isAdminConfigMode => config == AdminConfigEnum.adminMode;
  bool get isActivatePhone => config == AdminConfigEnum.activatePhone;

  @override
  List<Object?> get props => [title];
}
