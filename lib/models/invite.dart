class InviteCode {
  final int userId;
  final String code;
  final int pv;
  final int status;
  final int createdAt;
  final int updatedAt;

  InviteCode({
    required this.userId,
    required this.code,
    required this.pv,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      userId: json['user_id'] ?? 0,
      code: json['code'] ?? '',
      pv: json['pv'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
    );
  }

  // 格式化创建时间为东8区
  String get formattedCreatedAt {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
      final beijingTime = dateTime.add(const Duration(hours: 8));
      return '${beijingTime.year}-${beijingTime.month.toString().padLeft(2, '0')}-${beijingTime.day.toString().padLeft(2, '0')} ${beijingTime.hour.toString().padLeft(2, '0')}:${beijingTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '未知时间';
    }
  }
}

class InviteStat {
  final int registeredUsers;    // 已注册用户数
  final int unknown1;           // 未知字段
  final int pendingCommission;  // 确认中的佣金（分）
  final int commissionRate;     // 佣金比例
  final int totalCommission;    // 累计获得佣金（分）

  InviteStat({
    required this.registeredUsers,
    required this.unknown1,
    required this.pendingCommission,
    required this.commissionRate,
    required this.totalCommission,
  });

  factory InviteStat.fromJson(List<dynamic> statList) {
    return InviteStat(
      registeredUsers: statList.isNotEmpty ? statList[0] ?? 0 : 0,
      unknown1: statList.length > 1 ? statList[1] ?? 0 : 0,
      pendingCommission: statList.length > 2 ? statList[2] ?? 0 : 0,
      commissionRate: statList.length > 3 ? statList[3] ?? 0 : 0,
      totalCommission: statList.length > 4 ? statList[4] ?? 0 : 0,
    );
  }

  // 格式化佣金显示（分转元）
  String get formattedPendingCommission {
    return '¥${(pendingCommission / 100).toStringAsFixed(2)}';
  }

  String get formattedTotalCommission {
    return '¥${(totalCommission / 100).toStringAsFixed(2)}';
  }

  String get formattedCommissionRate {
    return '$commissionRate%';
  }
}

class InviteDetail {
  final int id;
  final int orderAmount;      // 订单金额（分）
  final String tradeNo;       // 订单号
  final int getAmount;        // 获得佣金（分）
  final int createdAt;        // 创建时间

  InviteDetail({
    required this.id,
    required this.orderAmount,
    required this.tradeNo,
    required this.getAmount,
    required this.createdAt,
  });

  factory InviteDetail.fromJson(Map<String, dynamic> json) {
    return InviteDetail(
      id: json['id'] ?? 0,
      orderAmount: json['order_amount'] ?? 0,
      tradeNo: json['trade_no'] ?? '',
      getAmount: json['get_amount'] ?? 0,
      createdAt: json['created_at'] ?? 0,
    );
  }

  // 格式化订单金额
  String get formattedOrderAmount {
    return '¥${(orderAmount / 100).toStringAsFixed(2)}';
  }

  // 格式化获得佣金
  String get formattedGetAmount {
    return '¥${(getAmount / 100).toStringAsFixed(2)}';
  }

  // 格式化创建时间为东8区
  String get formattedCreatedAt {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
      final beijingTime = dateTime.add(const Duration(hours: 8));
      return '${beijingTime.year}-${beijingTime.month.toString().padLeft(2, '0')}-${beijingTime.day.toString().padLeft(2, '0')} ${beijingTime.hour.toString().padLeft(2, '0')}:${beijingTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '未知时间';
    }
  }
}

class InviteInfo {
  final List<InviteCode> codes;
  final InviteStat stat;

  InviteInfo({
    required this.codes,
    required this.stat,
  });

  factory InviteInfo.fromJson(Map<String, dynamic> json) {
    return InviteInfo(
      codes: (json['codes'] as List<dynamic>?)
              ?.map((code) => InviteCode.fromJson(code))
              .toList() ??
          [],
      stat: InviteStat.fromJson(json['stat'] ?? []),
    );
  }
}

class InviteDetailsResponse {
  final List<InviteDetail> data;
  final int total;

  InviteDetailsResponse({
    required this.data,
    required this.total,
  });

  factory InviteDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InviteDetailsResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((detail) => InviteDetail.fromJson(detail))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}
