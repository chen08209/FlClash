import 'package:flutter/material.dart';

enum TicketLevel {
  low,    // 0 低
  medium, // 1 中
  high,   // 2 高
}

enum TicketStatus {
  open,   // 0 开启
  closed, // 1 已关闭
}

enum TicketReplyStatus {
  replied,      // 0 已回复
  waitingReply, // 1 待回复
}

extension TicketLevelExtension on TicketLevel {
  static TicketLevel fromCode(int code) {
    switch (code) {
      case 0:
        return TicketLevel.low;
      case 1:
        return TicketLevel.medium;
      case 2:
        return TicketLevel.high;
      default:
        return TicketLevel.low;
    }
  }

  int get code {
    switch (this) {
      case TicketLevel.low:
        return 0;
      case TicketLevel.medium:
        return 1;
      case TicketLevel.high:
        return 2;
    }
  }

  String get levelText {
    switch (this) {
      case TicketLevel.low:
        return '低';
      case TicketLevel.medium:
        return '中';
      case TicketLevel.high:
        return '高';
    }
  }

  Color get levelColor {
    switch (this) {
      case TicketLevel.low:
        return Colors.green;
      case TicketLevel.medium:
        return Colors.orange;
      case TicketLevel.high:
        return Colors.red;
    }
  }
}

extension TicketStatusExtension on TicketStatus {
  static TicketStatus fromCode(int code) {
    switch (code) {
      case 0:
        return TicketStatus.open;
      case 1:
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  int get code {
    switch (this) {
      case TicketStatus.open:
        return 0;
      case TicketStatus.closed:
        return 1;
    }
  }

  String get statusText {
    switch (this) {
      case TicketStatus.open:
        return '开启';
      case TicketStatus.closed:
        return '已关闭';
    }
  }

  Color get statusColor {
    switch (this) {
      case TicketStatus.open:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.grey;
    }
  }
}

extension TicketReplyStatusExtension on TicketReplyStatus {
  static TicketReplyStatus fromCode(int code) {
    switch (code) {
      case 0:
        return TicketReplyStatus.replied;
      case 1:
        return TicketReplyStatus.waitingReply;
      default:
        return TicketReplyStatus.waitingReply;
    }
  }

  int get code {
    switch (this) {
      case TicketReplyStatus.replied:
        return 0;
      case TicketReplyStatus.waitingReply:
        return 1;
    }
  }

  String get replyStatusText {
    switch (this) {
      case TicketReplyStatus.replied:
        return '已回复';
      case TicketReplyStatus.waitingReply:
        return '待回复';
    }
  }

  Color get replyStatusColor {
    switch (this) {
      case TicketReplyStatus.replied:
        return Colors.green;
      case TicketReplyStatus.waitingReply:
        return Colors.orange;
    }
  }
}

class Ticket {
  final int id;
  final TicketLevel level;
  final TicketReplyStatus replyStatus;
  final TicketStatus status;
  final String subject;
  final String? message;
  final int createdAt;
  final int updatedAt;
  final int userId;

  Ticket({
    required this.id,
    required this.level,
    required this.replyStatus,
    required this.status,
    required this.subject,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      level: TicketLevelExtension.fromCode(json['level'] as int),
      replyStatus: TicketReplyStatusExtension.fromCode(json['reply_status'] as int),
      status: TicketStatusExtension.fromCode(json['status'] as int),
      subject: json['subject'] as String,
      message: json['message'] as String?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.code,
      'reply_status': replyStatus.code,
      'status': status.code,
      'subject': subject,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
    };
  }

  // 将时间戳转换为东8区时间
  DateTime _toChineseTime(int timestamp) {
    final utcTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return utcTime.add(const Duration(hours: 8));
  }

  // 格式化时间为字符串
  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 格式化创建时间
  String get formattedCreatedAt {
    final dateTime = _toChineseTime(createdAt);
    return _formatDateTime(dateTime);
  }

  // 格式化更新时间
  String get formattedUpdatedAt {
    final dateTime = _toChineseTime(updatedAt);
    return _formatDateTime(dateTime);
  }
}
