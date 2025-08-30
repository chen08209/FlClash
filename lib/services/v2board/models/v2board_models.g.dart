// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2board_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V2BoardBaseResponse<T> _$V2BoardBaseResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    V2BoardBaseResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      errorCode: json['error_code'] as String?,
    );

Map<String, dynamic> _$V2BoardBaseResponseToJson<T>(
  V2BoardBaseResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'error_code': instance.errorCode,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

V2BoardLoginData _$V2BoardLoginDataFromJson(Map<String, dynamic> json) =>
    V2BoardLoginData(
      authData: json['auth_data'] as String?,
      isAdmin: json['is_admin'] as bool?,
      isStaff: json['is_staff'] as bool?,
    );

Map<String, dynamic> _$V2BoardLoginDataToJson(V2BoardLoginData instance) =>
    <String, dynamic>{
      'auth_data': instance.authData,
      'is_admin': instance.isAdmin,
      'is_staff': instance.isStaff,
    };

V2BoardUser _$V2BoardUserFromJson(Map<String, dynamic> json) => V2BoardUser(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String?,
      transferEnable: (json['transfer_enable'] as num?)?.toInt(),
      u: (json['u'] as num?)?.toInt(),
      d: (json['d'] as num?)?.toInt(),
      expiredAt: (json['expired_at'] as num?)?.toInt(),
      planId: (json['plan_id'] as num?)?.toInt(),
      groupId: (json['group_id'] as num?)?.toInt(),
      token: json['token'] as String?,
      uuid: json['uuid'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      balance: (json['balance'] as num?)?.toInt(),
      commissionBalance: (json['commission_balance'] as num?)?.toInt(),
      planName: json['plan_name'] as String?,
      subscribeUrl: json['subscribe_url'] as String?,
      resetDay: (json['reset_day'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V2BoardUserToJson(V2BoardUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'transfer_enable': instance.transferEnable,
      'u': instance.u,
      'd': instance.d,
      'expired_at': instance.expiredAt,
      'plan_id': instance.planId,
      'group_id': instance.groupId,
      'token': instance.token,
      'uuid': instance.uuid,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'balance': instance.balance,
      'commission_balance': instance.commissionBalance,
      'plan_name': instance.planName,
      'subscribe_url': instance.subscribeUrl,
      'reset_day': instance.resetDay,
    };

V2BoardSubscription _$V2BoardSubscriptionFromJson(Map<String, dynamic> json) =>
    V2BoardSubscription(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      url: json['url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$V2BoardSubscriptionToJson(
        V2BoardSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

V2BoardPlan _$V2BoardPlanFromJson(Map<String, dynamic> json) => V2BoardPlan(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      content: json['content'] as String?,
      monthPrice: (json['month_price'] as num?)?.toInt(),
      quarterPrice: (json['quarter_price'] as num?)?.toInt(),
      halfYearPrice: (json['half_year_price'] as num?)?.toInt(),
      yearPrice: (json['year_price'] as num?)?.toInt(),
      twoYearPrice: (json['two_year_price'] as num?)?.toInt(),
      threeYearPrice: (json['three_year_price'] as num?)?.toInt(),
      onetimePrice: (json['onetime_price'] as num?)?.toInt(),
      resetPrice: (json['reset_price'] as num?)?.toInt(),
      transferEnable: (json['transfer_enable'] as num?)?.toInt(),
      sort: (json['sort'] as num?)?.toInt(),
      renew: (json['renew'] as num?)?.toInt(),
      show: (json['show'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V2BoardPlanToJson(V2BoardPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'content': instance.content,
      'month_price': instance.monthPrice,
      'quarter_price': instance.quarterPrice,
      'half_year_price': instance.halfYearPrice,
      'year_price': instance.yearPrice,
      'two_year_price': instance.twoYearPrice,
      'three_year_price': instance.threeYearPrice,
      'onetime_price': instance.onetimePrice,
      'reset_price': instance.resetPrice,
      'transfer_enable': instance.transferEnable,
      'sort': instance.sort,
      'renew': instance.renew,
      'show': instance.show,
    };

V2BoardOrder _$V2BoardOrderFromJson(Map<String, dynamic> json) => V2BoardOrder(
      id: (json['id'] as num?)?.toInt(),
      tradeNo: json['trade_no'] as String?,
      planId: (json['plan_id'] as num?)?.toInt(),
      period: json['period'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$V2BoardOrderToJson(V2BoardOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trade_no': instance.tradeNo,
      'plan_id': instance.planId,
      'period': instance.period,
      'total_amount': instance.totalAmount,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

V2BoardPaymentMethod _$V2BoardPaymentMethodFromJson(
        Map<String, dynamic> json) =>
    V2BoardPaymentMethod(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      payment: json['payment'] as String?,
      icon: json['icon'] as String?,
      handlingFeeFixed: (json['handling_fee_fixed'] as num?)?.toInt(),
      handlingFeePercent: (json['handling_fee_percent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$V2BoardPaymentMethodToJson(
        V2BoardPaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'payment': instance.payment,
      'icon': instance.icon,
      'handling_fee_fixed': instance.handlingFeeFixed,
      'handling_fee_percent': instance.handlingFeePercent,
    };

V2BoardOrderStatus _$V2BoardOrderStatusFromJson(Map<String, dynamic> json) =>
    V2BoardOrderStatus(
      status: (json['status'] as num?)?.toInt(),
      callbackNo: json['callback_no'] as String?,
    );

Map<String, dynamic> _$V2BoardOrderStatusToJson(V2BoardOrderStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'callback_no': instance.callbackNo,
    };
