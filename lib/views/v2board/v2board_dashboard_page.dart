import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/services/v2board/v2board_api_service.dart';
import 'package:fl_clash/services/v2board/models/v2board_models.dart';
import 'package:fl_clash/services/v2board/subscription_manager.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// V2Board 用户仪表板页面
class V2BoardDashboardPage extends ConsumerStatefulWidget {
  const V2BoardDashboardPage({super.key});

  @override
  ConsumerState<V2BoardDashboardPage> createState() => _V2BoardDashboardPageState();
}

class _V2BoardDashboardPageState extends ConsumerState<V2BoardDashboardPage> {
  V2BoardUser? _userInfo;
  List<V2BoardPlan>? _plans;
  bool _isLoading = true;
  String? _errorMessage;
  String? _subscriptionUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 并行加载用户信息和套餐信息
      final futures = await Future.wait([
        V2BoardApiService.instance.getUserInfo(),
        V2BoardApiService.instance.getPlans(),
        V2BoardApiService.instance.getClashSubscriptionUrl(),
      ]);

      final userResponse = futures[0] as V2BoardUserResponse;
      final plansResponse = futures[1] as V2BoardPlansResponse;
      final subscriptionUrl = futures[2] as String;

      if (userResponse.success && userResponse.data != null) {
        setState(() {
          _userInfo = userResponse.data;
          _plans = plansResponse.data ?? [];
          _subscriptionUrl = subscriptionUrl;
        });

        // 自动导入订阅
        await _importSubscription();
      } else {
        setState(() {
          _errorMessage = userResponse.message ?? 'Failed to load user data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importSubscription() async {
    if (_subscriptionUrl == null) return;

    try {
      commonPrint.log('Importing subscription: $_subscriptionUrl');

      // 使用订阅管理器导入订阅
      final success = await V2BoardSubscriptionManager.instance.importSubscriptionFromV2Board();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription imported successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import subscription')),
        );
      }
    } catch (e) {
      commonPrint.log('Failed to import subscription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import subscription: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  Future<void> _resetSubscription() async {
    try {
      // 使用订阅管理器重置订阅
      final success = await V2BoardSubscriptionManager.instance.resetV2BoardSubscription();

      if (success) {
        // 重新加载用户数据以获取新的订阅 URL
        await _loadUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription reset successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reset subscription')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset subscription: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await V2BoardApiService.instance.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/v2board/login');
      }
    } catch (e) {
      commonPrint.log('Logout error: $e');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatExpireDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V2Board Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'reset_subscription':
                  _resetSubscription();
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_subscription',
                child: Text('Reset Subscription'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: context.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 用户信息卡片
                      _buildUserInfoCard(),
                      const SizedBox(height: 16),
                      
                      // 流量使用情况
                      _buildTrafficCard(),
                      const SizedBox(height: 16),
                      
                      // 订阅信息
                      _buildSubscriptionCard(),
                      const SizedBox(height: 16),
                      
                      // 套餐信息
                      if (_plans?.isNotEmpty == true) ...[
                        _buildPlansCard(),
                        const SizedBox(height: 16),
                      ],
                      
                      // 操作按钮
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_userInfo == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: context.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'User Information',
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Email', _userInfo!.email ?? 'N/A'),
            _buildInfoRow('Plan', _userInfo!.planName ?? 'No Plan'),
            _buildInfoRow('Balance', '¥${(_userInfo!.balance ?? 0) / 100}'),
            if (_userInfo!.expiredAt != null)
              _buildInfoRow(
                'Expires',
                _formatExpireDate(_userInfo!.expiredAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficCard() {
    if (_userInfo == null) return const SizedBox.shrink();

    final totalTraffic = _userInfo!.transferEnable ?? 0;
    final usedTraffic = _userInfo!.usedTraffic;
    final remainingTraffic = _userInfo!.remainingTraffic;
    final usagePercent = totalTraffic > 0 ? usedTraffic / totalTraffic : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.data_usage, color: context.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Traffic Usage',
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: usagePercent,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used: ${_formatBytes(usedTraffic)}'),
                Text('${(usagePercent * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remaining: ${_formatBytes(remainingTraffic)}'),
                Text('Total: ${_formatBytes(totalTraffic)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key, color: context.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Subscription',
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_subscriptionUrl != null) ...[
              Text('Status: Active'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _importSubscription,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Update Subscription'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _resetSubscription,
                    icon: const Icon(Icons.reset_tv),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ] else
              const Text('No subscription available'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: context.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Available Plans',
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_plans ?? []).take(3).map((plan) => ListTile(
              title: Text(plan.name ?? 'Unknown Plan'),
              subtitle: Text('Traffic: ${_formatBytes(plan.transferEnable ?? 0)}'),
              trailing: Text('¥${(plan.monthPrice ?? 0) / 100}/month'),
              onTap: () => _showPurchaseDialog(plan),
            )),
            if ((_plans?.length ?? 0) > 3)
              TextButton(
                onPressed: () => _showAllPlans(),
                child: const Text('View All Plans'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showPurchaseWebView(),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Purchase / Renew'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showPurchaseDialog(V2BoardPlan plan) {
    // TODO: 实现购买对话框
  }

  void _showAllPlans() {
    // TODO: 显示所有套餐页面
  }

  void _showPurchaseWebView() {
    final baseUrl = V2BoardApiService.instance.baseUrl;
    if (baseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('V2Board URL not configured')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => V2BoardWebViewPage(
          url: '$baseUrl/#/plan',
          title: 'Purchase / Renew',
          onPaymentComplete: () async {
            // 支付完成后刷新用户数据
            await _refreshData();
          },
        ),
      ),
    );
  }
}

/// V2Board WebView 页面
class V2BoardWebViewPage extends StatefulWidget {
  final String url;
  final String title;
  final VoidCallback? onPaymentComplete;

  const V2BoardWebViewPage({
    super.key,
    required this.url,
    required this.title,
    this.onPaymentComplete,
  });

  @override
  State<V2BoardWebViewPage> createState() => _V2BoardWebViewPageState();
}

class _V2BoardWebViewPageState extends State<V2BoardWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // 检查是否是支付成功页面
            _checkPaymentSuccess(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            // 检查导航请求中的支付成功标识
            _checkPaymentSuccess(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkPaymentSuccess(String url) {
    // 检查 URL 中是否包含支付成功的标识
    if (url.contains('payment/success') ||
        url.contains('order/success') ||
        url.contains('success=true')) {

      // 延迟执行回调，确保页面加载完成
      Future.delayed(const Duration(seconds: 2), () {
        if (widget.onPaymentComplete != null && mounted) {
          widget.onPaymentComplete!();

          // 显示成功提示并返回
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment completed successfully!')),
          );

          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
