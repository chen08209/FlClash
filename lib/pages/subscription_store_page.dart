import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/subscription_plan.dart';
import 'package:fl_clash/pages/checkout_page.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class SubscriptionStorePage extends StatefulWidget {
  const SubscriptionStorePage({super.key});

  @override
  State<SubscriptionStorePage> createState() => _SubscriptionStorePageState();
}

class _SubscriptionStorePageState extends State<SubscriptionStorePage> {
  final AuthService _authService = AuthService();
  
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _error;
  
  // 每个套餐选择的订阅周期
  final Map<int, SubscriptionPeriod> _selectedPeriods = {};

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final plans = await _authService.getSubscriptionPlans();
      
      setState(() {
        _plans = plans;
        _isLoading = false;
        
        // 为每个套餐设置默认的订阅周期（选择最优惠的）
        for (final plan in plans) {
          final availablePeriods = SubscriptionPeriod.getAvailablePeriods(plan);
          if (availablePeriods.isNotEmpty) {
            // 默认选择年付，如果没有年付则选择第一个可用的
            _selectedPeriods[plan.id] = availablePeriods.contains(SubscriptionPeriod.year)
                ? SubscriptionPeriod.year
                : availablePeriods.first;
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showPurchaseDialog(SubscriptionPlan plan) {
    final selectedPeriod = _selectedPeriods[plan.id];
    if (selectedPeriod == null) return;
    
    final price = selectedPeriod.getPrice(plan);
    if (price == null || price <= 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认购买'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('套餐：${plan.name}'),
            const SizedBox(height: 8),
            Text('周期：${selectedPeriod.label}'),
            const SizedBox(height: 8),
            Text('价格：${plan.formatPrice(price)}'),
            const SizedBox(height: 8),
            Text('流量：${plan.formattedTraffic}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchasePlan(plan, selectedPeriod);
            },
            child: const Text('确认购买'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(SubscriptionPlan plan) {
    final selectedPeriod = _selectedPeriods[plan.id];
    if (selectedPeriod == null) return;
    
    final price = selectedPeriod.getPrice(plan);
    if (price == null || price <= 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          plan: plan,
          initialPeriod: selectedPeriod,
        ),
      ),
    );
  }

  void _purchasePlan(SubscriptionPlan plan, SubscriptionPeriod period) {
    // TODO: 实现购买逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('购买功能待实现：${plan.name} - ${period.label}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final availablePeriods = SubscriptionPeriod.getAvailablePeriods(plan);
    final selectedPeriod = _selectedPeriods[plan.id];
    final selectedPrice = selectedPeriod?.getPrice(plan);

    // 根据套餐等级确定重点色
    Color accentColor = TechTheme.primaryCyan;
    IconData planIcon = Icons.star_outline;
    
    if (plan.name.toLowerCase().contains('premium') || 
        plan.name.toLowerCase().contains('高级') ||
        plan.name.toLowerCase().contains('专业')) {
      accentColor = TechTheme.primaryPurple;
      planIcon = Icons.diamond_outlined;
    } else if (plan.name.toLowerCase().contains('vip') || 
               plan.name.toLowerCase().contains('至尊')) {
      accentColor = TechTheme.neonOrange;
      planIcon = Icons.workspace_premium_outlined;
    }

    return TechTheme.techCard(
      animated: true,
      accentColor: accentColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPurchaseDialog(plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 套餐头部信息
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    planIcon,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TechTheme.techTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          glowing: true,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          plan.formattedTraffic,
                          style: TechTheme.techTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedPrice != null && selectedPrice > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.formatPrice(selectedPrice),
                        style: TechTheme.techTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          glowing: true,
                        ),
                      ),
                      if (selectedPeriod != null)
                        Text(
                          selectedPeriod.label,
                          style: TechTheme.techTextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 套餐内容描述（简化显示）
            if (plan.content.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '套餐特性',
                      style: TechTheme.techTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        glowing: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSimplifiedContent(plan, accentColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 订阅周期选择
            if (availablePeriods.length > 1) ...[
              Text(
                '选择订阅周期',
                style: TechTheme.techTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  glowing: true,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availablePeriods.map((period) {
                  final price = period.getPrice(plan);
                  final isSelected = selectedPeriod == period;
                  
                  return FilterChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(period.label),
                        if (price != null && price > 0)
                          Text(
                            plan.formatPrice(price),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onSecondaryContainer
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPeriods[plan.id] = period;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // 购买按钮
            SizedBox(
              width: double.infinity,
              child: TechTheme.techButton(
                text: selectedPrice != null && selectedPrice > 0
                    ? '购买套餐 ${plan.formatPrice(selectedPrice)}'
                    : '暂不可购买',
                onPressed: (selectedPrice != null && selectedPrice > 0)
                    ? () => _navigateToCheckout(plan)
                    : () {},
                glowing: true,
                color: accentColor,
              ),
            ),
            
            // 重置流量选项
            if (plan.resetPrice != null && plan.resetPrice! > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('重置流量功能待实现：${plan.formatPrice(plan.resetPrice!)}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '重置流量 ${plan.formatPrice(plan.resetPrice!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplifiedContent(SubscriptionPlan plan, Color accentColor) {
    // 简化显示套餐内容，提取关键信息
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(Icons.cloud_download, '每月${plan.formattedTraffic}流量', accentColor),
        _buildFeatureItem(Icons.speed, 'IEPL专线隧道出口', accentColor),
        _buildFeatureItem(Icons.devices, '最大同时4个设备在线', accentColor),
        _buildFeatureItem(Icons.network_check, '端口限速1Gbps', accentColor),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '订阅商店',
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: TechTheme.primaryCyan,
            ),
            onPressed: _loadPlans,
          ),
        ],
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
            : _error != null
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TechTheme.techTextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TechTheme.techButton(
                            text: '重试',
                            onPressed: _loadPlans,
                            color: TechTheme.neonOrange,
                          ),
                        ],
                      ),
                    ),
                  )
                : _plans.isEmpty
                    ? Center(
                        child: TechTheme.techCard(
                          animated: true,
                          accentColor: TechTheme.primaryPurple,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: TechTheme.primaryPurple,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '暂无可用套餐',
                                style: TechTheme.techTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '请稍后再试或联系客服',
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
                    : RefreshIndicator(
                        onRefresh: _loadPlans,
                        color: TechTheme.primaryCyan,
                        child: ListView.builder(
                          itemCount: _plans.length,
                          itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
                        ),
                      ),
      ),
    );
  }
}
