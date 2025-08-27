import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_clash/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailCodeController = TextEditingController();
  
  final AuthService _authService = AuthService();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isSendingCode = false;
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRegistrationConfig() async {
    try {
      final config = await _authService.getRegistrationConfig();
      if (mounted) {
        setState(() {
          _emailWhitelist = List<String>.from(config['email_whitelist_suffix'] ?? []);
          if (_emailWhitelist.isNotEmpty) {
            _selectedEmailSuffix = _emailWhitelist.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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

  String _getFullEmail() {
    final username = _emailController.text.trim();
    final suffix = _selectedEmailSuffix;
    if (username.isNotEmpty && suffix != null) {
      return '$username@$suffix';
    }
    return '';
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
      return '请输入新密码';
    }
    if (value.length < 8) {
      return '密码长度至少8位';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认新密码';
    }
    if (value != _newPasswordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  String? _validateEmailCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱验证码';
    }
    if (value.length != 6) {
      return '验证码应为6位数字';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
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
      await _authService.resetPassword(
        email: fullEmail,
        password: _newPasswordController.text,
        emailCode: _emailCodeController.text,
      );
      
      _showSuccess('密码重置成功！');
      
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
      
    } catch (e) {
      _showError('重置密码失败：${e.toString().replaceFirst('Exception: ', '')}');
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
        title: const Text('重置密码'),
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
                  Icons.lock_reset,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '重置您的密码',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请输入您的邮箱地址，我们将向您发送验证码',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                  textAlign: TextAlign.center,
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: '邮箱验证码',
                          hintText: '请输入6位验证码',
                          prefixIcon: const Icon(Icons.verified_user),
                          counterText: '',
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
                      height: 56,
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
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '新密码',
                    hintText: '请输入新密码（至少8位）',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
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
                    labelText: '确认新密码',
                    hintText: '请再次输入新密码',
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
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
                            '重置密码',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('返回登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
