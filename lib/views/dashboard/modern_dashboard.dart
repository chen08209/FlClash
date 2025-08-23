import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/tech_theme.dart';
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
    
    // 获取主题信息
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 根据主题动态设置背景色
    final backgroundColor = isDark 
        ? TechTheme.darkBackground  // 深色模式使用科技感深蓝黑色
        : colorScheme.surface;      // 浅色模式使用主题surface颜色

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [
              backgroundColor,
              TechTheme.cardBackground.withOpacity(0.8),
              backgroundColor,
            ] : [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
              colorScheme.surfaceContainer.withOpacity(0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
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
      ),
    );
  }

  Widget _buildWorldMapBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: CustomPaint(
        painter: WorldMapPainter(isDark: isDark),
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
        final selectedMap = ref.watch(selectedMapProvider);
        
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
        
        return Container(
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
                  () {
                    // 优先使用selectedMap中的选择，如果没有则使用group.now，最后fallback到'当前节点'
                    final selectedNodeName = selectedMap[currentGroup.name] ?? 
                                            currentGroup.now ?? 
                                            '';
                    return selectedNodeName.isNotEmpty ? selectedNodeName : '当前节点';
                  }(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              // 移除了下拉箭头图标
            ],
          ),
        );
      },
    );
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
  final bool isDark;
  
  WorldMapPainter({required this.isDark});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 绘制随机分布的点来模拟世界地图上的节点
    final random = math.Random(42); // 固定种子以保持一致性
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6 + size.height * 0.2;
      final radius = random.nextDouble() * 3 + 1;
      
      // 根据主题选择颜色
      final baseColor = isDark 
          ? Colors.cyan 
          : Colors.blue.shade400;
      final opacity = random.nextDouble() * 0.5 + 0.1;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = baseColor.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is WorldMapPainter && oldDelegate.isDark != isDark;
  }
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
