import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/subscription_plan.dart';
import 'package:fl_clash/models/coupon.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class CheckoutPage extends StatefulWidget {
  final SubscriptionPlan plan;
  final SubscriptionPeriod initialPeriod;

  const CheckoutPage({
    super.key,
    required this.plan,
    required this.initialPeriod,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _couponController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SubscriptionPeriod? _selectedPeriod;
  Coupon? _appliedCoupon;
  bool _isValidatingCoupon = false;
  bool _isCreatingOrder = false;
  String? _couponError;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  int? get _currentPrice {
    if (_selectedPeriod == null) return null;
    return _selectedPeriod!.getPrice(widget.plan);
  }

  String get _periodKey {
    return _selectedPeriod!.priceField;
  }

  int get _finalPrice {
    if (_currentPrice == null) return 0;
    if (_appliedCoupon == null) return _currentPrice!;

    switch (_appliedCoupon!.type) {
      case CouponType.fixedAmount:
        return (_currentPrice! - _appliedCoupon!.value).clamp(0, _currentPrice!);
      case CouponType.percentage:
        // value 是百分比数值，如 value=20 表示 20%
        final discount = (_currentPrice! * _appliedCoupon!.value / 100).round();
        return (_currentPrice! - discount).clamp(0, _currentPrice!);
    }
  }

  String _getPeriodName(SubscriptionPeriod period) {
    return period.label;
  }

  Future<void> _validateCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      setState(() {
        _appliedCoupon = null;
        _couponError = null;
      });
      return;
    }

    setState(() {
      _isValidatingCoupon = true;
      _couponError = null;
    });

    try {
      final coupon = await _authService.checkCoupon(
        code: _couponController.text.trim(),
        planId: widget.plan.id,
      );

      setState(() {
        _appliedCoupon = coupon;
        _isValidatingCoupon = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('优惠码验证成功：${coupon.formattedValue}优惠'),
          backgroundColor: TechTheme.neonGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _appliedCoupon = null;
        _couponError = e.toString().replaceFirst('Exception: ', '');
        _isValidatingCoupon = false;
      });
    }
  }

  Future<void> _createOrder() async {
    if (_currentPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择订阅周期'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final orderNo = await _authService.createOrder(
        period: _periodKey,
        planId: widget.plan.id,
        couponCode: _appliedCoupon?.code,
      );

      if (mounted) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('订单创建成功！订单号：$orderNo'),
            backgroundColor: TechTheme.neonGreen,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '复制',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: orderNo));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('订单号已复制'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );

        // 返回到上一页面
        Navigator.of(context).pop();
        
        // 如果需要，可以导航到订单详情页面
        // Navigator.pushNamed(context, '/order_center');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建订单失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: TechTheme.neonOrange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPeriods = SubscriptionPeriod.getAvailablePeriods(widget.plan)
      ..sort((a, b) => _getPeriodSortOrder(a).compareTo(_getPeriodSortOrder(b)));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '确认订单',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 套餐信息
                TechTheme.techCard(
                  animated: true,
                  accentColor: TechTheme.primaryCyan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '套餐信息',
                        style: TechTheme.techTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TechTheme.primaryCyan,
                          glowing: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.plan.name,
                        style: TechTheme.techTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '流量: ${widget.plan.formattedTraffic}/月',
                        style: TechTheme.techTextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 订阅周期选择
                TechTheme.techCard(
                  animated: true,
                  accentColor: TechTheme.primaryPurple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '选择订阅周期',
                        style: TechTheme.techTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TechTheme.primaryPurple,
                          glowing: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: sortedPeriods.map((period) {
                          final price = period.getPrice(widget.plan);
                          if (price == null || price <= 0) return const SizedBox.shrink();

                          return FilterChip(
                            label: Text(
                              '${_getPeriodName(period)} (¥${widget.plan.formatPrice(price)})',
                              style: TechTheme.techTextStyle(
                                fontSize: 12,
                                color: _selectedPeriod == period ? TechTheme.darkBackground : Colors.white,
                              ),
                            ),
                            selected: _selectedPeriod == period,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedPeriod = period;
                                  // 清除优惠码，因为周期变化可能影响优惠码有效性
                                  _appliedCoupon = null;
                                  _couponError = null;
                                });
                              }
                            },
                            backgroundColor: TechTheme.cardBackground,
                            selectedColor: TechTheme.primaryPurple,
                            checkmarkColor: TechTheme.darkBackground,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedPeriod == period ? TechTheme.primaryPurple : Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 优惠码
                TechTheme.techCard(
                  animated: true,
                  accentColor: TechTheme.neonOrange,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '优惠码（可选）',
                        style: TechTheme.techTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TechTheme.neonOrange,
                          glowing: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                labelText: '优惠码',
                                hintText: '请输入优惠码',
                                prefixIcon: const Icon(Icons.local_offer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorText: _couponError,
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _validateCoupon(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isValidatingCoupon ? null : _validateCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TechTheme.neonOrange,
                              foregroundColor: TechTheme.darkBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isValidatingCoupon
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('验证'),
                          ),
                        ],
                      ),
                      if (_appliedCoupon != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TechTheme.neonGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TechTheme.neonGreen, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: TechTheme.neonGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_appliedCoupon!.name} - ${_appliedCoupon!.formattedValue}优惠',
                                  style: TechTheme.techTextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _appliedCoupon = null;
                                    _couponController.clear();
                                    _couponError = null;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: TechTheme.neonOrange,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 价格汇总
                TechTheme.techCard(
                  animated: true,
                  accentColor: TechTheme.neonGreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '价格明细',
                        style: TechTheme.techTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TechTheme.neonGreen,
                          glowing: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_currentPrice != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '套餐价格：',
                              style: TechTheme.techTextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              widget.plan.formatPrice(_currentPrice!),
                              style: TechTheme.techTextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (_appliedCoupon != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '优惠金额：',
                                style: TechTheme.techTextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                '-${widget.plan.formatPrice(_currentPrice! - _finalPrice)}',
                                style: TechTheme.techTextStyle(
                                  fontSize: 14,
                                  color: TechTheme.neonOrange,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(color: Colors.white30, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '实付金额：',
                              style: TechTheme.techTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.plan.formatPrice(_finalPrice),
                              style: TechTheme.techTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TechTheme.neonGreen,
                                glowing: true,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          '请先选择订阅周期',
                          style: TechTheme.techTextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 提交按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreatingOrder || _currentPrice == null ? null : () => _createOrder(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TechTheme.neonGreen,
                      foregroundColor: TechTheme.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isCreatingOrder ? '创建订单中...' : '确认下单',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getPeriodSortOrder(SubscriptionPeriod period) {
    switch (period) {
      case SubscriptionPeriod.month: return 1;
      case SubscriptionPeriod.quarter: return 2;
      case SubscriptionPeriod.halfYear: return 3;
      case SubscriptionPeriod.year: return 4;
      case SubscriptionPeriod.twoYear: return 5;
      case SubscriptionPeriod.threeYear: return 6;
      case SubscriptionPeriod.onetime: return 7;
    }
  }
}
