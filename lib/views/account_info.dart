import 'package:flutter/material.dart';
import 'package:fl_clash/services/api_service_v2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/pages/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/tools.dart';
import 'dart:io';

class AccountInfoPage extends ConsumerStatefulWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends ConsumerState<AccountInfoPage> {
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _subscriptionInfo;
  bool _isLoading = true;
  String? _errorMessage;
  int _emailClickCount = 0;
  bool _showToolsSection = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    print('AccountInfoPage: Starting _fetchData');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final apiService = ApiServiceV2();
    try {
      print('AccountInfoPage: Calling getUserInfo');
      final userInfo = await apiService.getUserInfo();
      print('AccountInfoPage: getUserInfo success: $userInfo');
      
      print('AccountInfoPage: Calling getSubscriptionInfo');
      final subscriptionInfo = await apiService.getSubscriptionInfo();
      print('AccountInfoPage: getSubscriptionInfo success: $subscriptionInfo');
      
      if (mounted) {
      setState(() {
        _userInfo = userInfo;
        _subscriptionInfo = subscriptionInfo;
        _isLoading = false;
      });
        print('AccountInfoPage: State updated successfully');
      }
    } catch (e) {
      print('AccountInfoPage: Error fetching data: $e');
      if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      }
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '未知';
    final utcTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    final chineseTime = utcTime.add(const Duration(hours: 8));
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(chineseTime);
  }

  String _formatTraffic(num? bytes) {
    if (bytes == null) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var index = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }
    return '${size.toStringAsFixed(2)} ${units[index]}';
  }

  void _handleEmailClick() {
    setState(() {
      _emailClickCount++;
      if (_emailClickCount >= 15) {
        _showToolsSection = !_showToolsSection;
        _emailClickCount = 0; // 重置计数
        
        // 显示提示信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_showToolsSection ? '工具页面已显示' : '工具页面已隐藏'),
            backgroundColor: const Color(0xFF00D9FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('AccountInfoPage: Building widget - loading: $_isLoading, error: $_errorMessage, userInfo: ${_userInfo != null}');
    
    // 简化版本测试 - 使用基础Scaffold
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27), // 深蓝黑色背景
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
                  ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '加载账户信息...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A3C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Color(0xFFFF6B35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!.contains('未登录') ? '请先登录' : '加载失败',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_errorMessage!.contains('未登录')) ...[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FF88),
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('去登录'),
                              ),
                              const SizedBox(width: 16),
                            ],
                            ElevatedButton(
                          onPressed: _fetchData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  color: const Color(0xFF00D9FF),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 基本信息卡片
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A3C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF00D9FF),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '账户信息',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D9FF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('邮箱', _userInfo?['email'] ?? '未知', clickable: true, onTap: _handleEmailClick),
                              _buildInfoRow('余额', '¥${_userInfo?['balance'] ?? '0'}'),
                              _buildExpireTimeRow(),
                            ],
                          ),
                        ),
                        
                        // 订阅信息卡片
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A3C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '订阅信息',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('套餐名称', _subscriptionInfo?['plan']?['name'] ?? '未知'),
                              _buildInfoRow('上传流量', _formatTraffic(_subscriptionInfo?['u'])),
                              _buildInfoRow('下载流量', _formatTraffic(_subscriptionInfo?['d'])),
                              _buildInfoRow('总流量', _formatTraffic(_subscriptionInfo?['transfer_enable'])),
                            ],
                          ),
                        ),
                        
                        // 服务中心卡片
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A3C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF00FF88),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '服务中心',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00FF88),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildServiceItem('订购中心', Icons.shopping_cart, '/subscription_store'),
                              _buildServiceItem('订单中心', Icons.receipt_long, '/order_center'),
                              _buildServiceItem('工单中心', Icons.support_agent, '/ticket_list'),
                              _buildServiceItem('我的邀请', Icons.person_add, '/invite'),
                              _buildServiceItem('流量明细', Icons.analytics, '/traffic_log'),
                            ],
                          ),
                        ),
                        
                        // 设置区域
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A3C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '应用设置',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingItem('主题设置', Icons.palette, () {
                                _showThemeDialog();
                              }),
                              _buildSettingItem('访问控制', Icons.security, () {
                                _showAccessDialog();
                              }),
                              _buildSettingItem('退出登录', Icons.logout, () {
                                _showLogoutDialog();
                              }),
                            ],
                          ),
                        ),
                        
                        // 工具页面（隐藏，需要点击邮箱15次激活）
                        if (_showToolsSection) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141A3C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '开发者工具',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSettingItem('网络日志', Icons.network_check, () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('网络日志功能')),
                                  );
                                }),
                                _buildSettingItem('调试信息', Icons.bug_report, () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('调试信息功能')),
                                  );
                                }),
                                _buildSettingItem('性能监控', Icons.speed, () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('性能监控功能')),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool clickable = false, VoidCallback? onTap}) {
    Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (clickable) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.touch_app,
                  size: 16,
                  color: Color(0xFF00D9FF),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (clickable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00D9FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: row,
        ),
      );
    }

    return row;
  }

  Widget _buildExpireTimeRow() {
    final expiredAt = _userInfo?['expired_at'];
    final expireText = _formatDate(expiredAt);
    
    // 检查是否过期
    final isExpired = expiredAt != null && 
        DateTime.fromMillisecondsSinceEpoch(expiredAt * 1000, isUtc: true)
            .add(const Duration(hours: 8)) // 转换为东8区
            .isBefore(DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '过期时间',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  expireText,
                  style: TextStyle(
                    color: isExpired ? Colors.red : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isExpired) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/subscription_store');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00FF88),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '续费',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
              color: const Color(0xFF00FF88).withOpacity(0.3),
                width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF00FF88),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
                  size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A3C),
          title: const Text(
            '主题设置',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6, color: Color(0xFF3B82F6)),
                title: const Text('跟随系统', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已设置为跟随系统主题')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode, color: Color(0xFF3B82F6)),
                title: const Text('浅色模式', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已设置为浅色模式')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Color(0xFF3B82F6)),
                title: const Text('深色模式', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已设置为深色模式')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A3C),
          title: const Text(
            '访问控制',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.vpn_key, color: Color(0xFF3B82F6)),
                title: const Text('系统代理', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('系统代理设置')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.network_check, color: Color(0xFF3B82F6)),
                title: const Text('TUN模式', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('TUN模式设置')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.security, color: Color(0xFF3B82F6)),
                title: const Text('DNS设置', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DNS设置')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A3C),
          title: const Text(
            '退出登录',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '确定要退出登录吗？',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '取消',
                style: TextStyle(color: Color(0xFF3B82F6)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // 清除本地存储的登录信息
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                await prefs.remove('auth_data');
                await prefs.remove('user_email');
                await prefs.setBool('is_logged_in', false);
                
                // 跳转到登录页面
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}