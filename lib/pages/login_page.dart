import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://origin.huanshen.org/api/v1/passport/auth/login',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.data['status'] == 'success') {
        // Handle successful login
        // 保存登录凭证
        final token = response.data['data']['token'];
        final authData = response.data['data']['auth_data'];
        final email = _usernameController.text;
        
        // 保存到SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('auth_data', authData);
        await prefs.setString('user_email', email);
        await prefs.setBool('is_logged_in', true);
        
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // 显示服务器返回的错误信息
        _showError(response.data['message'] ?? '登录失败');
      }
    } on DioException catch (e) {
      // 处理网络错误
      if (e.response != null) {
        // 服务器返回了错误响应
        try {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            _showError(errorData['message']);
          } else {
            _showError('服务器错误：${e.response!.statusCode}');
          }
        } catch (_) {
          _showError('服务器错误：${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        _showError('连接超时，请检查网络');
      } else if (e.type == DioExceptionType.connectionError) {
        _showError('网络连接失败，请检查网络设置');
      } else {
        _showError('网络错误：${e.message}');
      }
    } catch (e) {
      // 处理其他错误
      _showError('登录失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _performLogin();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo或标题
                  Icon(
                    Icons.shield,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FlClash',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // 用户名输入框
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '邮箱',
                      hintText: '请输入邮箱',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入邮箱';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 密码输入框
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '请输入密码',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '登录',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 提示文本
                  Text(
                    '请使用您的账户邮箱和密码登录',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
