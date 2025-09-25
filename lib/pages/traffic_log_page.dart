import 'package:flutter/material.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/traffic_log.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class TrafficLogPage extends StatefulWidget {
  const TrafficLogPage({super.key});

  @override
  State<TrafficLogPage> createState() => _TrafficLogPageState();
}

class _TrafficLogPageState extends State<TrafficLogPage> {
  final AuthService _authService = AuthService();
  List<TrafficLog> _trafficLogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrafficLogs();
  }

  Future<void> _fetchTrafficLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 确保AuthService已初始化
      await _authService.initialize();
      final logs = await _authService.getTrafficLogs();
      // 按时间倒序排列（最新的在前面）
      logs.sort((a, b) => b.recordAt.compareTo(a.recordAt));
      setState(() {
        _trafficLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TechPageWrapper(
      title: '流量明细',
      child: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryCyan),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载流量明细中...',
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TechTheme.techTextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TechTheme.techButton(
                        text: '重试',
                        onPressed: _fetchTrafficLogs,
                        color: TechTheme.primaryCyan,
                      ),
                    ],
                  ),
                )
              : _trafficLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无流量记录',
                            style: TechTheme.techTextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '开始使用服务后这里会显示流量统计',
                            style: TechTheme.techTextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // 统计概览
                        _buildStatsOverview(),
                        
                        // 流量记录列表
                        Expanded(
                          child: RefreshIndicator(
                            color: TechTheme.primaryCyan,
                            backgroundColor: TechTheme.darkBackground,
                            onRefresh: _fetchTrafficLogs,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _trafficLogs.length,
                              itemBuilder: (context, index) {
                                final log = _trafficLogs[index];
                                return _buildTrafficLogCard(log);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStatsOverview() {
    if (_trafficLogs.isEmpty) return const SizedBox.shrink();

    // 计算统计数据
    int totalDownload = 0;
    int totalUpload = 0;
    int totalBilled = 0;

    for (final log in _trafficLogs) {
      totalDownload += log.download;
      totalUpload += log.upload;
      totalBilled += log.billedTraffic;
    }

    final totalTraffic = totalDownload + totalUpload;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TechTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TechTheme.primaryCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '流量统计概览',
            style: TechTheme.techTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TechTheme.primaryCyan,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总流量',
                  _formatTraffic(totalTraffic),
                  TechTheme.neonGreen,
                  Icons.data_usage,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '实际计费',
                  _formatTraffic(totalBilled),
                  TechTheme.neonOrange,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '下载',
                  _formatTraffic(totalDownload),
                  TechTheme.primaryBlue,
                  Icons.download,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '上传',
                  _formatTraffic(totalUpload),
                  TechTheme.primaryPurple,
                  Icons.upload,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TechTheme.techTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TechTheme.techTextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLogCard(TrafficLog log) {
    return TechTheme.techCard(
      animated: true,
      accentColor: TechTheme.primaryCyan,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期和总流量
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: TechTheme.primaryCyan,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.formattedDate,
                      style: TechTheme.techTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: log.trafficColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: log.trafficColor, width: 1),
                  ),
                  child: Text(
                    log.formattedTotal,
                    style: TechTheme.techTextStyle(
                      fontSize: 12,
                      color: log.trafficColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 流量详情
            Row(
              children: [
                Expanded(
                  child: _buildTrafficDetail(
                    '下载',
                    log.formattedDownload,
                    Icons.download,
                    TechTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTrafficDetail(
                    '上传',
                    log.formattedUpload,
                    Icons.upload,
                    TechTheme.primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 扣费信息
            Row(
              children: [
                Expanded(
                  child: _buildTrafficDetail(
                    '扣费倍率',
                    log.formattedServerRate,
                    Icons.trending_up,
                    log.serverRateColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTrafficDetail(
                    '实际计费',
                    log.formattedBilledTraffic,
                    Icons.account_balance_wallet,
                    TechTheme.neonOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficDetail(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TechTheme.techTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TechTheme.techTextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 格式化流量显示
  String _formatTraffic(int trafficBytes) {
    if (trafficBytes == 0) return '0 B';
    
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var index = 0;
    double size = trafficBytes.toDouble();
    
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }
    
    if (size == size.floor()) {
      return '${size.toInt()} ${units[index]}';
    } else {
      return '${size.toStringAsFixed(2)} ${units[index]}';
    }
  }
}
