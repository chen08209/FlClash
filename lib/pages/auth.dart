import 'dart:async';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/services/api_service.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 认证页面，支持登录、注册和重置密码
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // 新增确认密码控制器
  final _inviteController = TextEditingController();
  final _codeController = TextEditingController();
  String? _errorMessage;
  int _mode = 0; // 0: 登录, 1: 注册, 2: 重置密码
  bool _isLoading = false;
  int _countdown = 0; // 验证码倒计时（秒）
  Timer? _timer; // 倒计时定时器

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // 检查本地是否有 token，若有则跳转到首页
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      final config = Provider.of<Config>(context, listen: false);
      config.token = token;
      config.isAuthenticated = true;
      _navigateToHome();
    }
  }

  // 保存 token 和用户信息到本地和 Config
  Future<void> _saveToken(String token, String email, [String? password]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    final config = Provider.of<Config>(context, listen: false);
    config.token = token;
    config.isAuthenticated = true;
    config.user = User(email: email, password: password);
  }

  // 发送验证码并启动60秒倒计时
  Future<void> _sendCode(int type) async {
    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() => _errorMessage = "请输入邮箱");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _countdown = 60; // 初始化倒计时为60秒
    });
    try {
      final config = Provider.of<Config>(context, listen: false);
      final data = await ApiService.sendCode(
        apiBaseUrl: config.apiBaseUrl,
        email: email,
        type: type,
      );
      if (data['code'] == 200 && data['data']['status']) {
        setState(() => _errorMessage = "验证码发送成功");
        _startCountdown(); // 启动倒计时
      } else {
        setState(() {
          _errorMessage = data['msg'] ?? "发送验证码失败";
          _countdown = 0; // 重置倒计时
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "错误: $e";
        _countdown = 0; // 重置倒计时
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 启动验证码倒计时
  void _startCountdown() {
    _timer?.cancel(); // 取消现有定时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  // 执行登录
  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "请填写所有字段");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final config = Provider.of<Config>(context, listen: false);
      final data = await ApiService.login(
        apiBaseUrl: config.apiBaseUrl,
        email: email,
        password: password,
      );
      if (data['code'] == 200) {
        await _saveToken(data['data']['token'], email, password);
        _navigateToHome();
      } else {
        setState(() => _errorMessage = data['msg'] ?? "登录失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 执行注册
  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final invite = _inviteController.text;
    final code = _codeController.text;
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || invite.isEmpty) {
      setState(() => _errorMessage = "请填写所有必填字段");
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = "两次输入的密码不一致");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final config = Provider.of<Config>(context, listen: false);
      final data = await ApiService.register(
        apiBaseUrl: config.apiBaseUrl,
        email: email,
        password: password,
        invite: invite,
        code: code,
      );
      if (data['code'] == 200) {
        await _saveToken(data['data']['token'], email, password);
        _navigateToHome();
      } else {
        setState(() => _errorMessage = data['msg'] ?? "注册失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 执行密码重置
  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final code = _codeController.text;
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || code.isEmpty) {
      setState(() => _errorMessage = "请填写所有字段");
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = "两次输入的密码不一致");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final config = Provider.of<Config>(context, listen: false);
      final data = await ApiService.resetPassword(
        apiBaseUrl: config.apiBaseUrl,
        email: email,
        password: password,
        code: code,
      );
      if (data['code'] == 200) {
        await _saveToken(data['data']['token'], email, password);
        _navigateToHome();
      } else {
        setState(() => _errorMessage = data['msg'] ?? "重置密码失败");
      }
    } catch (e) {
      setState(() => _errorMessage = "错误: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 导航到首页
  void _navigateToHome() {
    globalState.navigatorKey.currentState?.pushReplacementNamed('/home') ??
        Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteController.dispose();
    _codeController.dispose();
    _timer?.cancel(); // 清理定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0), // 桌面端更大内边距
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450 : double.infinity, // 桌面端限制最大宽度
              ),
              child: Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 标题和返回按钮
                      Row(
                        children: [
                          if (_mode != 0)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: () => setState(() => _mode = 0),
                            ),
                          Expanded(
                            child: Text(
                              _mode == 0 ? "欢迎登录" : _mode == 1 ? "注册账号" : "重置密码",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // 邮箱输入框
                      _buildTextField(_emailController, "邮箱", Icons.email),
                      const SizedBox(height: 12.0),
                      // 密码输入框
                      _buildTextField(_passwordController, "密码", Icons.lock, obscureText: true),
                      // 确认密码（注册和重置密码模式）
                      if (_mode > 0) ...[
                        const SizedBox(height: 12.0),
                        _buildTextField(_confirmPasswordController, "确认密码", Icons.lock_outline,
                            obscureText: true),
                      ],
                      // 邀请码（注册模式）
                      if (_mode == 1) ...[
                        const SizedBox(height: 12.0),
                        _buildTextField(_inviteController, "邀请码", Icons.card_giftcard),
                      ],
                      // 验证码和发送按钮（注册和重置密码模式）
                      if (_mode > 0) ...[
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(_codeController, "验证码", Icons.verified),
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: (_isLoading || _countdown > 0)
                                  ? null
                                  : () => _sendCode(_mode), // 倒计时或加载时禁用
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700], // 一致的蓝色
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              ),
                              child: Text(_countdown > 0 ? "$_countdown秒" : "发送验证码"),
                            ),
                          ],
                        ),
                      ],
                      // 错误或提示信息
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
                      // 主操作按钮
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _mode == 0
                                ? _login()
                                : _mode == 1
                                    ? _register()
                                    : _resetPassword(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700], // 一致的蓝色
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isDesktop ? 16.0 : 14.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                              )
                            : Text(
                                _mode == 0 ? "登录" : _mode == 1 ? "注册" : "重置",
                                style: const TextStyle(fontSize: 16.0),
                              ),
                      ),
                      const SizedBox(height: 16.0),
                      // 模式切换选项（仅登录模式）
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

  // 重构的输入框样式
  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]), // 一致的蓝色图标
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
    );
  }
}
