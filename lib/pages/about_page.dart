import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fl_clash/models/about_info.dart';
import 'package:fl_clash/services/api_service_v2.dart';

/// 关于页面
class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  List<AboutInfo> _aboutInfos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _appVersion = '';
  String _appName = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取应用信息
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _appName = packageInfo.appName;

      // 获取关于信息
      final apiService = ApiServiceV2();
      final aboutResponse = await apiService.getAboutInfo();

      if (aboutResponse.isSuccess) {
        if (mounted) {
          setState(() {
            _aboutInfos = aboutResponse.data;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(aboutResponse.message);
      }
    } catch (e) {
      print('AboutPage: 获取数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleItemTap(AboutInfo item) async {
    try {
      if (item.isEmail) {
        // 邮箱地址，复制到剪贴板并提示
        await Clipboard.setData(ClipboardData(text: item.value));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('邮箱地址已复制到剪贴板: ${item.value}'),
              backgroundColor: const Color(0xFF00D9FF),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (item.isLink) {
        // 链接，尝试打开
        final uri = Uri.parse(item.value);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('无法打开链接');
        }
      } else {
        // 普通文本，复制到剪贴板
        await Clipboard.setData(ClipboardData(text: item.value));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('内容已复制到剪贴板: ${item.value}'),
              backgroundColor: const Color(0xFF00D9FF),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAboutItem(AboutInfo item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleItemTap(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141A3C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00D9FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.displayIcon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // 操作提示
              Icon(
                item.isLink ? Icons.open_in_new : Icons.copy,
                color: const Color(0xFF00D9FF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          '关于',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF141A3C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
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
                      '加载中...',
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
                          const Text(
                            '加载失败',
                            style: TextStyle(
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
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    color: const Color(0xFF00D9FF),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 应用信息卡片
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141A3C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF00D9FF),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // 应用图标
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF00D9FF),
                                        Color(0xFF0099CC),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.router_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // 应用名称
                                Text(
                                  _appName.isNotEmpty ? _appName : 'FlClash',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00D9FF),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // 版本号
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00D9FF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'v$_appVersion',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF00D9FF),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // 应用描述
                                Text(
                                  '智能代理客户端',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 联系方式标题
                          const Text(
                            '联系方式',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D9FF),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 关于信息列表
                          ..._aboutInfos.map((item) => _buildAboutItem(item)),
                          
                          const SizedBox(height: 24),
                          
                          // 底部提示
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141A3C).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '点击链接可直接打开，点击邮箱或其他内容可复制到剪贴板',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
