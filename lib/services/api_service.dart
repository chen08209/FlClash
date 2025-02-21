import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_clash/models/config.dart';

// API 服务类，提供通用的认证相关接口调用
class ApiService {
  // 发送验证码到指定邮箱
  static Future<Map<String, dynamic>> sendCode({
    required String apiBaseUrl,
    required String email,
    required int type,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/common/send_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'type': type}),
    ).timeout(const Duration(seconds: 10));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 重置密码（用于登录页面和个人中心）
  static Future<Map<String, dynamic>> resetPassword({
    required String apiBaseUrl,
    required String email,
    required String password,
    required String code,
    String? token, // 可选 token，用于已登录用户的请求
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = ' $token'; // 无 Bearer 前缀
    }
    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/auth/reset'),
      headers: headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'code': code,
      }),
    ).timeout(const Duration(seconds: 10));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 登录请求
  static Future<Map<String, dynamic>> login({
    required String apiBaseUrl,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 注册请求
  static Future<Map<String, dynamic>> register({
    required String apiBaseUrl,
    required String email,
    required String password,
    required String invite,
    String? code,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'invite': invite,
        'code': code?.isEmpty ?? true ? null : code,
      }),
    ).timeout(const Duration(seconds: 10));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
