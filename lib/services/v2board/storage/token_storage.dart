import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_clash/common/common.dart';

/// V2Board Token 安全存储管理类
/// 使用 flutter_secure_storage 安全存储 API token 和相关认证信息
class TokenStorage {
  static const String _tokenKey = 'v2board_auth_token';
  static const String _userInfoKey = 'v2board_user_info';
  static const String _baseUrlKey = 'v2board_base_url';
  static const String _loginTimeKey = 'v2board_login_time';
  
  late final FlutterSecureStorage _secureStorage;
  
  /// 初始化存储
  Future<void> initialize() async {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
      lOptions: LinuxOptions(),
      wOptions: WindowsOptions(
        useBackwardCompatibility: false,
      ),
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }
  
  /// 保存认证 token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(
        key: _loginTimeKey, 
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      commonPrint.log('V2Board token saved successfully');
    } catch (e) {
      commonPrint.log('Failed to save V2Board token: $e');
      rethrow;
    }
  }
  
  /// 获取认证 token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        // 检查 token 是否过期（假设 token 有效期为 30 天）
        final loginTimeStr = await _secureStorage.read(key: _loginTimeKey);
        if (loginTimeStr != null) {
          final loginTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(loginTimeStr),
          );
          final now = DateTime.now();
          final difference = now.difference(loginTime);
          
          // 如果超过 30 天，清除 token
          if (difference.inDays > 30) {
            await clearToken();
            return null;
          }
        }
      }
      return token;
    } catch (e) {
      commonPrint.log('Failed to get V2Board token: $e');
      return null;
    }
  }
  
  /// 清除认证 token
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _loginTimeKey);
      commonPrint.log('V2Board token cleared successfully');
    } catch (e) {
      commonPrint.log('Failed to clear V2Board token: $e');
    }
  }
  
  /// 保存用户信息
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final userInfoJson = jsonEncode(userInfo);
      await _secureStorage.write(key: _userInfoKey, value: userInfoJson);
      commonPrint.log('V2Board user info saved successfully');
    } catch (e) {
      commonPrint.log('Failed to save V2Board user info: $e');
      rethrow;
    }
  }
  
  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userInfoJson = await _secureStorage.read(key: _userInfoKey);
      if (userInfoJson != null) {
        return jsonDecode(userInfoJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      commonPrint.log('Failed to get V2Board user info: $e');
      return null;
    }
  }
  
  /// 清除用户信息
  Future<void> clearUserInfo() async {
    try {
      await _secureStorage.delete(key: _userInfoKey);
      commonPrint.log('V2Board user info cleared successfully');
    } catch (e) {
      commonPrint.log('Failed to clear V2Board user info: $e');
    }
  }
  
  /// 保存 V2Board 基础 URL
  Future<void> saveBaseUrl(String baseUrl) async {
    try {
      await _secureStorage.write(key: _baseUrlKey, value: baseUrl);
      commonPrint.log('V2Board base URL saved successfully');
    } catch (e) {
      commonPrint.log('Failed to save V2Board base URL: $e');
      rethrow;
    }
  }
  
  /// 获取 V2Board 基础 URL
  Future<String?> getBaseUrl() async {
    try {
      return await _secureStorage.read(key: _baseUrlKey);
    } catch (e) {
      commonPrint.log('Failed to get V2Board base URL: $e');
      return null;
    }
  }
  
  /// 清除 V2Board 基础 URL
  Future<void> clearBaseUrl() async {
    try {
      await _secureStorage.delete(key: _baseUrlKey);
      commonPrint.log('V2Board base URL cleared successfully');
    } catch (e) {
      commonPrint.log('Failed to clear V2Board base URL: $e');
    }
  }
  
  /// 清除所有存储的数据
  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearToken(),
        clearUserInfo(),
        clearBaseUrl(),
      ]);
      commonPrint.log('All V2Board data cleared successfully');
    } catch (e) {
      commonPrint.log('Failed to clear all V2Board data: $e');
    }
  }
  
  /// 检查是否有有效的认证信息
  Future<bool> hasValidAuth() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 获取登录时间
  Future<DateTime?> getLoginTime() async {
    try {
      final loginTimeStr = await _secureStorage.read(key: _loginTimeKey);
      if (loginTimeStr != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(loginTimeStr));
      }
      return null;
    } catch (e) {
      commonPrint.log('Failed to get login time: $e');
      return null;
    }
  }
  
  /// 检查 token 是否即将过期（剩余时间少于 3 天）
  Future<bool> isTokenExpiringSoon() async {
    try {
      final loginTime = await getLoginTime();
      if (loginTime != null) {
        final now = DateTime.now();
        final difference = now.difference(loginTime);
        return difference.inDays > 27; // 30 - 3 = 27
      }
      return false;
    } catch (e) {
      commonPrint.log('Failed to check token expiration: $e');
      return false;
    }
  }
}
