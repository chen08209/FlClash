import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用版本信息模型
class AppVersion {
  final int id;
  final String os; // 操作系统：Android, Windows, MacOS
  final String version; // 版本号
  final int updateType; // 0为无需更新，1为强制更新，2为提示更新
  final String updateTime; // 更新时间
  final String downloadUrl; // 下载地址

  const AppVersion({
    required this.id,
    required this.os,
    required this.version,
    required this.updateType,
    required this.updateTime,
    required this.downloadUrl,
  });

  /// 从JSON创建AppVersion对象
  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      id: json['id'] as int,
      os: json['os'] as String,
      version: json['ver'] as String,
      updateType: json['update'] as int,
      updateTime: json['updateTime'] as String,
      downloadUrl: json['downUrl'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'os': os,
      'ver': version,
      'update': updateType,
      'updateTime': updateTime,
      'downUrl': downloadUrl,
    };
  }

  /// 获取更新类型描述
  String get updateTypeDescription {
    switch (updateType) {
      case 0:
        return '无需更新';
      case 1:
        return '强制更新';
      case 2:
        return '提示更新';
      default:
        return '未知';
    }
  }

  /// 是否需要更新
  bool get needsUpdate => updateType > 0;

  /// 是否强制更新
  bool get isForcedUpdate => updateType == 1;

  /// 是否提示更新
  bool get isOptionalUpdate => updateType == 2;

  /// 比较版本号
  /// 返回值：
  /// - 负数：当前版本 < 目标版本
  /// - 0：版本相同
  /// - 正数：当前版本 > 目标版本
  static int compareVersions(String currentVersion, String targetVersion) {
    // 移除可能的前缀v
    String cleanCurrent = currentVersion.replaceFirst(RegExp(r'^v'), '');
    String cleanTarget = targetVersion.replaceFirst(RegExp(r'^v'), '');

    List<int> currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> targetParts = cleanTarget.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // 补齐长度
    int maxLength = currentParts.length > targetParts.length ? currentParts.length : targetParts.length;
    while (currentParts.length < maxLength) currentParts.add(0);
    while (targetParts.length < maxLength) targetParts.add(0);

    for (int i = 0; i < maxLength; i++) {
      if (currentParts[i] < targetParts[i]) return -1;
      if (currentParts[i] > targetParts[i]) return 1;
    }
    return 0;
  }

  /// 检查是否有新版本
  static Future<bool> hasNewVersion(String remoteVersion) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      return compareVersions(currentVersion, remoteVersion) < 0;
    } catch (e) {
      print('检查版本失败: $e');
      return false;
    }
  }

  /// 获取当前应用版本信息
  static Future<String> getCurrentVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('获取当前版本失败: $e');
      return '1.0.0'; // 默认版本
    }
  }

  /// 获取当前操作系统
  static String getCurrentOS() {
    // 根据平台返回对应的操作系统名称
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'MacOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppVersion{id: $id, os: $os, version: $version, updateType: $updateType, updateTime: $updateTime, downloadUrl: $downloadUrl}';
  }
}

/// 版本检查响应模型
class VersionCheckResponse {
  final int code;
  final String message;
  final AppVersion? data;

  const VersionCheckResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 从JSON创建VersionCheckResponse对象
  factory VersionCheckResponse.fromJson(Map<String, dynamic> json) {
    return VersionCheckResponse(
      code: json['code'] as int,
      message: json['msg'] as String,
      data: json['data'] != null ? AppVersion.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': message,
      'data': data?.toJson(),
    };
  }

  /// 是否成功
  bool get isSuccess => code == 200;

  @override
  String toString() {
    return 'VersionCheckResponse{code: $code, message: $message, data: $data}';
  }
}
