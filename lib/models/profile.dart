import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/profile.g.dart';

typedef SelectedMap = Map<String, String>;

@JsonSerializable()
class UserInfo {
  int upload;
  int download;
  int total;
  int expire;

  UserInfo({
    int? upload,
    int? download,
    int? total,
    int? expire,
  })  : upload = upload ?? 0,
        download = download ?? 0,
        total = total ?? 0,
        expire = expire ?? 0;

  Map<String, dynamic> toJson() {
    return _$UserInfoToJson(this);
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return _$UserInfoFromJson(json);
  }

  factory UserInfo.formHString(String? info) {
    if (info == null) return UserInfo();
    final list = info.split(";");
    Map<String, int?> map = {};
    for (final i in list) {
      final keyValue = i.trim().split("=");
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
  String? currentGroupName;
  String? url;
  DateTime? lastUpdateDate;
  Duration autoUpdateDuration;
  UserInfo? userInfo;
  bool autoUpdate;
  SelectedMap selectedMap;

  Profile({
    String? id,
    this.label,
    this.url,
    this.currentGroupName,
    this.userInfo,
    this.lastUpdateDate,
    SelectedMap? selectedMap,
    Duration? autoUpdateDuration,
    this.autoUpdate = true,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        autoUpdateDuration = autoUpdateDuration ?? defaultUpdateDuration,
        selectedMap = selectedMap ?? {};

  ProfileType get type =>
      url == null || url?.isEmpty == true ? ProfileType.file : ProfileType.url;

  Future<void> checkAndUpdate() async {
    final isExists = await check();
    if (!isExists) {
      if (url != null) {
        return await update();
      }
    }
  }

  Future<void> update() async {
    final response = await request.getFileResponseForUrl(url!);
    final disposition = response.headers.value("content-disposition");
    label ??= other.getFileNameForDisposition(disposition) ?? id;
    final userinfo = response.headers.value('subscription-userinfo');
    userInfo = UserInfo.formHString(userinfo);
    await saveFile(response.data);
    lastUpdateDate = DateTime.now();
  }

  Future<bool> check() async {
    final profilePath = await appPath.getProfilePath(id);
    return await File(profilePath!).exists();
  }

  Future<void> saveFile(Uint8List bytes) async {
    final message = await clashCore.validateConfig(utf8.decode(bytes));
    if (message.isNotEmpty) {
      throw message;
    }
    final path = await appPath.getProfilePath(id);
    final file = File(path!);
    final isExists = await file.exists();
    if (!isExists) {
      await file.create(recursive: true);
    }
    await file.writeAsBytes(bytes);
    lastUpdateDate = DateTime.now();
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
          currentGroupName == other.currentGroupName &&
          url == other.url &&
          lastUpdateDate == other.lastUpdateDate &&
          autoUpdateDuration == other.autoUpdateDuration &&
          userInfo == other.userInfo &&
          autoUpdate == other.autoUpdate &&
          selectedMap == other.selectedMap;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      currentGroupName.hashCode ^
      url.hashCode ^
      lastUpdateDate.hashCode ^
      autoUpdateDuration.hashCode ^
      userInfo.hashCode ^
      autoUpdate.hashCode ^
      selectedMap.hashCode;

  Profile copyWith({
    String? label,
    String? url,
    UserInfo? userInfo,
    String? currentGroupName,
    String? proxyName,
    DateTime? lastUpdateDate,
    Duration? autoUpdateDuration,
    bool? autoUpdate,
    SelectedMap? selectedMap,
  }) {
    return Profile(
      id: id,
      label: label ?? this.label,
      url: url ?? this.url,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      userInfo: userInfo ?? this.userInfo,
      selectedMap: selectedMap ?? this.selectedMap,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      autoUpdateDuration: autoUpdateDuration ?? this.autoUpdateDuration,
      autoUpdate: autoUpdate ?? this.autoUpdate,
    );
  }
}
