import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/profile.g.dart';

part 'generated/profile.freezed.dart';

typedef SelectedMap = Map<String, String>;

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    @Default(0) int upload,
    @Default(0) int download,
    @Default(0) int total,
    @Default(0) int expire,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, Object?> json) =>
      _$UserInfoFromJson(json);

  factory UserInfo.formHString(String? info) {
    if (info == null) return const UserInfo();
    final list = info.split(";");
    Map<String, int?> map = {};
    for (final i in list) {
      final keyValue = i.trim().split("=");
      map[keyValue[0]] = int.tryParse(keyValue[1]);
    }
    return UserInfo(
      upload: map["upload"] ?? 0,
      download: map["download"] ?? 0,
      total: map["total"] ?? 0,
      expire: map["expire"] ?? 0,
    );
  }
}

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? label,
    String? currentGroupName,
    @Default("") String url,
    DateTime? lastUpdateDate,
    required Duration autoUpdateDuration,
    UserInfo? userInfo,
    @Default(true) bool autoUpdate,
    @Default({}) SelectedMap selectedMap,
    @Default({}) Set<String> unfoldSet,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  factory Profile.normal({
    String? label,
    String url = '',
}) {
    return Profile(
      label: label,
      url: url,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      autoUpdateDuration: defaultUpdateDuration,
    );
  }
}

extension ProfileExtension on Profile {
  ProfileType get type =>
      url.isEmpty == true ? ProfileType.file : ProfileType.url;

  bool get realAutoUpdate =>
      url.isEmpty == true ? false : autoUpdate;

  Future<void> checkAndUpdate() async {
    final isExists = await check();
    if (!isExists) {
      if (url.isNotEmpty) {
        await update();
      }
    }
  }

  Future<bool> check() async {
    final profilePath = await appPath.getProfilePath(id);
    return await File(profilePath!).exists();
  }

  Future<Profile> update() async {
    final response = await request.getFileResponseForUrl(url);
    final disposition = response.headers.value("content-disposition");
    final userinfo = response.headers.value('subscription-userinfo');
    return await copyWith(
      label: label ?? other.getFileNameForDisposition(disposition) ?? id,
      userInfo: UserInfo.formHString(userinfo),
    ).saveFile(response.data);
  }

  Future<Profile> saveFile(Uint8List bytes) async {
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
    return copyWith(lastUpdateDate: DateTime.now());
  }

  Future<Profile> saveFileWithString(String value) async {
    final message = await clashCore.validateConfig(value);
    if (message.isNotEmpty) {
      throw message;
    }
    final path = await appPath.getProfilePath(id);
    final file = File(path!);
    final isExists = await file.exists();
    if (!isExists) {
      await file.create(recursive: true);
    }
    await file.writeAsString(value);
    return copyWith(lastUpdateDate: DateTime.now());
  }
}
