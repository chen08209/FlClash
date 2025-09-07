import 'package:flutter/material.dart';

class TrafficLog {
  final int download; // 下行流量（字节 B）
  final int upload; // 上行流量（字节 B）
  final int recordAt; // 记录时间戳
  final String serverRate; // 扣费倍率
  final int userId; // 用户ID

  TrafficLog({
    required this.download,
    required this.upload,
    required this.recordAt,
    required this.serverRate,
    required this.userId,
  });

  factory TrafficLog.fromJson(Map<String, dynamic> json) {
    return TrafficLog(
      download: json['d'] as int,
      upload: json['u'] as int,
      recordAt: json['record_at'] as int,
      serverRate: json['server_rate'] as String,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'd': download,
      'u': upload,
      'record_at': recordAt,
      'server_rate': serverRate,
      'user_id': userId,
    };
  }

  // 将时间戳转换为东8区时间
  DateTime _toChineseTime(int timestamp) {
    final utcTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return utcTime.add(const Duration(hours: 8));
  }

  // 格式化流量为可读格式
  String _formatTraffic(int trafficBytes) {
    if (trafficBytes == 0) return '0 B';
    
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var index = 0;
    double size = trafficBytes.toDouble();
    
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }
    
    if (size == size.floor()) {
      return '${size.toInt()} ${units[index]}';
    } else {
      return '${size.toStringAsFixed(2)} ${units[index]}';
    }
  }

  // 格式化记录时间（只显示年月日）
  String get formattedDate {
    final date = _toChineseTime(recordAt);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 格式化下行流量
  String get formattedDownload {
    return _formatTraffic(download);
  }

  // 格式化上行流量
  String get formattedUpload {
    return _formatTraffic(upload);
  }

  // 计算总流量
  int get totalTraffic {
    return download + upload;
  }

  // 格式化总流量
  String get formattedTotal {
    return _formatTraffic(totalTraffic);
  }

  // 格式化扣费倍率
  String get formattedServerRate {
    final rate = double.tryParse(serverRate) ?? 1.0;
    if (rate == rate.floor()) {
      return '${rate.toInt()}x';
    } else {
      return '${rate.toStringAsFixed(2)}x';
    }
  }

  // 计算实际扣费流量
  int get billedTraffic {
    final rate = double.tryParse(serverRate) ?? 1.0;
    return (totalTraffic * rate).round();
  }

  // 格式化实际扣费流量
  String get formattedBilledTraffic {
    return _formatTraffic(billedTraffic);
  }

  // 获取流量使用状态颜色
  Color get trafficColor {
    if (totalTraffic == 0) return Colors.grey;
    if (totalTraffic < 100 * 1024 * 1024) return Colors.green; // < 100MB
    if (totalTraffic < 1024 * 1024 * 1024) return Colors.orange; // < 1GB
    return Colors.red; // >= 1GB
  }

  // 获取扣费倍率颜色
  Color get serverRateColor {
    final rate = double.tryParse(serverRate) ?? 1.0;
    if (rate <= 1.0) return Colors.green;
    if (rate <= 2.0) return Colors.orange;
    return Colors.red;
  }
}
