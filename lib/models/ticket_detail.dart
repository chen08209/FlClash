import 'package:flutter/material.dart';
import 'package:fl_clash/models/ticket.dart';

class TicketMessage {
  final int id;
  final int ticketId;
  final bool isMe; // true表示是用户发送的，false表示是客服回复的
  final String message;
  final int createdAt;
  final int updatedAt;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.isMe,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      isMe: json['is_me'] as bool,
      message: json['message'] as String,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'is_me': isMe,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
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

  // 获取消息发送者标识
  String get senderLabel {
    return isMe ? '我' : '客服';
  }

  // 获取消息发送者颜色
  Color get senderColor {
    return isMe ? Colors.blue : Colors.green;
  }
}

class TicketDetail {
  final int id;
  final TicketLevel level;
  final TicketReplyStatus replyStatus;
  final TicketStatus status;
  final String subject;
  final List<TicketMessage> messages;
  final int createdAt;
  final int updatedAt;
  final int userId;

  TicketDetail({
    required this.id,
    required this.level,
    required this.replyStatus,
    required this.status,
    required this.subject,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    List<TicketMessage> messageList = [];
    if (json['message'] is List) {
      messageList = (json['message'] as List)
          .map((messageJson) => TicketMessage.fromJson(messageJson))
          .toList();
    }

    return TicketDetail(
      id: json['id'] as int,
      level: TicketLevelExtension.fromCode(json['level'] as int),
      replyStatus: TicketReplyStatusExtension.fromCode(json['reply_status'] as int),
      status: TicketStatusExtension.fromCode(json['status'] as int),
      subject: json['subject'] as String,
      messages: messageList,
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
      'message': messages.map((msg) => msg.toJson()).toList(),
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

  // 获取最新消息
  TicketMessage? get latestMessage {
    if (messages.isEmpty) return null;
    return messages.reduce((a, b) => a.createdAt > b.createdAt ? a : b);
  }

  // 获取消息总数
  int get messageCount {
    return messages.length;
  }

  // 获取未读消息数（客服回复的消息）
  int get unreadCount {
    return messages.where((msg) => !msg.isMe).length;
  }
}
