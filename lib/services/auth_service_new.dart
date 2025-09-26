import 'dart:convert';
import 'package:fl_clash/models/subscription_plan.dart';
import 'package:fl_clash/models/order.dart';
import 'package:fl_clash/models/coupon.dart';
import 'package:fl_clash/models/payment_method.dart';
import 'package:fl_clash/models/ticket.dart';
import 'package:fl_clash/models/ticket_detail.dart';
import 'package:fl_clash/models/traffic_log.dart';
import 'package:fl_clash/common/http_client_util.dart';

class AuthService {
  // 使用HttpClientUtil代替Dio和EndpointService
  
  /// 初始化AuthService（确保HttpClientUtil已初始化）
  Future<void> initialize() async {
    await HttpClientUtil.initialize();
    print('AuthService: Initialized with HttpClientUtil');
  }

  /// 获取注册配置信息
  Future<Map<String, dynamic>> getRegistrationConfig() async {
    try {
      final response = await HttpClientUtil.get('/guest/comm/config', requireAuth: false);
      
      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? '获取配置失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取配置失败：${e.toString()}');
    }
  }

  /// 发送邮箱验证码
  Future<bool> sendEmailVerificationCode(String email) async {
    try {
      final response = await HttpClientUtil.post(
        '/passport/comm/sendEmailVerify',
        body: {'email': email},
        requireAuth: false,
      );

      if (response['status'] == 'success') {
        return response['data'] ?? true;
      } else {
        throw Exception(response['message'] ?? '发送验证码失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('发送验证码失败：${e.toString()}');
    }
  }

  /// 注册用户账户
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String emailCode,
    String inviteCode = '',
    String recaptchaData = '',
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/passport/auth/register',
        body: {
          'email': email,
          'password': password,
          'email_code': emailCode,
          'invite_code': inviteCode,
          'recaptcha_data': recaptchaData,
        },
        requireAuth: false,
      );

      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? '注册失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('注册失败：${e.toString()}');
    }
  }

  /// 重置密码
  Future<bool> resetPassword({
    required String email,
    required String password,
    required String emailCode,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/passport/auth/forget',
        body: {
          'email': email,
          'password': password,
          'email_code': emailCode,
        },
        requireAuth: false,
      );

      if (response['status'] == 'success') {
        return response['data'] ?? true;
      } else {
        throw Exception(response['message'] ?? '重置密码失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('重置密码失败：${e.toString()}');
    }
  }

  /// 用户登录
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/passport/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requireAuth: false,
      );

      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? '登录失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('登录失败：${e.toString()}');
    }
  }

  /// 获取订阅套餐列表
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await HttpClientUtil.get('/user/plan/fetch');

      if (response['status'] == 'success') {
        final List<dynamic> plansJson = response['data'] as List<dynamic>;
        final plans = plansJson
            .map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>))
            .where((plan) => plan.show == 1) // 只返回显示的套餐
            .toList();
        
        // 按sort字段排序
        plans.sort((a, b) => a.sort.compareTo(b.sort));
        
        return plans;
      } else {
        throw Exception(response['message'] ?? '获取套餐列表失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取套餐列表失败：${e.toString()}');
    }
  }

  /// 获取用户订单列表
  Future<List<Order>> getOrderList() async {
    try {
      final response = await HttpClientUtil.get('/user/order/fetch');

      if (response['status'] == 'success') {
        final List<dynamic> ordersJson = response['data'] as List<dynamic>;
        final orders = ordersJson
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // 按创建时间倒序排序（最新的在前面）
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return orders;
      } else {
        throw Exception(response['message'] ?? '获取订单列表失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取订单列表失败：${e.toString()}');
    }
  }

  /// 获取订单详情
  Future<Order> getOrderDetail(String tradeNo) async {
    try {
      final response = await HttpClientUtil.get(
        '/user/order/detail',
        queryParameters: {'trade_no': tradeNo},
      );

      if (response['status'] == 'success') {
        final orderJson = response['data'] as Map<String, dynamic>;
        return Order.fromJson(orderJson);
      } else {
        throw Exception(response['message'] ?? '获取订单详情失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取订单详情失败：${e.toString()}');
    }
  }

  /// 验证优惠码
  Future<Coupon> checkCoupon({
    required String code,
    required int planId,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/coupon/check',
        body: {
          'code': code,
          'plan_id': planId,
        },
      );

      if (response['status'] == 'success') {
        final couponJson = response['data'] as Map<String, dynamic>;
        return Coupon.fromJson(couponJson);
      } else {
        throw Exception(response['message'] ?? '优惠码验证失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('优惠码验证失败：${e.toString()}');
    }
  }

  /// 创建订单
  Future<String> createOrder({
    required String period,
    required int planId,
    String? couponCode,
  }) async {
    try {
      final requestData = {
        'period': period,
        'plan_id': planId,
      };

      // 只有在提供优惠码时才添加到请求数据中
      if (couponCode != null && couponCode.isNotEmpty) {
        requestData['coupon_code'] = couponCode;
      }

      final response = await HttpClientUtil.post(
        '/user/order/save',
        body: requestData,
      );

      if (response['status'] == 'success') {
        return response['data'] as String; // 返回订单号
      } else {
        throw Exception(response['message'] ?? '创建订单失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('创建订单失败：${e.toString()}');
    }
  }

  /// 获取支付方式列表
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await HttpClientUtil.get('/user/order/getPaymentMethod');

      if (response['status'] == 'success') {
        final List<dynamic> methodsJson = response['data'] as List<dynamic>;
        return methodsJson.map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response['message'] ?? '获取支付方式失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取支付方式失败：${e.toString()}');
    }
  }

  /// 结算订单
  Future<PaymentResult> checkoutOrder({
    required String tradeNo,
    required int methodId,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/order/checkout',
        body: {
          'trade_no': tradeNo,
          'method': methodId,
        },
      );

      // 结算订单接口返回的数据结构直接就是 PaymentResult 格式
      return PaymentResult.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('订单结算失败：${e.toString()}');
    }
  }

  /// 检查订单状态
  Future<OrderCheckStatus> checkOrderStatus(String tradeNo) async {
    try {
      final response = await HttpClientUtil.get(
        '/user/order/check',
        queryParameters: {'trade_no': tradeNo},
      );

      if (response['status'] == 'success') {
        final statusCode = response['data'] as int;
        return OrderCheckStatusExtension.fromCode(statusCode);
      } else {
        throw Exception(response['message'] ?? '检查订单状态失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('检查订单状态失败：${e.toString()}');
    }
  }

  /// 关闭订单
  Future<bool> cancelOrder(String tradeNo) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/order/cancel',
        body: {'trade_no': tradeNo},
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? '关闭订单失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('关闭订单失败：${e.toString()}');
    }
  }

  // ===== 工单相关 API =====
  
  /// 获取工单列表
  Future<List<Ticket>> getTicketList() async {
    try {
      final response = await HttpClientUtil.get('/user/ticket/fetch');

      if (response['status'] == 'success') {
        List<dynamic> ticketsData = response['data'] ?? [];
        return ticketsData.map((ticket) => Ticket.fromJson(ticket)).toList();
      } else {
        throw Exception(response['message'] ?? '获取工单列表失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取工单列表失败：${e.toString()}');
    }
  }

  /// 创建工单
  Future<bool> createTicket({
    required String subject,
    required TicketLevel level,
    required String message,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/ticket/save',
        body: {
          'subject': subject,
          'level': level.code,
          'message': message,
        },
      );

      if (response['status'] == 'success') {
        return response['data'] == true;
      } else {
        throw Exception(response['message'] ?? '创建工单失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('创建工单失败：${e.toString()}');
    }
  }

  /// 获取工单详情
  Future<TicketDetail> getTicketDetail(int ticketId) async {
    try {
      final response = await HttpClientUtil.get(
        '/user/ticket/fetch',
        queryParameters: {'id': ticketId},
      );

      if (response['status'] == 'success') {
        return TicketDetail.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? '获取工单详情失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取工单详情失败：${e.toString()}');
    }
  }

  /// 回复工单
  Future<bool> replyTicket({
    required int ticketId,
    required String message,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/ticket/reply',
        body: {
          'id': ticketId,
          'message': message,
        },
      );

      if (response['status'] == 'success') {
        return response['data'] == true;
      } else {
        throw Exception(response['message'] ?? '回复工单失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('回复工单失败：${e.toString()}');
    }
  }

  // ===== 流量统计相关 API =====
  
  /// 获取流量明细列表
  Future<List<TrafficLog>> getTrafficLogs() async {
    try {
      final response = await HttpClientUtil.get('/user/stat/getTrafficLog');

      if (response['status'] == 'success') {
        List<dynamic> trafficData = response['data'] ?? [];
        return trafficData.map((traffic) => TrafficLog.fromJson(traffic)).toList();
      } else {
        throw Exception(response['message'] ?? '获取流量明细失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取流量明细失败：${e.toString()}');
    }
  }
}
