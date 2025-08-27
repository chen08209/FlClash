import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _isEmailVerifyEnabled = false;
  bool _isInviteForced = false;
  List<String> _emailWhitelist = [];
  String? _selectedEmailSuffix;
  
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegistrationConfig();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailCodeController.dispose();
    _inviteCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRegistrationConfig() async {
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        final config = await _authService.getRegistrationConfig();
        if (mounted) {
          setState(() {
            _isEmailVerifyEnabled = config['is_email_verify'] == 1;
            _isInviteForced = config['is_invite_force'] == 1;
            _emailWhitelist = List<String>.from(config['email_whitelist_suffix'] ?? []);
            if (_emailWhitelist.isNotEmpty) {
              _selectedEmailSuffix = _emailWhitelist.first;
            }
          });
        }
        return;
      } catch (e) {
        retryCount++;
        if (retryCount <= maxRetries) {
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }
        if (mounted) {
          setState(() {
            _isEmailVerifyEnabled = true;
            _isInviteForced = false;
            _emailWhitelist = [
              'gmail.com',
              'qq.com',
              '163.com',
              'yahoo.com',
              'sina.com',
              '126.com',
              'outlook.com',
              'yeah.net',
              'foxmail.com'
            ];
            _selectedEmailSuffix = _emailWhitelist.first;
          });
        }
      }
    }
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _getFullEmail() {
    final username = _emailController.text.trim();
    final suffix = _selectedEmailSuffix;
    if (username.isNotEmpty && suffix != null) {
      return '$username@$suffix';
    }
    return '';
  }

  Future<void> _sendEmailCode() async {
    final fullEmail = _getFullEmail();
    if (fullEmail.isEmpty) {
      _showError('请先输入邮箱用户名并选择域名');
      return;
    }

    if (!_isValidEmail(fullEmail)) {
      _showError('邮箱格式不正确');
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    try {
      await _authService.sendEmailVerificationCode(fullEmail);
      _startCountdown();
      _showSuccess('验证码已发送，请查收邮箱');
    } catch (e) {
      _showError('发送验证码失败：${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      setState(() {
        _isSendingCode = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateEmailUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱用户名';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$').hasMatch(value)) {
      return '用户名格式不正确';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 8) {
      return '密码长度至少8位';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != _passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  String? _validateEmailCode(String? value) {
    if (!_isEmailVerifyEnabled) return null;
    
    if (value == null || value.isEmpty) {
      return '请输入邮箱验证码';
    }
    if (value.length != 6) {
      return '验证码应为6位数字';
    }
    return null;
  }

  String? _validateInviteCode(String? value) {
    if (!_isInviteForced) return null;
    
    if (value == null || value.isEmpty) {
      return '邀请码为必填项';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullEmail = _getFullEmail();
    if (fullEmail.isEmpty) {
      _showError('请完整填写邮箱信息');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.registerUser(
        email: fullEmail,
        password: _passwordController.text,
        emailCode: _emailCodeController.text,
        inviteCode: _inviteCodeController.text,
      );

      final token = result['token'];
      final authData = result['auth_data'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_data', authData);
      await prefs.setString('user_email', fullEmail);
      await prefs.setBool('is_logged_in', true);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
      
      _showSuccess('注册成功！');
    } catch (e) {
      _showError('注册失败：${e.toString().replaceFirst('Exception: ', '')}');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册账户'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '创建新账户',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: '邮箱用户名',
                          hintText: '请输入邮箱用户名',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: _validateEmailUsername,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('@', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 130,
                      child: DropdownButtonFormField<String>(
                        value: _selectedEmailSuffix,
                        decoration: InputDecoration(
                          labelText: '域名',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _emailWhitelist.map((suffix) {
                          return DropdownMenuItem(
                            value: suffix,
                            child: Text(suffix),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEmailSuffix = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请选择域名';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码（至少8位）',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    hintText: '请再次输入密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 16),
                if (_isEmailVerifyEnabled) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '邮箱验证码',
                            hintText: '请输入6位验证码',
                            prefixIcon: const Icon(Icons.verified_user),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: _validateEmailCode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: (_isSendingCode || _countdown > 0) ? null : _sendEmailCode,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSendingCode
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _countdown > 0 ? '${_countdown}s' : '发送',
                                  style: const TextStyle(fontSize: 12),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isInviteForced) ...[
                  TextFormField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      labelText: '邀请码',
                      hintText: '请输入邀请码',
                      prefixIcon: const Icon(Icons.card_giftcard),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: _validateInviteCode,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  TextFormField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      labelText: '邀请码（可选）',
                      hintText: '如有邀请码可填写',
                      prefixIcon: const Icon(Icons.card_giftcard),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
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
                            '注册',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('已有账户？返回登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
