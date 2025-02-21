// lib/pages/auth.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/state.dart';

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
      Provider.of<Config>(context, listen: false)
        ..token = token
        ..isAuthenticated = true;
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    Provider.of<Config>(context, listen: false)
      ..token = token
      ..isAuthenticated = true;
  }

  Future<void> _sendCode(int type) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return _showSnackBar("请输入邮箱");

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/v1/common/send_code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'type': type}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      data['code'] == 200 && data['data']['status']
          ? _showSnackBar("验证码发送成功")
          : _showSnackBar(data['msg'] ?? "发送验证码失败");
    } catch (e) {
      _showSnackBar("请求出错: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAuth(Function apiCall) async {
    setState(() => _isLoading = true);
    await apiCall();
    setState(() => _isLoading = false);
  }

  Future<void> _login() async => _handleAuth(() async {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        if (email.isEmpty || password.isEmpty) return _showSnackBar("请填写所有字段");

        final response = await http.post(
          Uri.parse('$apiBaseUrl/v1/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          await _saveToken(data['data']['token']);
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          _showSnackBar(data['msg'] ?? "登录失败");
        }
      });

  Future<void> _register() async => _handleAuth(() async {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final invite = _inviteController.text.trim();
        final code = _codeController.text.trim();

        if ([email, password, invite].any((e) => e.isEmpty)) return _showSnackBar("请填写所有必填字段");

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

        final data = jsonDecode(response.body);
        data['code'] == 200
            ? {
                await _saveToken(data['data']['token']),
                Navigator.of(context).pushReplacementNamed('/home'),
              }
            : _showSnackBar(data['msg'] ?? "注册失败");
      });

  Future<void> _resetPassword() async => _handleAuth(() async {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final code = _codeController.text.trim();

        if ([email, password, code].any((e) => e.isEmpty)) return _showSnackBar("请填写所有字段");

        final response = await http.post(
          Uri.parse('$apiBaseUrl/v1/auth/reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password, 'code': code}),
        ).timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);
        data['code'] == 200
            ? {
                await _saveToken(data['data']['token']),
                Navigator.of(context).pushReplacementNamed('/home'),
              }
            : _showSnackBar(data['msg'] ?? "重置密码失败");
      });

  void _showSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

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
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A90E2), Color(0xFF8E44AD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _mode == 0 ? "欢迎登录" : _mode == 1 ? "注册账号" : "重置密码",
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(_emailController, "邮箱", Icons.email),
                        const SizedBox(height: 12),
                        _buildTextField(_passwordController, "密码", Icons.lock, obscureText: true),
                        if (_mode == 1) ...[
                          const SizedBox(height: 12),
                          _buildTextField(_inviteController, "邀请码", Icons.card_giftcard),
                        ],
                        if (_mode > 0) ...[
                          const SizedBox(height: 12),
                          _buildTextField(_codeController, "验证码", Icons.verified),
                          TextButton(
                            onPressed: _isLoading ? null : () => _sendCode(_mode),
                            child: const Text("发送验证码"),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _mode == 0
                                  ? _login()
                                  : _mode == 1
                                      ? _register()
                                      : _resetPassword(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text(_mode == 0 ? "登录" : _mode == 1 ? "注册" : "重置密码"),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildModeButton("登录", 0),
                            const SizedBox(width: 12),
                            _buildModeButton("注册", 1),
                            const SizedBox(width: 12),
                            _buildModeButton("重置密码", 2),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, int mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
