import 'package:fl_clash/models/subscription_plan.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  pending, // 待支付
  processing, // 开通中
  cancelled, // 已取消
  completed, // 已完成
  discounted, // 已折抵
}

enum OrderType {
  newOrder, // 新订单
  renewal, // 续费
  upgrade, // 升级
}

enum OrderCheckStatus {
  pending,      // 0 待支付
  processing,   // 1 开通中
  cancelled,    // 2 已取消
  completed,    // 3 已完成
  refunded,     // 4 已折抵
}

// OrderCheckStatus 扩展方法
extension OrderCheckStatusExtension on OrderCheckStatus {
  // 解析状态码
  static OrderCheckStatus fromCode(int code) {
    switch (code) {
      case 0:
        return OrderCheckStatus.pending;
      case 1:
        return OrderCheckStatus.processing;
      case 2:
        return OrderCheckStatus.cancelled;
      case 3:
        return OrderCheckStatus.completed;
      case 4:
        return OrderCheckStatus.refunded;
      default:
        return OrderCheckStatus.pending;
    }
  }
  
  // 获取状态文本
  String get statusText {
    switch (this) {
      case OrderCheckStatus.pending:
        return '待支付';
      case OrderCheckStatus.processing:
        return '开通中';
      case OrderCheckStatus.cancelled:
        return '已取消';
      case OrderCheckStatus.completed:
        return '已完成';
      case OrderCheckStatus.refunded:
        return '已折抵';
    }
  }
  
  // 获取状态颜色
  Color get statusColor {
    switch (this) {
      case OrderCheckStatus.pending:
        return Colors.orange;
      case OrderCheckStatus.processing:
        return Colors.blue;
      case OrderCheckStatus.cancelled:
        return Colors.red;
      case OrderCheckStatus.completed:
        return Colors.green;
      case OrderCheckStatus.refunded:
        return Colors.purple;
    }
  }
}

class Order {
  final int? id;  // 订单详情才有
  final int? userId;  // 订单详情才有
  final int? inviteUserId;
  final int planId;
  final int? couponId;
  final int? paymentId;
  final OrderType type;
  final String period;
  final String tradeNo;
  final String? callbackNo;
  final int totalAmount;
  final int? handlingAmount;
  final int? discountAmount;
  final int? surplusAmount;
  final int? refundAmount;
  final int? balanceAmount;
  final String? surplusOrderIds;
  final OrderStatus status;
  final int commissionStatus;
  final int commissionBalance;
  final int? actualCommissionBalance;
  final int? paidAt;
  final int createdAt;
  final int updatedAt;
  final SubscriptionPlan? plan;
  final int? tryOutPlanId;  // 订单详情才有

  Order({
    this.id,
    this.userId,
    this.inviteUserId,
    required this.planId,
    this.couponId,
    this.paymentId,
    required this.type,
    required this.period,
    required this.tradeNo,
    this.callbackNo,
    required this.totalAmount,
    this.handlingAmount,
    this.discountAmount,
    this.surplusAmount,
    this.refundAmount,
    this.balanceAmount,
    this.surplusOrderIds,
    required this.status,
    required this.commissionStatus,
    required this.commissionBalance,
    this.actualCommissionBalance,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
    this.tryOutPlanId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      inviteUserId: json['invite_user_id'] as int?,
      planId: json['plan_id'] as int,
      couponId: json['coupon_id'] as int?,
      paymentId: json['payment_id'] as int?,
      type: _parseOrderType(json['type'] as int),
      period: json['period'] as String,
      tradeNo: json['trade_no'] as String,
      callbackNo: json['callback_no'] as String?,
      totalAmount: json['total_amount'] as int,
      handlingAmount: json['handling_amount'] as int?,
      discountAmount: json['discount_amount'] as int?,
      surplusAmount: json['surplus_amount'] as int?,
      refundAmount: json['refund_amount'] as int?,
      balanceAmount: json['balance_amount'] as int?,
      surplusOrderIds: json['surplus_order_ids'] as String?,
      status: _parseOrderStatus(json['status'] as int),
      commissionStatus: json['commission_status'] as int,
      commissionBalance: json['commission_balance'] as int,
      actualCommissionBalance: json['actual_commission_balance'] as int?,
      paidAt: json['paid_at'] as int?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      plan: json['plan'] != null 
          ? SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      tryOutPlanId: json['try_out_plan_id'] as int?,
    );
  }

  static OrderStatus _parseOrderStatus(int status) {
    switch (status) {
      case 0:
        return OrderStatus.pending;
      case 1:
        return OrderStatus.processing;
      case 2:
        return OrderStatus.cancelled;
      case 3:
        return OrderStatus.completed;
      case 4:
        return OrderStatus.discounted;
      default:
        return OrderStatus.pending;
    }
  }

  static OrderType _parseOrderType(int type) {
    switch (type) {
      case 1:
        return OrderType.newOrder;
      case 2:
        return OrderType.renewal;
      case 3:
        return OrderType.upgrade;
      default:
        return OrderType.newOrder;
    }
  }

  // 格式化价格（分转元）
  String formatPrice(int? priceInCents) {
    if (priceInCents == null || priceInCents == 0) return '免费';
    return '¥${(priceInCents / 100).toStringAsFixed(2)}';
  }

  // 获取订单状态文本
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return '待支付';
      case OrderStatus.processing:
        return '开通中';
      case OrderStatus.cancelled:
        return '已取消';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.discounted:
        return '已折抵';
    }
  }

  // 获取订单状态颜色
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return '#FF9800'; // 橙色
      case OrderStatus.processing:
        return '#2196F3'; // 蓝色
      case OrderStatus.cancelled:
        return '#F44336'; // 红色
      case OrderStatus.completed:
        return '#4CAF50'; // 绿色
      case OrderStatus.discounted:
        return '#9C27B0'; // 紫色
    }
  }

  // 获取订单类型文本
  String get typeText {
    switch (type) {
      case OrderType.newOrder:
        return '新订单';
      case OrderType.renewal:
        return '续费';
      case OrderType.upgrade:
        return '升级';
    }
  }

  // 获取周期文本
  String get periodText {
    switch (period) {
      case 'month_price':
        return '月付';
      case 'quarter_price':
        return '季付';
      case 'half_year_price':
        return '半年付';
      case 'year_price':
        return '年付';
      case 'two_year_price':
        return '两年付';
      case 'three_year_price':
        return '三年付';
      case 'onetime_price':
        return '一次性';
      case 'reset_price':
        return '重置流量';
      default:
        return period;
    }
  }

  // 格式化创建时间
  String get formattedCreatedAt {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 格式化更新时间
  String get formattedUpdatedAt {
    final date = DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 格式化支付时间
  String? get formattedPaidAt {
    if (paidAt == null) return null;
    final date = DateTime.fromMillisecondsSinceEpoch(paidAt! * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 是否显示余额支付金额
  bool get shouldShowBalanceAmount {
    return balanceAmount != null && balanceAmount! > 0;
  }
}