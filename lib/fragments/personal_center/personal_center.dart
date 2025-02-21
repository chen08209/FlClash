import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/models/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalCenterFragment extends StatefulWidget {
  const PersonalCenterFragment({super.key});

  @override
  State<PersonalCenterFragment> createState() => _PersonalCenterFragmentState();
}

class _PersonalCenterFragmentState extends State<PersonalCenterFragment> {
  bool _isLoading = false;

  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      final config = Provider.of<Config>(context, listen: false);
      config.token = null;
      config.isAuthenticated = false;
      config.user = null;
      globalState.navigatorKey.currentState?.pushReplacementNamed('/auth') ??
          Navigator.of(context).pushReplacementNamed('/auth');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("退出失败: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword(String newPassword) async {
    final config = Provider.of<Config>(context, listen: false);
    if (config.token == null || config.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("未登录，无法修改密码")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${config.apiBaseUrl}/v1/auth/change_password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.token}',
        },
        body: jsonEncode({'password': newPassword}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("密码修改成功")));
        config.user = config.user!.copyWith(password: newPassword);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'] ?? "修改密码失败")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("错误: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("修改密码"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
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
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "确认密码",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final newPassword = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;
                    if (newPassword.isEmpty || confirmPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请填写所有字段")));
                      return;
                    }
                    if (newPassword != confirmPassword) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("两次输入的密码不一致")));
                      return;
                    }
                    Navigator.pop(context);
                    await _changePassword(newPassword);
                  },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                  )
                : const Text("确认修改"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<Config>(context);
    final email = config.user?.email ?? "未登录用户";

    return Scaffold(
      appBar: AppBar(
        title: const Text("个人中心"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.purple.shade100],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : "U",
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_reset),
                  label: const Text("修改密码"),
                  onPressed: _isLoading ? null : _showChangePasswordDialog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
