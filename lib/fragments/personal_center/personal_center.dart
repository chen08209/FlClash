import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/services/api_service.dart';

// 个人中心页面，展示用户信息并提供修改密码和退出登录功能
class PersonalCenterFragment extends StatefulWidget {
  const PersonalCenterFragment({super.key});

  @override
  State<PersonalCenterFragment> createState() => _PersonalCenterFragmentState();
}

class _PersonalCenterFragmentState extends State<PersonalCenterFragment> {
  bool _isLoading = false; // 控制加载状态

  // 退出登录功能，清空认证信息并跳转到登录页面
  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true); // 开始加载
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token'); // 移除本地存储的 token
      final config = Provider.of<Config>(context, listen: false);
      config.token = null; // 清空 token
      config.isAuthenticated = false; // 标记为未认证
      config.user = null; // 清空用户信息
      // 跳转到登录页面，使用全局导航器或当前上下文
      globalState.navigatorKey.currentState?.pushReplacementNamed('/auth') ??
          Navigator.of(context).pushReplacementNamed('/auth');
    } catch (e) {
      // 显示退出失败的提示
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("退出失败: $e")));
    } finally {
      setState(() => _isLoading = false); // 结束加载
    }
  }

  // 发送验证码到用户邮箱，用于密码修改验证
  Future<void> _sendCode(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请提供邮箱")));
      return;
    }
    setState(() => _isLoading = true); // 开始加载
    try {
      final config = Provider.of<Config>(context, listen: false);
      final data = await ApiService.sendCode(
        apiBaseUrl: config.apiBaseUrl,
        email: email,
        type: 2, // type=2 表示重置密码
      );
      if (data['code'] == 200 && data['data']['status']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("验证码发送成功")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'] ?? "发送验证码失败")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("错误: $e")));
    } finally {
      setState(() => _isLoading = false); // 结束加载
    }
  }

  // 修改密码功能，向服务器发送带有邮箱、密码和验证码的请求
  Future<void> _changePassword(String email, String newPassword, String code) async {
    final config = Provider.of<Config>(context, listen: false);
    if (config.token == null || config.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("未登录，无法修改密码")));
      return;
    }

    setState(() => _isLoading = true); // 开始加载
    try {
      final data = await ApiService.resetPassword(
        apiBaseUrl: config.apiBaseUrl,
        email: email,
        password: newPassword,
        code: code,
        token: config.token, // 传递当前用户的 token
      );
      if (data['code'] == 200) {
        // 修改成功，更新本地用户密码并显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("密码修改成功")));
        config.user = config.user!.copyWith(password: newPassword);
      } else {
        // 修改失败，显示服务器返回的错误信息
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'] ?? "修改密码失败")));
      }
    } catch (e) {
      // 捕获网络或其他异常，显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("错误: $e")));
    } finally {
      setState(() => _isLoading = false); // 结束加载
    }
  }

  // 显示修改密码对话框，包含邮箱、新密码、验证码和确认密码输入框
  void _showChangePasswordDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("修改密码"), // 对话框标题
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 最小高度
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "邮箱",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12), // 输入框间距
              TextField(
                controller: passwordController,
                obscureText: true, // 隐藏输入内容
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "新密码",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "确认密码",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: "验证码",
                        prefixIcon: Icon(Icons.verified),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => _sendCode(emailController.text), // 发送验证码
                    child: const Text("发送验证码", style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 关闭对话框
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final email = emailController.text;
                    final newPassword = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;
                    final code = codeController.text;
                    // 检查输入是否为空
                    if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请填写所有字段")));
                      return;
                    }
                    // 检查两次输入是否一致
                    if (newPassword != confirmPassword) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("两次输入的密码不一致")));
                      return;
                    }
                    Navigator.pop(context); // 关闭对话框
                    await _changePassword(email, newPassword, code); // 执行密码修改
                  },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                  )
                : const Text("确认修改"), // 加载时显示进度条
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<Config>(context);
    final email = config.user?.email ?? "未登录用户"; // 获取用户邮箱，未登录时显示默认文本

    return Scaffold(
      // 移除 AppBar，直接使用 body
      body: Container(
        color: Colors.grey.shade200, // 默认背景色，替换渐变
        padding: const EdgeInsets.all(16.0), // 整体内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 子元素宽度填满
          children: [
            // 用户头像
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : "U",
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
            const SizedBox(height: 16), // 头像与邮箱间距
            // 用户邮箱
            Text(
              email,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24), // 邮箱与按钮间距
            // 修改密码按钮
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text("修改密码"),
              onPressed: _isLoading ? null : _showChangePasswordDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
            const SizedBox(height: 16), // 按钮间距
            // 退出登录按钮
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("退出登录"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              onPressed: _isLoading ? null : _logout,
            ),
          ],
        ),
      ),
    );
  }
}
