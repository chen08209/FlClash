import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/services/api_service_v2.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/state.dart';
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
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 使用AuthService进行登录
      final result = await _authService.login(
        email: _usernameController.text,
        password: _passwordController.text,
      );

      // 保存登录凭证
      final token = result['token'];
      final authData = result['auth_data'];
      final email = _usernameController.text;
      
      // 保存到SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_data', authData);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_logged_in', true);
      
      // 自动添加订阅配置
      await _autoAddSubscription();
      
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // 显示错误信息
      _showError('登录失败：${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _autoAddSubscription() async {
    try {
      // 调用API获取订阅信息
      final apiService = ApiServiceV2();
      final subscriptionInfo = await apiService.getSubscriptionInfo();
      
      // 获取订阅链接
      final subscribeUrl = subscriptionInfo['subscribe_url'];
      if (subscribeUrl == null || subscribeUrl.isEmpty) {
        print('未找到订阅链接');
        return;
      }
      
      // 检查是否已存在该订阅
      final profiles = globalState.config.profiles;
      final existingProfile = profiles.firstWhere(
        (p) => p.url == subscribeUrl,
        orElse: () => Profile.normal(url: ''),
      );
      
      if (existingProfile.url == subscribeUrl) {
        // 如果已存在，更新它
        print('订阅已存在，更新中...');
        await globalState.appController.updateProfile(existingProfile);
      } else {
        // 获取套餐名称作为配置名称
        final planName = subscriptionInfo['plan']?['name'] ?? '订阅配置';
        
        // 创建并更新配置
        final profile = await Profile.normal(
          url: subscribeUrl,
          label: planName,
        ).update();
        
        // 添加到配置列表
        await globalState.appController.addProfile(profile);
        
        // 如果是第一个配置，自动设置为当前配置
        if (profiles.isEmpty) {
          globalState.appController.applyProfileDebounce(silence: true);
        }
        
        print('订阅添加成功: $planName');
      }
    } catch (e) {
      print('自动添加订阅失败: $e');
      // 不显示错误，让用户正常进入主页
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
                  // 忘记密码链接
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: const Text('忘记密码？'),
                  ),
                  const SizedBox(height: 16),
                  // 注册链接
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '还没有账户？',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('立即注册'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 提示文本
                  Text(
                    '请使用您的账户邮箱和密码登录',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
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
