// lib/pages/auth.dart
import 'dart:convert';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiBaseUrl = "https://api.ppanel.dev"; // 替换为实际 API 地址

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

  @override
  void initState() {
    super.initState();
    _loadToken(); // 加载已保存的 token
  }

  // 从 SharedPreferences 加载 token
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      final config = Provider.of<Config>(context, listen: false);
      config.token = token;
      config.isAuthenticated = true;
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // 保存 token 到 SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    final config = Provider.of<Config>(context, listen: false);
    config.token = token;
    config.isAuthenticated = true;
  }

  // 发送验证码
  Future<void> _sendCode(int type) async {
    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() => _errorMessage = "Please enter email");
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/common/send_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'type': type}),
    );

    final data = jsonDecode(response.body);
    if (data['code'] == 200 && data['data']['status']) {
      setState(() => _errorMessage = "Code sent successfully");
    } else {
      setState(() => _errorMessage = data['msg'] ?? "Failed to send code");
    }
  }

  // 登录
  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields");
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      final token = data['data']['token'];
      await _saveToken(token);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _errorMessage = data['msg'] ?? "Login failed");
    }
  }

  // 注册
  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final invite = _inviteController.text;
    final code = _codeController.text;

    if (email.isEmpty || password.isEmpty || invite.isEmpty) {
      setState(() => _errorMessage = "Please fill in all required fields");
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'invite': invite,
        'code': code.isEmpty ? null : code,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      final token = data['data']['token'];
      await _saveToken(token);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _errorMessage = data['msg'] ?? "Registration failed");
    }
  }

  // 重置密码
  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final code = _codeController.text;

    if (email.isEmpty || password.isEmpty || code.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields");
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/v1/auth/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'code': code,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      final token = data['data']['token'];
      await _saveToken(token);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _errorMessage = data['msg'] ?? "Reset password failed");
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
      appBar: AppBar(
        title: Text(_mode == 0 ? "Login" : _mode == 1 ? "Register" : "Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              if (_mode == 1) // 注册模式显示邀请码
                TextField(
                  controller: _inviteController,
                  decoration: const InputDecoration(labelText: "Invite Code"),
                ),
              if (_mode > 0) // 注册和重置密码显示验证码
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: "Verification Code"),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_mode == 0) _login();
                  else if (_mode == 1) _register();
                  else _resetPassword();
                },
                child: Text(_mode == 0 ? "Login" : _mode == 1 ? "Register" : "Reset"),
              ),
              if (_mode > 0) // 发送验证码按钮
                TextButton(
                  onPressed: () => _sendCode(_mode),
                  child: const Text("Send Verification Code"),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _mode = 0),
                    child: const Text("Login"),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _mode = 1),
                    child: const Text("Register"),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _mode = 2),
                    child: const Text("Reset Password"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
