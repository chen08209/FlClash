import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/order.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class OrderCenterPage extends StatefulWidget {
  const OrderCenterPage({super.key});

  @override
  State<OrderCenterPage> createState() => _OrderCenterPageState();
}

class _OrderCenterPageState extends State<OrderCenterPage> {
  final AuthService _authService = AuthService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _cancellingOrders = {}; // 正在取消的订单号集合

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 确保AuthService已初始化
      await _authService.initialize();
      final orders = await _authService.getOrderList();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _copyTradeNo(String tradeNo) {
    Clipboard.setData(ClipboardData(text: tradeNo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('订单号已复制: $tradeNo'),
        backgroundColor: TechTheme.primaryCyan,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showOrderDetails(Order order) async {
    // 显示加载弹窗
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TechTheme.cardBackground,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryCyan),
              ),
              const SizedBox(height: 16),
              Text(
                '正在加载订单详情...',
                style: TechTheme.techTextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // 确保AuthService已初始化
      await _authService.initialize();
      // 获取订单详情
      final detailOrder = await _authService.getOrderDetail(order.tradeNo);
      
      // 关闭加载弹窗
      if (mounted) {
        Navigator.of(context).pop();
        
        // 显示详情弹窗
        _showOrderDetailDialog(detailOrder);
      }
    } catch (e) {
      // 关闭加载弹窗
      if (mounted) {
        Navigator.of(context).pop();
        
        // 显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取订单详情失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: TechTheme.neonOrange,
          ),
        );
      }
    }
  }

  void _showOrderDetailDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TechTheme.cardBackground,
          title: Text(
            '订单详情',
            style: TechTheme.techTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TechTheme.primaryCyan,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('订单号', order.tradeNo),
                  _buildDetailRow('套餐名称', order.plan?.name ?? '未知套餐'),
                  _buildDetailRow('订单类型', order.typeText),
                  _buildDetailRow('订阅周期', order.periodText),
                  _buildDetailRow('订单状态', order.statusText),
                  _buildDetailRow('支付金额', order.formatPrice(order.totalAmount)),
                  // 条件显示可选金额字段
                  if (order.shouldShowBalanceAmount)
                    _buildDetailRow('余额支付', order.formatPrice(order.balanceAmount)),
                  if (order.discountAmount != null && order.discountAmount! > 0)
                    _buildDetailRow('折抵金额', order.formatPrice(order.discountAmount)),
                  if (order.refundAmount != null && order.refundAmount! > 0)
                    _buildDetailRow('退回金额', order.formatPrice(order.refundAmount)),
                  if (order.surplusAmount != null && order.surplusAmount! > 0)
                    _buildDetailRow('余额', order.formatPrice(order.surplusAmount)),
                  _buildDetailRow('创建时间', order.formattedCreatedAt),
                  _buildDetailRow('更新时间', order.formattedUpdatedAt),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '关闭',
                style: TechTheme.techTextStyle(color: TechTheme.primaryCyan),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '订单中心',
          style: TechTheme.techTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            glowing: true,
          ),
        ),
        centerTitle: true,
        backgroundColor: TechTheme.darkBackground,
        foregroundColor: Colors.white,
      ),
      body: TechPageWrapper(
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
                            onPressed: _fetchOrders,
                            color: TechTheme.neonOrange,
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    color: TechTheme.primaryCyan,
                    child: _orders.isEmpty
                        ? Center(
                            child: TechTheme.techCard(
                              animated: true,
                              accentColor: TechTheme.primaryPurple,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: TechTheme.primaryPurple,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '暂无订单',
                                    style: TechTheme.techTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '您还没有任何订单记录',
                                    textAlign: TextAlign.center,
                                    style: TechTheme.techTextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              return _buildOrderCard(order);
                            },
                          ),
                  ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.processing:
        statusColor = Colors.blue;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
      case OrderStatus.completed:
        statusColor = Colors.green;
        break;
      case OrderStatus.discounted:
        statusColor = Colors.purple;
        break;
    }

    return TechTheme.techCard(
      animated: true,
      accentColor: TechTheme.primaryCyan,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单号和状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _copyTradeNo(order.tradeNo),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt,
                            size: 16,
                            color: TechTheme.primaryCyan,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.tradeNo,
                              style: TechTheme.techTextStyle(
                                fontSize: 14,
                                color: TechTheme.primaryCyan,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.copy,
                            size: 14,
                            color: TechTheme.primaryCyan.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      order.statusText,
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 套餐名称
              Text(
                order.plan?.name ?? '未知套餐',
                style: TechTheme.techTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // 订单类型和周期
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: TechTheme.primaryPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TechTheme.primaryPurple, width: 1),
                    ),
                    child: Text(
                      order.typeText,
                      style: TechTheme.techTextStyle(
                        fontSize: 10,
                        color: TechTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: TechTheme.neonGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TechTheme.neonGreen, width: 1),
                    ),
                    child: Text(
                      order.periodText,
                      style: TechTheme.techTextStyle(
                        fontSize: 10,
                        color: TechTheme.neonGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 金额和时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '支付金额',
                        style: TechTheme.techTextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        order.formatPrice(order.totalAmount),
                        style: TechTheme.techTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TechTheme.neonOrange,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '创建时间',
                        style: TechTheme.techTextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        order.formattedCreatedAt,
                        style: TechTheme.techTextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 余额支付（如果有）
              if (order.shouldShowBalanceAmount) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: TechTheme.primaryCyan,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '余额支付: ${order.formatPrice(order.balanceAmount)}',
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: TechTheme.primaryCyan,
                      ),
                    ),
                  ],
                ),
              ],
              
              // 未支付订单的操作按钮
              if (order.status == OrderStatus.pending) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TechTheme.techButton(
                        text: '立即支付',
                        onPressed: () => _navigateToPayment(order),
                        color: TechTheme.neonGreen,
                        height: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TechTheme.techButton(
                        text: _cancellingOrders.contains(order.tradeNo) ? '关闭中...' : '关闭订单',
                        onPressed: _cancellingOrders.contains(order.tradeNo) 
                            ? () {} 
                            : () => _cancelOrder(order),
                        color: Colors.red,
                        height: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 导航到支付页面
  Future<void> _navigateToPayment(Order order) async {
    try {
      // 确保AuthService已初始化
      await _authService.initialize();
      // 获取订单详情，确保有完整的套餐信息
      final orderDetail = await _authService.getOrderDetail(order.tradeNo);
      
      if (mounted && orderDetail.plan != null) {
        Navigator.pushNamed(
          context,
          '/payment',
          arguments: {
            'order': orderDetail,
            'plan': orderDetail.plan!,
            'discountAmount': orderDetail.discountAmount,
          },
        ).then((_) {
          // 从支付页面返回后刷新订单列表
          _fetchOrders();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('跳转支付页面失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 关闭订单
  Future<void> _cancelOrder(Order order) async {
    // 显示确认对话框
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TechTheme.darkBackground,
        title: Text(
          '确认关闭订单',
          style: TechTheme.techTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '订单号：${order.tradeNo}',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: TechTheme.primaryCyan,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '确定要关闭此订单吗？关闭后将无法继续支付。',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '取消',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              '确认关闭',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    try {
      setState(() {
        _cancellingOrders.add(order.tradeNo);
      });

      // 确保AuthService已初始化
      await _authService.initialize();
      await _authService.cancelOrder(order.tradeNo);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('订单 ${order.tradeNo} 关闭成功'),
            backgroundColor: Colors.green,
          ),
        );

        // 刷新订单列表
        await _fetchOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('关闭订单失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cancellingOrders.remove(order.tradeNo);
        });
      }
    }
  }
}
