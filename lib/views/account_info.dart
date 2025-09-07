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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final apiService = ApiServiceV2();
    try {
      final userInfo = await apiService.getUserInfo();
      final subscriptionInfo = await apiService.getSubscriptionInfo();
      setState(() {
        _userInfo = userInfo;
        _subscriptionInfo = subscriptionInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
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
            backgroundColor: TechTheme.primaryCyan,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TechPageWrapper(
      showAppBar: false,
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryCyan),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: TechTheme.techCard(
                    animated: true,
                    accentColor: TechTheme.neonOrange,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: TechTheme.neonOrange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '加载失败',
                          style: TechTheme.techTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TechTheme.techTextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TechTheme.techButton(
                          text: '重试',
                          onPressed: _fetchData,
                          color: TechTheme.neonOrange,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  color: TechTheme.primaryCyan,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 基本信息卡片
                        TechTheme.techCard(
                          animated: true,
                          accentColor: TechTheme.primaryCyan,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '账户信息',
                                style: TechTheme.techTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: TechTheme.primaryCyan,
                                  glowing: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTechInfoRow(
                                Icons.email,
                                '邮箱',
                                _userInfo?['email'] ?? '未知',
                                onTap: _handleEmailClick,
                                clickable: true,
                              ),
                              _buildTechInfoRow(
                                Icons.access_time,
                                '过期时间',
                                _formatDate(_userInfo?['expired_at']),
                              ),
                              _buildTechInfoRow(
                                Icons.account_balance_wallet,
                                '余额',
                                '¥${_userInfo?['balance'] ?? '0'}',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 订阅信息卡片
                        TechTheme.techCard(
                          animated: true,
                          accentColor: TechTheme.primaryPurple,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '订阅信息',
                                style: TechTheme.techTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: TechTheme.primaryPurple,
                                  glowing: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTechInfoRow(
                                Icons.card_membership,
                                '套餐名称',
                                _subscriptionInfo?['plan']?['name'] ?? '未知',
                              ),
                              _buildTechInfoRow(
                                Icons.upload,
                                '上传流量',
                                _formatTraffic(_subscriptionInfo?['u']),
                              ),
                              _buildTechInfoRow(
                                Icons.download,
                                '下载流量',
                                _formatTraffic(_subscriptionInfo?['d']),
                              ),
                              _buildTechInfoRow(
                                Icons.data_usage,
                                '总流量',
                                _formatTraffic(_subscriptionInfo?['transfer_enable']),
                              ),
                              if (_subscriptionInfo != null && _subscriptionInfo!['transfer_enable'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: ((_subscriptionInfo!['u'] ?? 0) + (_subscriptionInfo!['d'] ?? 0)) / _subscriptionInfo!['transfer_enable'],
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: LinearGradient(
                                          colors: [
                                            TechTheme.primaryPurple,
                                            TechTheme.primaryCyan,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 功能服务卡片
                        TechTheme.techCard(
                          animated: true,
                          accentColor: TechTheme.neonGreen,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '服务中心',
                                style: TechTheme.techTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: TechTheme.neonGreen,
                                  glowing: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTechServiceItem(
                                Icons.shopping_cart, 
                                '订购中心', 
                                TechTheme.primaryBlue,
                                onTap: () {
                                  Navigator.pushNamed(context, '/subscription_store');
                                },
                              ),
                              _buildTechServiceItem(
                                Icons.receipt_long, 
                                '订单中心', 
                                TechTheme.primaryPurple,
                                onTap: () {
                                  Navigator.pushNamed(context, '/order_center');
                                },
                              ),
                              _buildTechServiceItem(
                                Icons.support_agent, 
                                '工单中心', 
                                TechTheme.neonYellow,
                                onTap: () {
                                  Navigator.pushNamed(context, '/ticket_list');
                                },
                              ),
                              _buildTechServiceItem(
                                Icons.analytics, 
                                '流量明细', 
                                TechTheme.neonPink,
                                onTap: () {
                                  Navigator.pushNamed(context, '/traffic_log');
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 设置卡片
                        TechTheme.techCard(
                          animated: true,
                          accentColor: TechTheme.primaryBlue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '设置',
                                style: TechTheme.techTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: TechTheme.primaryBlue,
                                  glowing: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _TechLocaleItem(),
                              const SizedBox(height: 12),
                              _TechThemeItem(),
                              if (Platform.isAndroid) ...[
                                const SizedBox(height: 12),
                                _TechAccessItem(),
                              ],
                            ],
                          ),
                        ),
                        
                        // 工具页面 (条件显示)
                        if (_showToolsSection) ...[
                          const SizedBox(height: 16),
                          TechTheme.techCard(
                            animated: true,
                            accentColor: TechTheme.neonOrange,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.construction,
                                      color: TechTheme.neonOrange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '开发者工具',
                                      style: TechTheme.techTextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: TechTheme.neonOrange,
                                        glowing: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TechTheme.techButton(
                                  text: '打开工具页面',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: const Text('开发者工具'),
                                            backgroundColor: TechTheme.darkBackground,
                                            foregroundColor: Colors.white,
                                          ),
                                          body: const ToolsView(),
                                        ),
                                      ),
                                    );
                                  },
                                  color: TechTheme.neonOrange,
                                  width: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // 退出账户
                        TechTheme.techCard(
                          animated: true,
                          accentColor: TechTheme.neonOrange,
                          child: Row(
                            children: [
                              Icon(
                                Icons.exit_to_app,
                                color: TechTheme.neonOrange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '退出账户',
                                  style: TechTheme.techTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                            ],
                          ),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTechInfoRow(
    IconData icon, 
    String label, 
    String value, {
    VoidCallback? onTap,
    bool clickable = false,
  }) {
    Widget row = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: clickable 
            ? TechTheme.primaryCyan.withOpacity(0.1)
            : Colors.transparent,
        border: clickable 
            ? Border.all(
                color: TechTheme.primaryCyan.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TechTheme.primaryCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: TechTheme.primaryCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TechTheme.techTextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          if (clickable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.touch_app,
              size: 16,
              color: TechTheme.primaryCyan.withOpacity(0.7),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: row,
      );
    }
    return row;
  }

  Widget _buildTechServiceItem(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TechTheme.techTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TechLocaleItem extends ConsumerWidget {
  const _TechLocaleItem();

  String _getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appSettingProvider.select((state) => state.locale));
    final subTitle = locale ?? appLocalizations.defaultText;
    final currentLocale = utils.getLocaleForString(locale);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TechTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // 显示语言选择对话框
            showDialog<Locale?>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: TechTheme.cardBackground,
                title: Text(
                  appLocalizations.language,
                  style: TechTheme.techTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TechTheme.primaryBlue,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in [null, ...AppLocalizations.delegate.supportedLocales])
                      ListTile(
                        title: Text(
                          _getLocaleString(option),
                          style: TechTheme.techTextStyle(
                            color: Colors.white,
                          ),
                        ),
                        selected: option == currentLocale,
                        selectedColor: TechTheme.primaryBlue,
                        onTap: () {
                          ref.read(appSettingProvider.notifier).updateState(
                                (state) => state.copyWith(locale: option?.toString()),
                              );
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TechTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language_outlined,
                  size: 20,
                  color: TechTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.language,
                      style: TechTheme.techTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      Intl.message(subTitle),
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechThemeItem extends StatelessWidget {
  const _TechThemeItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TechTheme.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(appLocalizations.theme),
                    backgroundColor: TechTheme.darkBackground,
                    foregroundColor: Colors.white,
                  ),
                  body: const ThemeView(),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TechTheme.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.style,
                  size: 20,
                  color: TechTheme.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.theme,
                      style: TechTheme.techTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      appLocalizations.themeDesc,
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechAccessItem extends StatelessWidget {
  const _TechAccessItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TechTheme.neonGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(appLocalizations.appAccessControl),
                    backgroundColor: TechTheme.darkBackground,
                    foregroundColor: Colors.white,
                  ),
                  body: const AccessView(),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TechTheme.neonGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.view_list,
                  size: 20,
                  color: TechTheme.neonGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.accessControl,
                      style: TechTheme.techTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      appLocalizations.accessControlDesc,
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

