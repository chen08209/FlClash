import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/subscription_plan.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 套餐头部信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          plan.formattedTraffic,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      if (selectedPeriod != null)
                        Text(
                          selectedPeriod.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                    ],
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 套餐内容描述（简化显示）
            if (plan.content.isNotEmpty) ...[
              Text(
                '套餐特性：',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildSimplifiedContent(plan),
              ),
              const SizedBox(height: 16),
            ],
            
            // 订阅周期选择
            if (availablePeriods.length > 1) ...[
              Text(
                '选择周期：',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
              child: ElevatedButton(
                onPressed: selectedPrice != null && selectedPrice > 0
                    ? () => _showPurchaseDialog(plan)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedPrice != null && selectedPrice > 0
                      ? '购买套餐 ${plan.formatPrice(selectedPrice)}'
                      : '暂不可购买',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
    );
  }

  Widget _buildSimplifiedContent(SubscriptionPlan plan) {
    // 简化显示套餐内容，提取关键信息
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(Icons.cloud_download, '每月${plan.formattedTraffic}流量'),
        _buildFeatureItem(Icons.speed, 'IEPL专线隧道出口'),
        _buildFeatureItem(Icons.devices, '最大同时4个设备在线'),
        _buildFeatureItem(Icons.network_check, '端口限速1Gbps'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
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
        title: const Text('订阅商店'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlans,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPlans,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _plans.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64),
                          SizedBox(height: 16),
                          Text('暂无可用套餐'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlans,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
                      ),
                    ),
    );
  }
}
