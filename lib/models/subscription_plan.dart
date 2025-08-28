class SubscriptionPlan {
  final int id;
  final int groupId;
  final int transferEnable; // 流量额度 (GB)
  final String name;
  final int? speedLimit;
  final int show;
  final int sort;
  final int renew;
  final String content; // HTML格式的详细描述
  final int? monthPrice; // 月价格 (分)
  final int? quarterPrice; // 季价格 (分)
  final int? halfYearPrice; // 半年价格 (分)
  final int? yearPrice; // 年价格 (分)
  final int? twoYearPrice; // 两年价格 (分)
  final int? threeYearPrice; // 三年价格 (分)
  final int? onetimePrice; // 一次性价格 (分)
  final int? resetPrice; // 重置价格 (分)
  final int? resetTrafficMethod;
  final int? capacityLimit;
  final int createdAt;
  final int updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.groupId,
    required this.transferEnable,
    required this.name,
    this.speedLimit,
    required this.show,
    required this.sort,
    required this.renew,
    required this.content,
    this.monthPrice,
    this.quarterPrice,
    this.halfYearPrice,
    this.yearPrice,
    this.twoYearPrice,
    this.threeYearPrice,
    this.onetimePrice,
    this.resetPrice,
    this.resetTrafficMethod,
    this.capacityLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      transferEnable: json['transfer_enable'] as int,
      name: json['name'] as String,
      speedLimit: json['speed_limit'] as int?,
      show: json['show'] as int,
      sort: json['sort'] as int,
      renew: json['renew'] as int,
      content: json['content'] as String,
      monthPrice: json['month_price'] as int?,
      quarterPrice: json['quarter_price'] as int?,
      halfYearPrice: json['half_year_price'] as int?,
      yearPrice: json['year_price'] as int?,
      twoYearPrice: json['two_year_price'] as int?,
      threeYearPrice: json['three_year_price'] as int?,
      onetimePrice: json['onetime_price'] as int?,
      resetPrice: json['reset_price'] as int?,
      resetTrafficMethod: json['reset_traffic_method'] as int?,
      capacityLimit: json['capacity_limit'] as int?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'transfer_enable': transferEnable,
      'name': name,
      'speed_limit': speedLimit,
      'show': show,
      'sort': sort,
      'renew': renew,
      'content': content,
      'month_price': monthPrice,
      'quarter_price': quarterPrice,
      'half_year_price': halfYearPrice,
      'year_price': yearPrice,
      'two_year_price': twoYearPrice,
      'three_year_price': threeYearPrice,
      'onetime_price': onetimePrice,
      'reset_price': resetPrice,
      'reset_traffic_method': resetTrafficMethod,
      'capacity_limit': capacityLimit,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // 格式化价格 (分转换为元)
  String formatPrice(int? priceInCents) {
    if (priceInCents == null) return '--';
    return '¥${(priceInCents / 100).toStringAsFixed(2)}';
  }

  // 获取最低价格
  String get lowestPrice {
    final prices = [
      monthPrice,
      quarterPrice,
      halfYearPrice,
      yearPrice,
      twoYearPrice,
      threeYearPrice,
      onetimePrice,
    ].where((price) => price != null && price > 0).cast<int>().toList();
    
    if (prices.isEmpty) return '--';
    
    final lowest = prices.reduce((a, b) => a < b ? a : b);
    return formatPrice(lowest);
  }

  // 格式化流量
  String get formattedTraffic {
    if (transferEnable >= 1024) {
      return '${(transferEnable / 1024).toStringAsFixed(1)}TB';
    }
    return '${transferEnable}GB';
  }

  // 是否可以续费
  bool get canRenew => renew == 1;

  // 是否显示
  bool get isVisible => show == 1;
}

// 订阅周期枚举
enum SubscriptionPeriod {
  month('月付', 'month_price'),
  quarter('季付', 'quarter_price'),
  halfYear('半年付', 'half_year_price'),
  year('年付', 'year_price'),
  twoYear('两年付', 'two_year_price'),
  threeYear('三年付', 'three_year_price'),
  onetime('一次性', 'onetime_price');

  const SubscriptionPeriod(this.label, this.priceField);
  
  final String label;
  final String priceField;

  // 获取对应价格
  int? getPrice(SubscriptionPlan plan) {
    switch (this) {
      case SubscriptionPeriod.month:
        return plan.monthPrice;
      case SubscriptionPeriod.quarter:
        return plan.quarterPrice;
      case SubscriptionPeriod.halfYear:
        return plan.halfYearPrice;
      case SubscriptionPeriod.year:
        return plan.yearPrice;
      case SubscriptionPeriod.twoYear:
        return plan.twoYearPrice;
      case SubscriptionPeriod.threeYear:
        return plan.threeYearPrice;
      case SubscriptionPeriod.onetime:
        return plan.onetimePrice;
    }
  }

  // 获取可用的订阅周期
  static List<SubscriptionPeriod> getAvailablePeriods(SubscriptionPlan plan) {
    return SubscriptionPeriod.values.where((period) {
      final price = period.getPrice(plan);
      return price != null && price > 0;
    }).toList();
  }
}
