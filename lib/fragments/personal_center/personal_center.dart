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
  bool _isLoading = false; // 控制加载状态，用于禁用按钮或显示进度条

  // 退出登录功能，清空认证信息并跳转到登录页面
  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true); // 开始加载
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token'); // 移除本地存储的认证 token
      final config = Provider.of<Config>(context, listen: false);
      config.token = null; // 清空内存中的 token
      config.isAuthenticated = false; // 标记用户为未认证状态
      config.user = null; // 清空用户信息
      // 跳转到登录页面，优先使用全局导航器，若失败则使用当前上下文
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
        type: 2, // type=2 表示重置密码的验证码
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
        token: config.token, // 使用当前用户的 token 进行认证
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
            mainAxisSize: MainAxisSize.min, // 最小高度以适应内容
            children: [
              // 邮箱输入框
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? 400 : double.infinity, // 桌面端限制宽度
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "邮箱",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(height: 12), // 输入框间距
              // 新密码输入框
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // 隐藏输入内容
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "新密码",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 确认密码输入框
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "确认密码",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 验证码输入框和发送按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600 ? 300 : 200,
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
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.pop(context), // 关闭对话框
            child: const Text("取消"),
          ),
          // 确认修改按钮
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
                    // 检查两次输入的密码是否一致
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
                : const Text("确认修改"), // 加载时显示进度条，否则显示文字
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<Config>(context);
    final email = config.user?.email ?? "未登录用户"; // 获取用户邮箱，未登录时显示默认文本
    final screenWidth = MediaQuery.of(context).size.width; // 获取屏幕宽度
    final isDesktop = screenWidth > 600; // 判断是否为桌面端（宽度大于600）

    return Scaffold(
      // 页面主体，无 AppBar
      body: Container(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0), // 桌面端更大内边距，移动端较小
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中对齐
          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中对齐
          children: [
            // 用户头像
            CircleAvatar(
              radius: isDesktop ? 60 : 40, // 桌面端头像更大
              backgroundColor: Colors.blueAccent, // 蓝色背景
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : "U", // 显示邮箱首字母或 "U"
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 48 : 32, // 桌面端文字更大
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 16), // 动态间距，桌面端更大
            // 用户邮箱文本
            Text(
              email,
              textAlign: TextAlign.center, // 文本居中
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 24 : 20, // 桌面端字体更大
              ),
            ),
            SizedBox(height: isDesktop ? 32 : 24), // 动态间距，桌面端更大
            // 修改密码按钮
            SizedBox(
              width: isDesktop ? 300 : 200, // 桌面端按钮更宽
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_reset), // 重置密码图标
                label: const Text("修改密码"), // 按钮文本
                onPressed: _isLoading ? null : _showChangePasswordDialog, // 点击显示对话框，加载时禁用
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700], // 深蓝色背景
                  foregroundColor: Colors.white, // 白色文字和图标
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16.0 : 14.0), // 动态内边距
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // 圆角
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 16), // 动态间距，桌面端更大
            // 退出登录按钮
            SizedBox(
              width: isDesktop ? 300 : 200, // 桌面端按钮更宽
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout), // 退出图标
                label: const Text("退出登录"), // 按钮文本
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600], // 柔和红色背景
                  foregroundColor: Colors.white, // 白色文字和图标
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 16.0 : 14.0), // 动态内边距
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // 圆角
                ),
                onPressed: _isLoading ? null : _logout, // 点击执行退出，加载时禁用
              ),
            ),
          ],
        ),
      ),
    );
  }
}
