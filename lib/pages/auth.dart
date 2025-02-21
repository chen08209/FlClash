import 'dart:async';
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

  Future<void> _sendCode(int type) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = "请输入邮箱");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/v1/common/send_code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'type': type}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      setState(() => _errorMessage =
          (data['code'] == 200 && data['data']['status']) ? "验证码已发送" : data['msg']);
    } catch (e) {
      setState(() => _errorMessage = "请求出错: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "请填写所有字段");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        await _saveToken(data['data']['token']);
        globalState.navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        setState(() => _errorMessage = data['msg'] ?? "登录失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "请求错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final invite = _inviteController.text.trim();
    final code = _codeController.text.trim();

    if (email.isEmpty || password.isEmpty || invite.isEmpty) {
      setState(() => _errorMessage = "请填写所有必填字段");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/v1/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'invite': invite,
              'code': code.isEmpty ? null : code,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        await _saveToken(data['data']['token']);
        globalState.navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        setState(() => _errorMessage = data['msg'] ?? "注册失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "请求错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF9013FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_mode != 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                            onPressed: () => setState(() => _mode = 0),
                          ),
                        ),
                      Text(
                        _mode == 0 ? "欢迎登录" : _mode == 1 ? "注册账号" : "重置密码",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(_emailController, "邮箱", Icons.email),
                      const SizedBox(height: 12.0),
                      _buildTextField(_passwordController, "密码", Icons.lock, obscureText: true),
                      if (_mode == 1) ...[
                        const SizedBox(height: 12.0),
                        _buildTextField(_inviteController, "邀请码", Icons.card_giftcard),
                      ],
                      if (_mode > 0) ...[
                        const SizedBox(height: 12.0),
                        _buildTextField(_codeController, "验证码", Icons.verified),
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
                            : () => _mode == 0 ? _login() : _mode == 1 ? _register() : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                _mode == 0 ? "登录" : _mode == 1 ? "注册" : "重置",
                                style: const TextStyle(fontSize: 16.0, color: Colors.white),
                              ),
                      ),
                      if (_mode > 0)
                        TextButton(
                          onPressed: _isLoading ? null : () => _sendCode(_mode),
                          child: const Text(
                            "发送验证码",
                            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      if (_mode == 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _mode = 1),
                              child: const Text("没有账号？注册"),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _mode = 2),
                              child: const Text("忘记密码？"),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
    );
  }
}
