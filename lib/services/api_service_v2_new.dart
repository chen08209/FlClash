import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/common/http_client_util.dart';

class ApiServiceV2 {
  // 使用HttpClientUtil代替EndpointService和HttpClient

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

  /// 刷新端点（委托给HttpClientUtil）
  Future<void> refreshEndpoints() async {
    await HttpClientUtil.refreshEndpoints();
    print('ApiServiceV2: Refreshed endpoints via HttpClientUtil');
  }
}
