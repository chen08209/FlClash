import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/http_client_util.dart';

class ApiServiceV2 {
  // 使用HttpClientUtil代替EndpointService和HttpClient

  /// 初始化方法（为了兼容性，实际初始化在HttpClientUtil中完成）
  Future<void> initialize() async {
    // HttpClientUtil已在main.dart中初始化，这里无需操作
    print('ApiServiceV2: Using HttpClientUtil (already initialized)');
  }

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await HttpClientUtil.get('/user/info');
      
      if (response['status'] == 'success') {
        return response['data'];
      }
      throw Exception(response['message'] ?? '请求失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 获取订阅信息
  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    try {
      final response = await HttpClientUtil.get('/user/getSubscribe');
      
      if (response['status'] == 'success') {
        return response['data'];
      }
      throw Exception(response['message'] ?? '请求失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取订阅信息失败: $e');
    }
  }

  /// 获取最新订阅信息（别名方法）
  Future<Map<String, dynamic>> getLatestSubscriptionInfo() async {
    return getSubscriptionInfo();
  }

  /// 更新服务器订阅
  Future<void> updateServerSubscription() async {
    try {
      final response = await HttpClientUtil.post('/user/subscribe/update');
      
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? '更新订阅失败');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('更新订阅失败: $e');
    }
  }

  /// 获取邀请信息
  Future<InviteInfo> getInviteInfo() async {
    try {
      final response = await HttpClientUtil.get('/user/invite/fetch');
      
      if (response['status'] == 'success') {
        return InviteInfo.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? '获取邀请信息失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取邀请信息失败: $e');
    }
  }

  /// 获取邀请详情列表
  Future<InviteDetailsResponse> getInviteDetails() async {
    try {
      final response = await HttpClientUtil.get('/user/invite/details');
      
      if (response['status'] == 'success') {
        return InviteDetailsResponse.fromJson(response);
      }
      throw Exception(response['message'] ?? '获取邀请详情失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取邀请详情失败: $e');
    }
  }

  /// 生成邀请码
  Future<bool> generateInviteCode() async {
    try {
      final response = await HttpClientUtil.post('/user/invite/generate');
      
      if (response['status'] == 'success') {
        return response['data'] ?? true;
      }
      throw Exception(response['message'] ?? '生成邀请码失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('生成邀请码失败: $e');
    }
  }

  /// 转移佣金到余额
  Future<bool> transferCommissionToBalance(int amountInCents) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/invite/save',
        body: {'amount': amountInCents},
      );
      
      if (response['status'] == 'success') {
        return response['data'] ?? true;
      }
      throw Exception(response['message'] ?? '转移佣金失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('转移佣金失败: $e');
    }
  }

  /// 提取佣金
  Future<bool> withdrawCommission({
    required String withdrawMethod,
    required String withdrawAccount,
    required int amountInCents,
  }) async {
    try {
      final response = await HttpClientUtil.post(
        '/user/invite/withdraw',
        body: {
          'withdraw_method': withdrawMethod,
          'withdraw_account': withdrawAccount,
          'amount': amountInCents,
        },
      );
      
      if (response['status'] == 'success') {
        return response['data'] ?? true;
      }
      throw Exception(response['message'] ?? '提取佣金失败');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('提取佣金失败: $e');
    }
  }


  /// 获取公告列表
  Future<NoticeListResponse> getNoticeList() async {
    try {
      print('NoticeAPI: 开始调用 /user/notice/fetch');
      final response = await HttpClientUtil.get('/user/notice/fetch');
      print('NoticeAPI: 收到响应: $response');
      
      // 根据您提供的API响应格式：{"data": [...], "total": 8}
      // 或者可能包装在 {"status": "success", "data": {"data": [...], "total": 8}}
      Map<String, dynamic> responseData;
      
      if (response['status'] == 'success' && response['data'] != null) {
        // 如果有status和data包装
        responseData = response['data'];
      } else if (response['data'] != null && response['total'] != null) {
        // 如果直接返回data和total
        responseData = response;
      } else if (response['data'] != null) {
        // 如果只有data数组
        responseData = {
          'data': response['data'],
          'total': (response['data'] as List).length,
        };
      } else {
        throw Exception('API响应格式不正确');
      }
      
      print('NoticeAPI: 处理后的数据: $responseData');
      return NoticeListResponse.fromJson(responseData);
    } catch (e) {
      print('NoticeAPI: 调用失败: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('获取公告列表失败: $e');
    }
  }

  /// 刷新端点（委托给HttpClientUtil）
  Future<void> refreshEndpoints() async {
    await HttpClientUtil.refreshEndpoints();
    print('ApiServiceV2: Refreshed endpoints via HttpClientUtil');
  }
}
