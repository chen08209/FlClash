import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/services/api_service_v2.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> with TickerProviderStateMixin {
  final ApiServiceV2 _apiService = ApiServiceV2();
  
  InviteInfo? _inviteInfo;
  List<InviteDetail> _inviteDetails = [];
  bool _isLoading = true;
  bool _isLoadingDetails = false;
  String? _error;
  
  late TabController _tabController;
  final TextEditingController _transferAmountController = TextEditingController();
  final TextEditingController _withdrawAccountController = TextEditingController();
  String _selectedWithdrawMethod = 'USDT';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInviteInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transferAmountController.dispose();
    _withdrawAccountController.dispose();
    super.dispose();
  }

  Future<void> _loadInviteInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final inviteInfo = await _apiService.getInviteInfo();

      if (mounted) {
        setState(() {
          _inviteInfo = inviteInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInviteDetails() async {
    if (_isLoadingDetails) return;
    
    try {
      setState(() {
        _isLoadingDetails = true;
      });

      print('InvitePage: Loading invite details...');
      final details = await _apiService.getInviteDetails();
      print('InvitePage: Invite details loaded successfully, count: ${details.data.length}');

      if (mounted) {
        setState(() {
          _inviteDetails = details.data;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      print('InvitePage: Failed to load invite details: $e');
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载佣金记录失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateInviteCode() async {
    try {
      print('InvitePage: Generating invite code...');
      final success = await _apiService.generateInviteCode();
      print('InvitePage: Generate invite code result: $success');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('邀请码生成成功'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadInviteInfo(); // 刷新数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生成邀请码失败：服务器返回失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('InvitePage: Failed to generate invite code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成邀请码失败：${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('邀请码已复制到剪贴板'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _copyInviteLink(String code) async {
    const baseUrl = 'https://origin.huanshen.org'; // 使用API相同的域名
    final inviteLink = '$baseUrl/#/register?code=$code';
    await Clipboard.setData(ClipboardData(text: inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('邀请链接已复制到剪贴板'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _transferToBalance() async {
    if (_transferAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入转换金额'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final amount = double.parse(_transferAmountController.text);
      final amountInCents = (amount * 100).round(); // 转换为分

      print('InvitePage: Transferring commission to balance, amount: ¥$amount ($amountInCents 分)');
      final success = await _apiService.transferCommissionToBalance(amountInCents);
      print('InvitePage: Transfer commission result: $success');
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('佣金转换成功'),
            backgroundColor: Colors.green,
          ),
        );
        _transferAmountController.clear();
        await _loadInviteInfo(); // 刷新数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('佣金转换失败：服务器返回失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('InvitePage: Failed to transfer commission: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('佣金转换失败：${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _withdrawCommission() async {
    if (_withdrawAccountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入提现地址'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('InvitePage: Withdrawing commission, method: $_selectedWithdrawMethod, account: ${_withdrawAccountController.text}');
      final success = await _apiService.withdrawCommission(
        withdrawMethod: _selectedWithdrawMethod,
        withdrawAccount: _withdrawAccountController.text,
        amountInCents: 0, // TODO: 需要获取实际金额
      );
      print('InvitePage: Withdraw commission result: $success');
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('提现申请提交成功'),
            backgroundColor: Colors.green,
          ),
        );
        _withdrawAccountController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('提现申请失败：服务器返回失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('InvitePage: Failed to withdraw commission: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('提现申请失败：${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          '我的邀请',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A0E27),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '邀请统计'),
            Tab(text: '邀请码'),
            Tab(text: '佣金管理'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.blue,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInviteInfo,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatisticsTab(),
                    _buildInviteCodesTab(),
                    _buildCommissionTab(),
                  ],
                ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_inviteInfo == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(
            '已注册用户',
            '${_inviteInfo!.stat.registeredUsers}人',
            Icons.person_add,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            '佣金比例',
            _inviteInfo!.stat.formattedCommissionRate,
            Icons.percent,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            '确认中佣金',
            _inviteInfo!.stat.formattedPendingCommission,
            Icons.hourglass_empty,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            '累计获得佣金',
            _inviteInfo!.stat.formattedTotalCommission,
            Icons.account_balance_wallet,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCodesTab() {
    if (_inviteInfo == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 生成邀请码按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateInviteCode,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '生成邀请码',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 邀请码列表
          if (_inviteInfo!.codes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.code, color: Colors.white54, size: 48),
                  SizedBox(height: 16),
                  Text(
                    '暂无邀请码',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击上方按钮生成您的专属邀请码',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...(_inviteInfo!.codes.map((code) => _buildInviteCodeCard(code))),
        ],
      ),
    );
  }

  Widget _buildInviteCodeCard(InviteCode code) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '邀请码',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _copyInviteCode(code.code),
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    tooltip: '复制邀请码',
                  ),
                  IconButton(
                    onPressed: () => _copyInviteLink(code.code),
                    icon: const Icon(Icons.link, color: Colors.green),
                    tooltip: '复制邀请链接',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('访问量', '${code.pv}'),
              const SizedBox(width: 8),
              _buildInfoChip('创建时间', code.formattedCreatedAt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildCommissionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 佣金转为余额
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A4A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '佣金转为余额',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _transferAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '转换金额（元）',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _transferToBalance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '转换',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 佣金提现
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A4A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '佣金提现',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedWithdrawMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedWithdrawMethod = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: '提现方式',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF1E2A4A),
                  items: const [
                    DropdownMenuItem(
                      value: 'USDT', 
                      child: Text('USDT', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'ALIPAY', 
                      child: Text('支付宝', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'WECHAT', 
                      child: Text('微信', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _withdrawAccountController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '提现地址/账号',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _withdrawCommission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '申请提现',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 佣金记录
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A4A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '佣金记录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _loadInviteDetails,
                      child: const Text('加载记录'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isLoadingDetails)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                else if (_inviteDetails.isEmpty)
                  const Text(
                    '暂无佣金记录',
                    style: TextStyle(color: Colors.white54),
                  )
                else
                  ..._inviteDetails.map((detail) => _buildCommissionRecord(detail)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionRecord(InviteDetail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单号: ${detail.tradeNo}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                detail.formattedGetAmount,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单金额: ${detail.formattedOrderAmount}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                detail.formattedCreatedAt,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
