import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part 'generated/profile.g.dart';

@JsonSerializable()
class UserInfo {
  int upload;
  int download;
  int total;
  int? expire;

  UserInfo({
    int? upload,
    int? download,
    int? total,
    this.expire,
  })  : upload = upload ?? 0,
        download = download ?? 0,
        total = total ?? 0;

  Map<String, dynamic> toJson() {
    return _$UserInfoToJson(this);
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return _$UserInfoFromJson(json);
  }

  factory UserInfo.formHString(String? info) {
    if (info == null) return UserInfo();
    var list = info.split(";");
    Map<String, int?> map = {};
    for (var i in list) {
      var keyValue = i.trim().split("=");
      map[keyValue[0]] = int.tryParse(keyValue[1]);
    }
    return UserInfo(
      upload: map["upload"],
      download: map["download"],
      total: map["total"],
      expire: map["expire"],
    );
  }

  @override
  String toString() {
    return 'UserInfo{upload: $upload, download: $download, total: $total, expire: $expire}';
  }
}

@JsonSerializable()
class Profile {
  String id;
  String? label;
  String? groupName;
  String? proxyName;
  String? url;
  DateTime? lastUpdateDate;
  Duration autoUpdateDuration;
  UserInfo? userInfo;
  bool autoUpdate;

  Profile({
    String? id,
    this.label,
    this.url,
    this.userInfo,
    this.groupName,
    this.proxyName,
    this.lastUpdateDate,
    Duration? autoUpdateDuration,
    this.autoUpdate = true,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        autoUpdateDuration =
            autoUpdateDuration ?? appConstant.defaultUpdateDuration;

  ProfileType get type => url == null ? ProfileType.file : ProfileType.url;

  Future<Result<bool>> update() async {
    if (url == null) {
      return Result.error(
        message: appLocalizations.unableToUpdateCurrentProfileDesc,
      );
    }
    final responseResult = await Request.getFileResponseForUrl(url!);
    final response = responseResult.data;
    if (responseResult.type != ResultType.success || response == null) {
      return Result.error(message: responseResult.message);
    }
    final disposition = response.headers['content-disposition'];
    if (disposition != null && label == null) {
      final parseValue = HeaderValue.parse(disposition);
      parseValue.parameters.forEach(
        (key, value) {
          if (key.startsWith("filename")) {
            if (key == "filename*") {
              label = Uri.decodeComponent((value ?? "").split("'").last);
            } else {
              label = value ?? id;
            }
          }
        },
      );
    }
    final userinfo = response.headers['subscription-userinfo'];
    userInfo = UserInfo.formHString(userinfo);
    final saveResult = await saveFile(response.bodyBytes);
    if (saveResult.type == ResultType.error) {
      return Result.error(message: saveResult.message);
    }
    lastUpdateDate = DateTime.now();
    return Result.success();
  }

  Future<bool> check() async {
    final profilePath = await appPath.getProfilePath(id);
    return await File(profilePath!).exists();
  }

  Future<Result<void>> saveFile(Uint8List bytes) async {
    final isValidate = clashCore.validateConfig(utf8.decode(bytes));
    if (!isValidate) {
      return Result.error(message: appLocalizations.profileParseErrorDesc);
    }
    final path = await appPath.getProfilePath(id);
    final file = File(path!);
    final isExists = await file.exists();
    if (!isExists) {
      await file.create(recursive: true);
    }
    await file.writeAsBytes(bytes);
    lastUpdateDate = DateTime.now();
    return Result.success();
  }

  Map<String, dynamic> toJson() {
    return _$ProfileToJson(this);
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return _$ProfileFromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          groupName == other.groupName &&
          proxyName == other.proxyName &&
          url == other.url &&
          lastUpdateDate == other.lastUpdateDate &&
          autoUpdateDuration == other.autoUpdateDuration &&
          userInfo == other.userInfo &&
          autoUpdate == other.autoUpdate;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      groupName.hashCode ^
      proxyName.hashCode ^
      url.hashCode ^
      lastUpdateDate.hashCode ^
      autoUpdateDuration.hashCode ^
      userInfo.hashCode ^
      autoUpdate.hashCode;

  @override
  String toString() {
    return 'Profile{id: $id, label: $label, groupName: $groupName, proxyName: $proxyName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, userInfo: $userInfo, autoUpdate: $autoUpdate}';
  }

  Profile copyWith({
    String? label,
    String? url,
    UserInfo? userInfo,
    String? groupName,
    String? proxyName,
    DateTime? lastUpdateDate,
    Duration? autoUpdateDuration,
    bool? autoUpdate,
  }) {
    return Profile(
      id: id,
      label: label ?? this.label,
      url: url ?? this.url,
      groupName: groupName ?? this.groupName,
      proxyName: proxyName ?? this.proxyName,
      userInfo: userInfo ?? this.userInfo,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      autoUpdateDuration: autoUpdateDuration ?? this.autoUpdateDuration,
      autoUpdate: autoUpdate ?? this.autoUpdate,
    );
  }
}
