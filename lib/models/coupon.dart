enum CouponType {
  fixedAmount, // 抵扣固定金额
  percentage, // 按照比例抵扣
}

class Coupon {
  final int id;
  final String code;
  final String name;
  final CouponType type;
  final int value; // 折扣额度（固定金额为分，比例为百分比*100）
  final int show;
  final int? limitUse;
  final int? limitUseWithUser;
  final String? limitPlanIds;
  final String? limitPeriod;
  final int startedAt;
  final int endedAt;
  final int createdAt;
  final int updatedAt;

  Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.value,
    required this.show,
    this.limitUse,
    this.limitUseWithUser,
    this.limitPlanIds,
    this.limitPeriod,
    required this.startedAt,
    required this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      type: _parseCouponType(json['type'] as int),
      value: json['value'] as int,
      show: json['show'] as int,
      limitUse: json['limit_use'] as int?,
      limitUseWithUser: json['limit_use_with_user'] as int?,
      limitPlanIds: json['limit_plan_ids'] as String?,
      limitPeriod: json['limit_period'] as String?,
      startedAt: json['started_at'] as int,
      endedAt: json['ended_at'] as int,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  static CouponType _parseCouponType(int type) {
    switch (type) {
      case 1:
        return CouponType.fixedAmount;
      case 2:
        return CouponType.percentage;
      default:
        return CouponType.fixedAmount;
    }
  }

  // 获取优惠码类型文本
  String get typeText {
    switch (type) {
      case CouponType.fixedAmount:
        return '固定金额';
      case CouponType.percentage:
        return '比例折扣';
    }
  }

  // 格式化优惠额度显示
  String get formattedValue {
    switch (type) {
      case CouponType.fixedAmount:
        return '¥${(value / 100).toStringAsFixed(2)}';
      case CouponType.percentage:
        return '${value}%'; // value 直接就是百分比数值，如 value=20 表示 20%
    }
  }

  // 将时间戳转换为东8区时间
  DateTime _toChineseTime(int timestamp) {
    final utcTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return utcTime.add(const Duration(hours: 8));
  }

  // 格式化有效期
  String get formattedValidPeriod {
    final startDate = _toChineseTime(startedAt);
    final endDate = _toChineseTime(endedAt);
    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 检查优惠码是否有效
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= startedAt && now <= endedAt && show == 1;
  }
}
