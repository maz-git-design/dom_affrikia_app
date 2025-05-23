import 'dart:convert';

import 'package:equatable/equatable.dart';

class AppUpdateInfo extends Equatable {
  final String? id;
  final int? versionCode;
  final String? url;
  final String? content;
  final String? title;
  final int? updateInstall;
  final int? upgradeTag;
  final String? createTime;

  const AppUpdateInfo({
    this.id,
    this.versionCode,
    this.url,
    this.content,
    this.title,
    this.updateInstall,
    this.upgradeTag,
    this.createTime,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      id: json['id'] as String?,
      versionCode: json['versionCode'] as int?,
      url: json['url'] as String?,
      content: json['content'] as String?,
      title: json['title'] as String?,
      updateInstall: json['updateInstall'] as int?,
      upgradeTag: json['upgradeTag'] as int?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'versionCode': versionCode,
      'url': url,
      'content': content,
      'title': title,
      'updateInstall': updateInstall,
      'upgradeTag': upgradeTag,
      'createTime': createTime,
    };
  }

  factory AppUpdateInfo.fromString(String jsonString) {
    return AppUpdateInfo.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [id];
}
