import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../services/auth_service.dart';
import '../common/tech_theme.dart';
import '../widgets/tech_page_wrapper.dart';

class PaymentPage extends StatefulWidget {
  final Order order;
  final SubscriptionPlan plan;
  final int? discountAmount;

  const PaymentPage({
    super.key,
    required this.order,
    required this.plan,
    this.discountAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final AuthService _authService = AuthService();

  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  PaymentResult? _paymentResult;
  
  bool _isLoadingPaymentMethods = true;
  bool _isProcessingPayment = false;
  bool _isCancellingOrder = false;
  String? _error;

  // 订单状态轮询相关
  Timer? _statusCheckTimer;
  OrderCheckStatus _currentOrderStatus = OrderCheckStatus.pending;
  bool _isOrderCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _startOrderStatusPolling();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      setState(() {
        _isLoadingPaymentMethods = true;
        _error = null;
      });

      final methods = await _authService.getPaymentMethods();
      
      setState(() {
        _paymentMethods = methods;
        _selectedPaymentMethod = methods.isNotEmpty ? methods.first : null;
        _isLoadingPaymentMethods = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoadingPaymentMethods = false;
      });
    }
  }

  // 开始订单状态轮询
  void _startOrderStatusPolling() {
    // 立即检查一次状态
    _checkOrderStatus();
    
    // 每5秒检查一次订单状态
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isOrderCompleted) {
        timer.cancel();
        return;
      }
      _checkOrderStatus();
    });
  }

  // 检查订单状态
  Future<void> _checkOrderStatus() async {
    try {
      final status = await _authService.checkOrderStatus(widget.order.tradeNo);
      
      if (mounted) {
        setState(() {
          _currentOrderStatus = status;
        });

        // 根据状态处理
        switch (status) {
          case OrderCheckStatus.completed:
          case OrderCheckStatus.cancelled:
          case OrderCheckStatus.refunded:
            // 订单已完成或取消，停止轮询
            _isOrderCompleted = true;
            _statusCheckTimer?.cancel();
            
            if (status == OrderCheckStatus.completed) {
              // 支付成功，显示成功提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('订单支付成功！'),
                  backgroundColor: TechTheme.neonGreen,
                  action: SnackBarAction(
                    label: '查看订单',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/order_center');
                    },
                  ),
                ),
              );
            } else if (status == OrderCheckStatus.cancelled) {
              // 订单已取消
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('订单已取消'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            break;
          case OrderCheckStatus.processing:
            // 订单处理中，继续轮询
            break;
          case OrderCheckStatus.pending:
          default:
            // 待支付状态，继续轮询
            break;
        }
      }
    } catch (e) {
      // 静默处理错误，避免频繁弹出错误提示
      if (mounted) {
        print('检查订单状态失败：${e.toString()}');
      }
    }
  }

  // 关闭订单
  Future<void> _cancelOrder() async {
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
        content: Text(
          '确定要关闭此订单吗？关闭后将无法继续支付。',
          style: TechTheme.techTextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
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
        _isCancellingOrder = true;
      });

      await _authService.cancelOrder(widget.order.tradeNo);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('关闭订单成功'),
            backgroundColor: Colors.green,
          ),
        );

        // 停止状态轮询
        _statusCheckTimer?.cancel();
        _isOrderCompleted = true;

        // 返回上一页面
        Navigator.of(context).pop();
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
          _isCancellingOrder = false;
        });
      }
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择支付方式'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isProcessingPayment = true;
        _error = null;
      });

      final result = await _authService.checkoutOrder(
        tradeNo: widget.order.tradeNo,
        methodId: _selectedPaymentMethod!.id,
      );

      setState(() {
        _paymentResult = result;
        _isProcessingPayment = false;
      });

      // 处理订单已完成的情况
      if (result.type == PaymentResultType.completed) {
        if (result.completed == true) {
          // 停止状态轮询，因为订单已经完成
          _statusCheckTimer?.cancel();
          _isOrderCompleted = true;
          
          // 显示支付成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('订单支付成功！优惠码已全额抵扣'),
              backgroundColor: TechTheme.neonGreen,
              action: SnackBarAction(
                label: '查看订单',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/order_center');
                },
              ),
            ),
          );
        } else {
          // 支付失败
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('订单处理失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isProcessingPayment = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('支付处理失败：$_error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyTradeNo() async {
    await Clipboard.setData(ClipboardData(text: widget.order.tradeNo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('订单号已复制到剪贴板'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _openPaymentUrl() async {
    if (_paymentResult?.type == PaymentResultType.url && _paymentResult!.data != null) {
      final url = Uri.parse(_paymentResult!.data!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法打开支付链接'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String get _periodText {
    switch (widget.order.period) {
      case 'month_price':
        return '月付';
      case 'quarter_price':
        return '季付';
      case 'half_year_price':
        return '半年付';
      case 'year_price':
        return '年付';
      case 'two_year_price':
        return '两年付';
      case 'three_year_price':
        return '三年付';
      default:
        return '未知周期';
    }
  }

  Widget _buildOrderInfo() {
    return TechTheme.techCard(
      animated: true,
      accentColor: TechTheme.primaryCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '订单信息',
            style: TechTheme.techTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TechTheme.primaryCyan,
              glowing: true,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('套餐名称', widget.plan.name),
          _buildInfoRow('订阅周期', _periodText),
          _buildInfoRow('流量额度', widget.plan.formattedTraffic),
          
          _buildInfoRowWithCopy(
            '订单号', 
            widget.order.tradeNo,
            onCopy: _copyTradeNo,
          ),
          
          _buildInfoRow(
            '订单金额', 
            '¥${(widget.order.totalAmount / 100).toStringAsFixed(2)}',
          ),
          
          if (widget.discountAmount != null && widget.discountAmount! > 0)
            _buildInfoRow(
              '优惠金额',
              '-¥${(widget.discountAmount! / 100).toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          
          _buildInfoRow(
            '实付金额',
            '¥${((widget.order.totalAmount - (widget.discountAmount ?? 0)) / 100).toStringAsFixed(2)}',
            valueColor: TechTheme.neonGreen,
          ),
          
          _buildInfoRow('创建时间', widget.order.formattedCreatedAt),
          
          _buildInfoRow(
            '订单状态',
            _currentOrderStatus.statusText,
            valueColor: _currentOrderStatus.statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.white,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithCopy(String label, String value, {VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
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
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 16),
              color: TechTheme.primaryCyan,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    if (_isLoadingPaymentMethods) {
      return TechTheme.techCard(
        animated: true,
        accentColor: TechTheme.primaryCyan,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_paymentMethods.isEmpty) {
      return TechTheme.techCard(
        animated: true,
        accentColor: Colors.red,
        child: Column(
          children: [
            Text(
              '支付方式',
              style: TechTheme.techTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                glowing: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无可用的支付方式',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return TechTheme.techCard(
      animated: true,
      accentColor: TechTheme.primaryCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择支付方式',
            style: TechTheme.techTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TechTheme.primaryCyan,
              glowing: true,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._paymentMethods.map((method) => _buildPaymentMethodItem(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod?.id == method.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? TechTheme.neonGreen : Colors.white.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected 
                ? TechTheme.neonGreen.withOpacity(0.1)
                : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? TechTheme.neonGreen : Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: TechTheme.techTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? TechTheme.neonGreen : Colors.white,
                        ),
                      ),
                      Text(
                        method.payment,
                        style: TechTheme.techTextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      if (method.hasHandlingFee)
                        Text(
                          method.formattedHandlingFee,
                          style: TechTheme.techTextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentResult() {
    if (_paymentResult == null) return const SizedBox.shrink();

    return TechTheme.techCard(
      animated: true,
      accentColor: TechTheme.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付信息',
            style: TechTheme.techTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TechTheme.neonGreen,
              glowing: true,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_paymentResult!.type == PaymentResultType.completed) ...[
            // 订单已完成支付
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TechTheme.neonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TechTheme.neonGreen,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: TechTheme.neonGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '支付成功！',
                    style: TechTheme.techTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TechTheme.neonGreen,
                      glowing: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '优惠码已全额抵扣订单金额',
                    style: TechTheme.techTextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '订单已自动激活，请稍等片刻后刷新',
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TechTheme.techButton(
                      text: '查看订单',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/order_center');
                      },
                      color: TechTheme.neonGreen,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_paymentResult!.type == PaymentResultType.qrcode && _paymentResult!.data != null) ...[
            Text(
              '请使用${_selectedPaymentMethod?.name}扫描二维码支付',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: _paymentResult!.data!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
          ] else if (_paymentResult!.type == PaymentResultType.url) ...[
            Text(
              '点击下方按钮跳转到支付页面',
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TechTheme.techButton(
                text: '跳转支付',
                onPressed: _openPaymentUrl,
                color: TechTheme.neonGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          '订单支付',
          style: TechTheme.techTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            glowing: true,
          ),
        ),
        backgroundColor: TechTheme.darkBackground,
        foregroundColor: Colors.white,
      ),
      body: TechPageWrapper(
        showAppBar: false,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo(),
              const SizedBox(height: 16),
              
              _buildPaymentMethods(),
              const SizedBox(height: 16),
              
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _error!,
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              _buildPaymentResult(),
              const SizedBox(height: 16),
              
              // 只有在订单未完成且未处理过支付时显示支付按钮
              if (_paymentResult == null && _paymentMethods.isNotEmpty && !_isOrderCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: TechTheme.techButton(
                    text: _isProcessingPayment ? '处理中...' : '立即支付',
                    onPressed: _isProcessingPayment ? () {} : () => _processPayment(),
                    color: TechTheme.neonGreen,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // 关闭订单按钮 - 只有在待支付状态且未完成时显示
              if (_currentOrderStatus == OrderCheckStatus.pending && 
                  !_isOrderCompleted && 
                  (_paymentResult == null || _paymentResult!.type != PaymentResultType.completed)) ...[
                SizedBox(
                  width: double.infinity,
                  child: TechTheme.techButton(
                    text: _isCancellingOrder ? '关闭中...' : '关闭订单',
                    onPressed: _isCancellingOrder ? () {} : () => _cancelOrder(),
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
