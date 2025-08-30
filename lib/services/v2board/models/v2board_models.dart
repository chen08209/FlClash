import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'v2board_models.g.dart';

/// V2Board API 异常类
class V2BoardApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  V2BoardApiException(this.message, {this.statusCode, this.errorCode});

  factory V2BoardApiException.fromDioError(DioException error) {
    String message = 'Network error occurred';
    int? statusCode = error.response?.statusCode;
    String? errorCode;

    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      message = data['message'] ?? message;
      errorCode = data['error_code']?.toString();
    } else if (error.message != null) {
      message = error.message!;
    }

    return V2BoardApiException(message, statusCode: statusCode, errorCode: errorCode);
  }

  @override
  String toString() => 'V2BoardApiException: $message';
}

/// 基础响应类
@JsonSerializable(genericArgumentFactories: true)
class V2BoardBaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  @JsonKey(name: 'error_code')
  final String? errorCode;

  V2BoardBaseResponse({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
  });

  factory V2BoardBaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$V2BoardBaseResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$V2BoardBaseResponseToJson(this, toJsonT);
}

/// 登录响应数据
@JsonSerializable()
class V2BoardLoginData {
  @JsonKey(name: 'auth_data')
  final String? authData;
  @JsonKey(name: 'is_admin')
  final bool? isAdmin;
  @JsonKey(name: 'is_staff')
  final bool? isStaff;

  V2BoardLoginData({
    this.authData,
    this.isAdmin,
    this.isStaff,
  });

  factory V2BoardLoginData.fromJson(Map<String, dynamic> json) =>
      _$V2BoardLoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardLoginDataToJson(this);
}

/// 登录响应
typedef V2BoardLoginResponse = V2BoardBaseResponse<V2BoardLoginData>;

/// 用户信息
@JsonSerializable()
class V2BoardUser {
  final int? id;
  final String? email;
  @JsonKey(name: 'transfer_enable')
  final int? transferEnable;
  final int? u;
  final int? d;
  @JsonKey(name: 'expired_at')
  final int? expiredAt;
  @JsonKey(name: 'plan_id')
  final int? planId;
  @JsonKey(name: 'group_id')
  final int? groupId;
  @JsonKey(name: 'token')
  final String? token;
  @JsonKey(name: 'uuid')
  final String? uuid;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final int? balance;
  @JsonKey(name: 'commission_balance')
  final int? commissionBalance;
  @JsonKey(name: 'plan_name')
  final String? planName;
  @JsonKey(name: 'subscribe_url')
  final String? subscribeUrl;
  @JsonKey(name: 'reset_day')
  final int? resetDay;

  V2BoardUser({
    this.id,
    this.email,
    this.transferEnable,
    this.u,
    this.d,
    this.expiredAt,
    this.planId,
    this.groupId,
    this.token,
    this.uuid,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.balance,
    this.commissionBalance,
    this.planName,
    this.subscribeUrl,
    this.resetDay,
  });

  factory V2BoardUser.fromJson(Map<String, dynamic> json) =>
      _$V2BoardUserFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardUserToJson(this);

  /// 获取剩余流量（字节）
  int get remainingTraffic {
    final total = transferEnable ?? 0;
    final used = (u ?? 0) + (d ?? 0);
    return total - used;
  }

  /// 获取已用流量（字节）
  int get usedTraffic => (u ?? 0) + (d ?? 0);

  /// 检查是否过期
  bool get isExpired {
    if (expiredAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > (expiredAt! * 1000);
  }

  /// 检查是否有有效订阅
  bool get hasValidSubscription {
    return !isExpired && remainingTraffic > 0;
  }
}

/// 用户信息响应
typedef V2BoardUserResponse = V2BoardBaseResponse<V2BoardUser>;

/// 订阅信息
@JsonSerializable()
class V2BoardSubscription {
  final int? id;
  final String? name;
  final String? url;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  V2BoardSubscription({
    this.id,
    this.name,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory V2BoardSubscription.fromJson(Map<String, dynamic> json) =>
      _$V2BoardSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardSubscriptionToJson(this);
}

/// 订阅信息响应
typedef V2BoardSubscriptionResponse = V2BoardBaseResponse<List<V2BoardSubscription>>;

/// 套餐信息
@JsonSerializable()
class V2BoardPlan {
  final int? id;
  final String? name;
  final String? content;
  @JsonKey(name: 'month_price')
  final int? monthPrice;
  @JsonKey(name: 'quarter_price')
  final int? quarterPrice;
  @JsonKey(name: 'half_year_price')
  final int? halfYearPrice;
  @JsonKey(name: 'year_price')
  final int? yearPrice;
  @JsonKey(name: 'two_year_price')
  final int? twoYearPrice;
  @JsonKey(name: 'three_year_price')
  final int? threeYearPrice;
  @JsonKey(name: 'onetime_price')
  final int? onetimePrice;
  @JsonKey(name: 'reset_price')
  final int? resetPrice;
  @JsonKey(name: 'transfer_enable')
  final int? transferEnable;
  final int? sort;
  final int? renew;
  final int? show;

  V2BoardPlan({
    this.id,
    this.name,
    this.content,
    this.monthPrice,
    this.quarterPrice,
    this.halfYearPrice,
    this.yearPrice,
    this.twoYearPrice,
    this.threeYearPrice,
    this.onetimePrice,
    this.resetPrice,
    this.transferEnable,
    this.sort,
    this.renew,
    this.show,
  });

  factory V2BoardPlan.fromJson(Map<String, dynamic> json) =>
      _$V2BoardPlanFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardPlanToJson(this);

  /// 获取指定周期的价格
  int? getPriceForPeriod(String period) {
    switch (period) {
      case 'month_price':
        return monthPrice;
      case 'quarter_price':
        return quarterPrice;
      case 'half_year_price':
        return halfYearPrice;
      case 'year_price':
        return yearPrice;
      case 'two_year_price':
        return twoYearPrice;
      case 'three_year_price':
        return threeYearPrice;
      case 'onetime_price':
        return onetimePrice;
      case 'reset_price':
        return resetPrice;
      default:
        return null;
    }
  }
}

/// 套餐列表响应
typedef V2BoardPlansResponse = V2BoardBaseResponse<List<V2BoardPlan>>;

/// 订单信息
@JsonSerializable()
class V2BoardOrder {
  final int? id;
  @JsonKey(name: 'trade_no')
  final String? tradeNo;
  @JsonKey(name: 'plan_id')
  final int? planId;
  final String? period;
  @JsonKey(name: 'total_amount')
  final int? totalAmount;
  final int? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  V2BoardOrder({
    this.id,
    this.tradeNo,
    this.planId,
    this.period,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory V2BoardOrder.fromJson(Map<String, dynamic> json) =>
      _$V2BoardOrderFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardOrderToJson(this);
}

/// 订单响应
typedef V2BoardOrderResponse = V2BoardBaseResponse<V2BoardOrder>;

/// 支付方式
@JsonSerializable()
class V2BoardPaymentMethod {
  final int? id;
  final String? name;
  final String? payment;
  final String? icon;
  @JsonKey(name: 'handling_fee_fixed')
  final int? handlingFeeFixed;
  @JsonKey(name: 'handling_fee_percent')
  final double? handlingFeePercent;

  V2BoardPaymentMethod({
    this.id,
    this.name,
    this.payment,
    this.icon,
    this.handlingFeeFixed,
    this.handlingFeePercent,
  });

  factory V2BoardPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$V2BoardPaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardPaymentMethodToJson(this);
}

/// 支付方式列表响应
typedef V2BoardPaymentMethodsResponse = V2BoardBaseResponse<List<V2BoardPaymentMethod>>;

/// 订单状态响应
@JsonSerializable()
class V2BoardOrderStatus {
  final int? status;
  @JsonKey(name: 'callback_no')
  final String? callbackNo;

  V2BoardOrderStatus({
    this.status,
    this.callbackNo,
  });

  factory V2BoardOrderStatus.fromJson(Map<String, dynamic> json) =>
      _$V2BoardOrderStatusFromJson(json);

  Map<String, dynamic> toJson() => _$V2BoardOrderStatusToJson(this);
}

/// 订单状态响应
typedef V2BoardOrderStatusResponse = V2BoardBaseResponse<V2BoardOrderStatus>;
