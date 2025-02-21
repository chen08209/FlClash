// lib/pages/auth.dart
import 'dart:async';
import 'dart:convert';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiBaseUrl = "https://api.ppanel.dev";

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteController = TextEditingController();
  final _codeController = TextEditingController();
  String? _errorMessage;
  int _mode = 0; // 0: 登录, 1: 注册, 2: 重置密码
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      final config = Provider.of<Config>(context, listen: false);
      config.token = token;
      config.isAuthenticated = true;
      await _fetchSubscribeUrl(token);
      globalState.navigatorKey.currentState?.pushReplacementNamed('/home');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    final config = Provider.of<Config>(context, listen: false);
    config.token = token;
    config.isAuthenticated = true;
  }

  Future<void> _fetchSubscribeUrl(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/v1/public/user/subscribe'),
        headers: {'Authorization': 'Bearer $authToken'},
      ).timeout(const Duration(seconds: 10));
      print("订阅响应: ${response.statusCode}, ${response.body}");
      final data = jsonDecode(response.body);
      if (data['code'] == 0 && data['data']['list'].isNotEmpty) {
        final subscribeToken = data['data']['list'][0]['token'];
        final subscribeUrl = '$apiBaseUrl/api/subscribe?token=$subscribeToken';
        final config = Provider.of<Config>(context, listen: false);
        config.subscribeUrl = subscribeUrl;
        print("订阅 URL 已存储: $subscribeUrl");
        await _addProfileFromSubscribeUrl(subscribeUrl);
      } else {
        setState(() => _errorMessage = data['msg'] ?? "获取订阅失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "获取订阅错误: $e");
      print("订阅错误: $e");
    }
  }

  Future<void> _addProfileFromSubscribeUrl(String url) async {
    final config = Provider.of<Config>(context, listen: false);
    final newProfile = Profile.normal(label: "订阅配置", url: url);
    config.setProfile(newProfile);
    await newProfile.checkAndUpdate();
  }

  Future<void> _sendCode(int type) async {
    final email = _emailController.text;
    print("发送验证码: email=$email, type=$type");
    if (email.isEmpty) {
      setState(() => _errorMessage = "请输入邮箱");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/v1/common/send_code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'type': type}),
      ).timeout(const Duration(seconds: 10));
      print("发送验证码响应: ${response.statusCode}, ${response.body}");
      final data = jsonDecode(response.body);
      if (data['code'] == 200 && data['data']['status']) {
        setState(() => _errorMessage = "验证码发送成功");
      } else {
        setState(() => _errorMessage = data['msg'] ?? "发送验证码失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
      print("发送验证码错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    print("尝试登录: email=$email, password=$password");
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "请填写所有字段");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      print("API响应: ${response.statusCode}, ${response.body}");
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        final token = data['data']['token'];
        print("登录成功，token: $token");
        await _saveToken(token);
        await _fetchSubscribeUrl(token);
        globalState.navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        setState(() => _errorMessage = data['msg'] ?? "登录失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
      print("登录错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final invite = _inviteController.text;
    final code = _codeController.text;
    print("尝试注册: email=$email, password=$password, invite=$invite, code=$code");
    if (email.isEmpty || password.isEmpty || invite.isEmpty) {
      setState(() => _errorMessage = "请填写所有必填字段");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'invite': invite,
          'code': code.isEmpty ? null : code,
        }),
      ).timeout(const Duration(seconds: 10));
      print("注册响应: ${response.statusCode}, ${response.body}");
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        final token = data['data']['token'];
        print("注册成功，token: $token");
        await _saveToken(token);
        await _fetchSubscribeUrl(token);
        globalState.navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        setState(() => _errorMessage = data['msg'] ?? "注册失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
      print("注册错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final code = _codeController.text;
    print("尝试重置密码: email=$email, password=$password, code=$code");
    if (email.isEmpty || password.isEmpty || code.isEmpty) {
      setState(() => _errorMessage = "请填写所有字段");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/v1/auth/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'code': code,
        }),
      ).timeout(const Duration(seconds: 10));
      print("重置密码响应: ${response.statusCode}, ${response.body}");
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        final token = data['data']['token'];
        print("重置密码成功，token: $token");
        await _saveToken(token);
        await _fetchSubscribeUrl(token);
        globalState.navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        setState(() => _errorMessage = data['msg'] ?? "重置密码失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
      print("重置密码错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _inviteController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _mode == 0 ? "欢迎登录" : _mode == 1 ? "注册账号" : "重置密码",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "邮箱",
                          prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: "密码",
                          prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          filled: true,
                          fillColor: Colors.grey,
                        ),
                        obscureText: true,
                      ),
                      if (_mode == 1) ...[
                        const SizedBox(height: 12.0),
                        TextField(
                          controller: _inviteController,
                          decoration: const InputDecoration(
                            labelText: "邀请码",
                            prefixIcon: Icon(Icons.card_giftcard, color: Colors.blueAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                            filled: true,
                            fillColor: Colors.grey,
                          ),
                        ),
                      ],
                      if (_mode > 0) ...[
                        const SizedBox(height: 12.0),
                        TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: "验证码",
                            prefixIcon: Icon(Icons.verified, color: Colors.blueAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                            filled: true,
                            fillColor: Colors.grey,
                          ),
                        ),
                      ],
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                print("按钮点击，当前模式: $_mode");
                                if (_mode == 0) _login();
                                else if (_mode == 1) _register();
                                else _resetPassword();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          elevation: 4.0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                _mode == 0 ? "登录" : _mode == 1 ? "注册" : "重置",
                                style: const TextStyle(fontSize: 16.0),
                              ),
                      ),
                      if (_mode > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: TextButton(
                            onPressed: _isLoading ? null : () => _sendCode(_mode),
                            child: const Text(
                              "发送验证码",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _mode = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: _mode == 0 ? Colors.blueAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                "登录",
                                style: TextStyle(
                                  color: _mode == 0 ? Colors.white : Colors.grey.shade700,
                                  fontWeight: _mode == 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () => setState(() => _mode = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: _mode == 1 ? Colors.blueAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                "注册",
                                style: TextStyle(
                                  color: _mode == 1 ? Colors.white : Colors.grey.shade700,
                                  fontWeight: _mode == 1 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () => setState(() => _mode = 2),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: _mode == 2 ? Colors.blueAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                "重置密码",
                                style: TextStyle(
                                  color: _mode == 2 ? Colors.white : Colors.grey.shade700,
                                  fontWeight: _mode == 2 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
