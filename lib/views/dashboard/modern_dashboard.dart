import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class ModernDashboard extends ConsumerStatefulWidget {
  const ModernDashboard({super.key});

  @override
  ConsumerState<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends ConsumerState<ModernDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _connectingController;
  late Animation<double> _connectingRotation;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 连接中动画控制器
    _connectingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _connectingRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _connectingController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _connectingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStart = ref.watch(runTimeProvider.notifier).isStart;

    // 监听运行状态变化
    ref.listen<int?>(runTimeProvider, (previous, next) {
      if (previous == null && next != null) {
        // 开始连接
        setState(() {
          _isConnecting = true;
        });
        _connectingController.repeat();
        
        // 模拟连接过程，2秒后显示已连接
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isConnecting = false;
            });
            _connectingController.stop();
            _connectingController.reset();
          }
        });
      } else if (previous != null && next == null) {
        // 断开连接
        setState(() {
          _isConnecting = false;
        });
        _connectingController.stop();
        _connectingController.reset();
      }
    });

    if (isStart && !_isConnecting) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // 世界地图背景
          _buildWorldMapBackground(),
          
          // 主要内容
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 判断是否需要滚动
                final isSmallScreen = constraints.maxHeight < 650;
                
                Widget content = Column(
                  children: [
                    // 添加顶部间距
                    SizedBox(height: isSmallScreen ? 10 : 20),
                    
                    // 出站模式选择
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: isSmallScreen ? 5 : 8,
                      ),
                      child: _buildModeSelector(),
                    ),
                    
                    // 节点选择器
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildNodeSelector(context),
                    ),
                    
                    // 灵活空间
                    Expanded(
                      child: Center(
                        child: _buildConnectButton(context, isStart, isSmallScreen),
                      ),
                    ),
                    
                    // 速度显示
                    _buildSpeedDisplay(context, isSmallScreen),
                    
                    SizedBox(height: isSmallScreen ? 10 : 15),
                    
                    // IP地址显示
                    _buildIpDisplay(context),
                    
                    SizedBox(height: isSmallScreen ? 15 : 20),
                  ],
                );
                
                // 如果屏幕太小，允许滚动
                if (isSmallScreen) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: content,
                    ),
                  );
                }
                
                return content;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldMapBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WorldMapPainter(),
      ),
    );
  }


  Widget _buildModeSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final mode = ref.watch(patchClashConfigProvider.select(
          (state) => state.mode,
        ));
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '出站模式',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              DropdownButton<Mode>(
                value: mode,
                dropdownColor: const Color(0xFF1A1E3A),
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                items: Mode.values.map((Mode value) {
                  return DropdownMenuItem<Mode>(
                    value: value,
                    child: Text(_getModeText(value)),
                  );
                }).toList(),
                onChanged: (Mode? newValue) {
                  if (newValue != null) {
                    globalState.appController.changeMode(newValue);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getModeText(Mode mode) {
    switch (mode) {
      case Mode.rule:
        return '规则';
      case Mode.global:
        return '全局';
      case Mode.direct:
        return '直连';
    }
  }

  Widget _buildNodeSelector(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final groups = ref.watch(groupsProvider);
        final currentGroupName = ref.watch(currentProfileProvider.select(
          (state) => state?.currentGroupName,
        ));
        
        // 获取当前选中的节点组
        final currentGroup = groups.firstWhere(
          (g) => g.name == currentGroupName,
          orElse: () => groups.isNotEmpty ? groups.first : Group(
            name: 'Unknown',
            type: GroupType.Selector,
            all: [],
            now: '',
          ),
        );
        
        return InkWell(
          onTap: () => _showNodeSelector(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 国旗图标（这里用圆形代替）
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red, Colors.yellow, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    (currentGroup.now?.isNotEmpty ?? false) ? currentGroup.now! : 'Select Node',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNodeSelector(BuildContext context) {
    final groups = ref.read(groupsProvider);
    final selectedMap = ref.read(selectedMapProvider);
    final delayDataSource = ref.read(delayDataSourceProvider);
    
    // 找到第一个 Selector 或 URLTest 类型的组
    final proxyGroup = groups.firstWhere(
      (g) => g.type == GroupType.Selector || g.type == GroupType.URLTest,
      orElse: () => groups.isNotEmpty ? groups.first : Group(
        name: 'Unknown',
        type: GroupType.Selector,
        all: [],
        now: '',
      ),
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1E3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择节点',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              
              // 节点列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: proxyGroup.all.length,
                  itemBuilder: (context, index) {
                    final proxy = proxyGroup.all[index];
                    final proxyName = proxy.name;
                    final isSelected = proxyGroup.now == proxyName;
                    // DelayMap is Map<String, Map<String, int?>>, need to find the delay for this proxy
                    int? delay;
                    for (final entry in delayDataSource.entries) {
                      if (entry.value.containsKey(proxyName)) {
                        delay = entry.value[proxyName];
                        break;
                      }
                    }
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Colors.cyan.withOpacity(0.2)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                            ? Colors.cyan.withOpacity(0.5)
                            : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () async {
                          // 切换代理
                          await globalState.appController.changeProxy(
                            groupName: proxyGroup.name,
                            proxyName: proxyName,
                          );
                          Navigator.pop(context);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _getCountryColors(proxyName),
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getCountryEmoji(proxyName),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          proxyName,
                          style: TextStyle(
                            color: isSelected ? Colors.cyan : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 延迟显示
                            if (delay != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDelayColor(delay).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  delay > 0 ? '${delay}ms' : 'timeout',
                                  style: TextStyle(
                                    color: _getDelayColor(delay),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // 选中标记
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.cyan,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 根据节点名称获取国家颜色
  List<Color> _getCountryColors(String proxyName) {
    final name = proxyName.toLowerCase();
    if (name.contains('us') || name.contains('美国')) {
      return [Colors.blue, Colors.red, Colors.white];
    } else if (name.contains('jp') || name.contains('日本')) {
      return [Colors.white, Colors.red, Colors.white];
    } else if (name.contains('hk') || name.contains('香港')) {
      return [Colors.red, Colors.white, Colors.red];
    } else if (name.contains('sg') || name.contains('新加坡')) {
      return [Colors.red, Colors.white];
    } else if (name.contains('tw') || name.contains('台湾')) {
      return [Colors.red, Colors.blue, Colors.white];
    } else if (name.contains('kr') || name.contains('韩国')) {
      return [Colors.white, Colors.red, Colors.blue];
    } else if (name.contains('de') || name.contains('德国')) {
      return [Colors.black, Colors.red, Colors.yellow];
    } else if (name.contains('uk') || name.contains('英国')) {
      return [Colors.blue, Colors.white, Colors.red];
    } else if (name.contains('ca') || name.contains('加拿大')) {
      return [Colors.red, Colors.white, Colors.red];
    } else if (name.contains('au') || name.contains('澳大利亚')) {
      return [Colors.blue, Colors.white, Colors.red];
    }
    return [Colors.grey, Colors.blueGrey];
  }
  
  // 根据节点名称获取国家表情
  String _getCountryEmoji(String proxyName) {
    final name = proxyName.toLowerCase();
    if (name.contains('us') || name.contains('美国')) return '🇺🇸';
    if (name.contains('jp') || name.contains('日本')) return '🇯🇵';
    if (name.contains('hk') || name.contains('香港')) return '🇭🇰';
    if (name.contains('sg') || name.contains('新加坡')) return '🇸🇬';
    if (name.contains('tw') || name.contains('台湾')) return '🇹🇼';
    if (name.contains('kr') || name.contains('韩国')) return '🇰🇷';
    if (name.contains('de') || name.contains('德国')) return '🇩🇪';
    if (name.contains('uk') || name.contains('英国')) return '🇬🇧';
    if (name.contains('ca') || name.contains('加拿大')) return '🇨🇦';
    if (name.contains('au') || name.contains('澳大利亚')) return '🇦🇺';
    if (name.contains('fr') || name.contains('法国')) return '🇫🇷';
    if (name.contains('nl') || name.contains('荷兰')) return '🇳🇱';
    if (name.contains('ru') || name.contains('俄罗斯')) return '🇷🇺';
    if (name.contains('in') || name.contains('印度')) return '🇮🇳';
    if (name.contains('br') || name.contains('巴西')) return '🇧🇷';
    return '🌍';
  }
  
  // 根据延迟获取颜色
  Color _getDelayColor(int delay) {
    if (delay <= 0) return Colors.red;
    if (delay < 100) return Colors.green;
    if (delay < 300) return Colors.yellow;
    if (delay < 500) return Colors.orange;
    return Colors.red;
  }

  Widget _buildConnectButton(BuildContext context, bool isStart, [bool isSmallScreen = false]) {
    return Center(
      child: GestureDetector(
        onTap: _isConnecting ? null : () async {
          if (!isStart) {
            // 开始连接动画
            setState(() {
              _isConnecting = true;
            });
            _connectingController.repeat();
          }
          
          // 执行连接/断开操作
          await globalState.appController.updateStart();
          
          // 如果是断开操作，立即停止动画
          if (isStart) {
            setState(() {
              _isConnecting = false;
            });
            _connectingController.stop();
            _connectingController.reset();
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _connectingRotation]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 脉冲效果背景
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSmallScreen ? 150 : 180,
                  height: isSmallScreen ? 150 : 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _isConnecting
                          ? [
                              Colors.orange.withOpacity(0.3),
                              Colors.orange.withOpacity(0.1),
                              Colors.transparent,
                            ]
                          : isStart
                              ? [
                                  Colors.green.withOpacity(0.3),
                                  Colors.green.withOpacity(0.1),
                                  Colors.transparent,
                                ]
                              : [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                    ),
                  ),
                ),
                
                // 主按钮
                Transform.scale(
                  scale: isStart && !_isConnecting ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: isSmallScreen ? 120 : 150,
                    height: isSmallScreen ? 120 : 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isConnecting
                            ? [
                                Colors.orange.withOpacity(0.8),
                                Colors.deepOrange.withOpacity(0.8),
                              ]
                            : isStart
                                ? [
                                    Colors.green.withOpacity(0.8),
                                    Colors.teal.withOpacity(0.8),
                                  ]
                                : [
                                    Colors.cyan.withOpacity(0.8),
                                    Colors.blue.withOpacity(0.8),
                                  ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isConnecting
                              ? Colors.orange.withOpacity(0.5)
                              : isStart
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.cyan.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isConnecting ? null : () async {
                          if (!isStart) {
                            setState(() {
                              _isConnecting = true;
                            });
                            _connectingController.repeat();
                          }
                          await globalState.appController.updateStart();
                          if (isStart) {
                            setState(() {
                              _isConnecting = false;
                            });
                            _connectingController.stop();
                            _connectingController.reset();
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Center(
                          child: _isConnecting
                              ? Transform.rotate(
                                  angle: _connectingRotation.value,
                                  child: Icon(
                                    Icons.sync,
                                    color: Colors.white,
                                    size: isSmallScreen ? 40 : 50,
                                  ),
                                )
                              : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: isStart
                                      ? Column(
                                          key: const ValueKey('disconnect'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.stop_circle_outlined,
                                              color: Colors.white,
                                              size: isSmallScreen ? 35 : 40,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '断开',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isSmallScreen ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          key: const ValueKey('connect'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.power_settings_new,
                                              color: Colors.white,
                                              size: isSmallScreen ? 35 : 40,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '连接',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isSmallScreen ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 连接中的进度环
                if (_isConnecting)
                  SizedBox(
                    width: isSmallScreen ? 140 : 170,
                    height: isSmallScreen ? 140 : 170,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.withOpacity(0.8),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpeedDisplay(BuildContext context, [bool isSmallScreen = false]) {
    return Consumer(
      builder: (context, ref, _) {
        final traffics = ref.watch(trafficsProvider).list;
        final lastTraffic = traffics.isNotEmpty ? traffics.last : Traffic();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.cyan.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '实时速率',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              
              // 速度图表
              SizedBox(
                height: isSmallScreen ? 50 : 60,
                child: CustomPaint(
                  painter: SpeedChartPainter(traffics),
                  child: Container(),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // 速度数值
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSpeedItem(
                    value: lastTraffic.up.showValue,
                    unit: lastTraffic.up.showUnit,
                    label: lastTraffic.up.value > 0 ? '↑ ${lastTraffic.up.value.toStringAsFixed(1)}' : '↑ 0.0',
                    color: Colors.cyan,
                  ),
                  _buildSpeedItem(
                    value: lastTraffic.down.showValue,
                    unit: lastTraffic.down.showUnit,
                    label: lastTraffic.down.value > 0 ? '↑ ${lastTraffic.down.value.toStringAsFixed(1)}' : '↑ 0.0',
                    color: Colors.cyan,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeedItem({
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          '$value $unit',
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIpDisplay(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        
        // Use ValueListenableBuilder to watch detection state
        return ValueListenableBuilder<NetworkDetectionState>(
          valueListenable: detectionState.state,
          builder: (context, detectionStateValue, child) {
            final ipInfo = detectionStateValue.ipInfo;
            final isLoading = detectionStateValue.isLoading;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.cyan.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'IP 地址',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () {
                          // Trigger IP check
                          detectionState.startCheck();
                        },
                      ),
                    ],
                  ),
                  // Display IP based on state
                  if (ipInfo != null) ...[
                    Text(
                      ipInfo.ip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '国家: ${ipInfo.countryCode}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ] else if (isLoading) ...[
                    const SizedBox(height: 8),
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '未检测到 IP',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// 世界地图绘制器
class WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 绘制随机分布的点来模拟世界地图上的节点
    final random = math.Random(42); // 固定种子以保持一致性
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6 + size.height * 0.2;
      final radius = random.nextDouble() * 3 + 1;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.cyan.withOpacity(random.nextDouble() * 0.5 + 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 速度图表绘制器
class SpeedChartPainter extends CustomPainter {
  final List<Traffic> traffics;

  SpeedChartPainter(this.traffics);

  @override
  void paint(Canvas canvas, Size size) {
    if (traffics.isEmpty) return;

    final paint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final maxSpeed = traffics.map((t) => t.speed).reduce(math.max);
    final step = size.width / math.max(traffics.length - 1, 1);

    for (int i = 0; i < traffics.length; i++) {
      final x = i * step;
      final y = size.height - (traffics[i].speed / math.max(maxSpeed, 1)) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpeedChartPainter oldDelegate) => true;
}
