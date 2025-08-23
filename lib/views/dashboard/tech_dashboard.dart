import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'widgets/widgets.dart';

class TechDashboard extends ConsumerStatefulWidget {
  const TechDashboard({super.key});

  @override
  ConsumerState<TechDashboard> createState() => _TechDashboardState();
}

class _TechDashboardState extends ConsumerState<TechDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isStart = ref.watch(runTimeProvider.notifier).isStart;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 获取主题色
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final surfaceColor = colorScheme.surface;
    final backgroundColor = isDark ? colorScheme.background : colorScheme.surface;
    final cardColor = isDark 
        ? colorScheme.surfaceVariant.withOpacity(0.3)
        : colorScheme.surfaceVariant.withOpacity(0.5);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [
            backgroundColor,
            cardColor,
            backgroundColor,
          ] : [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.95),
            colorScheme.surface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 科技感网格背景
          Positioned.fill(
            child: TechTheme.gridBackground(
              gridColor: primaryColor,
              opacity: isDark ? 0.03 : 0.02,
              spacing: 50,
            ),
          ),
          
          // 动态粒子效果
          Positioned.fill(
            child: _ParticleBackground(
              isActive: isStart,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          ),
          
          // 主内容
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
            children: [
              // 连接状态大卡片
              _buildMainStatusCard(context, isStart),
              const SizedBox(height: 20),
              
              // 速度监控区域
              Row(
                children: [
                  Expanded(
                    child: _buildSpeedCard(
                      context,
                      title: appLocalizations.upload,
                      icon: Icons.arrow_upward,
                      color: primaryColor,  // 使用主题的主色调
                      isUpload: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSpeedCard(
                      context,
                      title: appLocalizations.download,
                      icon: Icons.arrow_downward,
                      color: secondaryColor,  // 使用主题的次要色调
                      isUpload: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 流量统计和网络检测
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildTrafficChart(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: _buildNetworkInfo(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 快速设置网格
              _buildQuickSettings(context),
              const SizedBox(height: 20),
              
              // 核心信息
              _buildCoreInfo(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatusCard(BuildContext context, bool isStart) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: TechTheme.glassMorphismCard(
            padding: const EdgeInsets.all(24),
            gradient: LinearGradient(
              colors: isStart
                  ? [
                      primaryColor.withOpacity(0.15),
                      secondaryColor.withOpacity(0.08),
                    ]
                  : [
                      colorScheme.surfaceVariant.withOpacity(0.3),
                      colorScheme.surface.withOpacity(0.5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: isStart
                ? primaryColor.withOpacity(0.6)
                : primaryColor.withOpacity(0.2),
            child: Column(
              children: [
                // 连接按钮
                GestureDetector(
                  onTap: () async {
                    await globalState.appController.updateStart();
                  },
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isStart ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isStart
                                ? LinearGradient(
                                    colors: [
                                      primaryColor,
                                      secondaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      colorScheme.surfaceVariant.withOpacity(0.6),
                                      colorScheme.surface.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            boxShadow: isStart
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              isStart ? Icons.power_settings_new : Icons.power_off,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // 状态文字
                ShimmerEffect(
                  baseColor: isStart ? primaryColor : primaryColor.withOpacity(0.3),
                  highlightColor: isStart ? secondaryColor : primaryColor.withOpacity(0.5),
                  duration: const Duration(seconds: 3),
                  child: Text(
                    isStart ? '已连接' : '未连接',
                    style: TechTheme.techTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isStart ? primaryColor : Colors.grey,
                      glowing: isStart,
                    ),
                  ),
                ),
                
                // 运行时间
                if (isStart)
                  Consumer(
                    builder: (_, ref, __) {
                      final runTime = ref.watch(runTimeProvider);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatRunTime(runTime),
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isUpload,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer(
      builder: (context, ref, _) {
        final traffics = ref.watch(trafficsProvider).list;
        final lastTraffic = traffics.isNotEmpty ? traffics.last : Traffic();
        final speed = isUpload ? lastTraffic.up : lastTraffic.down;
        
        return TechTheme.glassMorphismCard(
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            colors: [
              colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.5),
              colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderColor: color.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    speed.showValue,
                    style: TechTheme.techTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                      glowing: true,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      speed.showUnit,
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 迷你速度图表
              SizedBox(
                height: 30,
                child: CustomPaint(
                  painter: _MiniChartPainter(
                    traffics: traffics,
                    color: color,
                    isUpload: isUpload,
                  ),
                  child: Container(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrafficChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    
    return TechTheme.glassMorphismCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [
          colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.5),
          colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: primaryColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                appLocalizations.trafficUsage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Consumer(
              builder: (_, ref, __) {
                final traffics = ref.watch(trafficsProvider).list;
                return LineChart(
                  gradient: true,
                  color: primaryColor,
                  points: _getTrafficPoints(traffics),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer(
      builder: (context, ref, _) {
        return TechTheme.glassMorphismCard(
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            colors: [
              colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.5),
              colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderColor: secondaryColor.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.language,
                    color: secondaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appLocalizations.networkDetection,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const NetworkDetection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickSettings(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    
    // 使用主题色的不同变体
    final settingsItems = [
      {'icon': Icons.language, 'label': '系统代理', 'color': primaryColor},
      {'icon': Icons.vpn_lock, 'label': 'TUN模式', 'color': secondaryColor},
      {'icon': Icons.speed, 'label': '测速', 'color': primaryColor.withOpacity(0.8)},
      {'icon': Icons.dns, 'label': 'DNS设置', 'color': secondaryColor.withOpacity(0.8)},
    ];

    return TechTheme.glassMorphismCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [
          colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.5),
          colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: primaryColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速设置',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: settingsItems.length,
            itemBuilder: (context, index) {
              final item = settingsItems[index];
              return _QuickSettingItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                color: item['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoreInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    
    return TechTheme.glassMorphismCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [
          colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.5),
          colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: secondaryColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.memory,
                color: secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                appLocalizations.coreInfo,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const MemoryInfo(),
        ],
      ),
    );
  }

  List<Point> _getTrafficPoints(List<Traffic> traffics) {
    if (traffics.isEmpty) return [Point(0, 0), Point(1, 0)];
    
    return traffics.asMap().entries.map((entry) {
      return Point(
        entry.key.toDouble(),
        entry.value.speed.toDouble(),
      );
    }).toList();
  }

  String _formatRunTime(int? milliseconds) {
    if (milliseconds == null) return '';
    
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '运行时间 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// 快速设置项
class _QuickSettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickSettingItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 处理点击事件
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// 迷你图表绘制器
class _MiniChartPainter extends CustomPainter {
  final List<Traffic> traffics;
  final Color color;
  final bool isUpload;

  _MiniChartPainter({
    required this.traffics,
    required this.color,
    required this.isUpload,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (traffics.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final values = traffics.map((t) => 
      isUpload ? t.up.value : t.down.value
    ).toList();
    
    if (values.isEmpty) return;
    
    final maxValue = values.reduce(math.max);
    final step = size.width / math.max(values.length - 1, 1);

    fillPath.moveTo(0, size.height);
    
    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - (values[i] / math.max(maxValue, 1)) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) => true;
}

// 粒子背景效果
class _ParticleBackground extends StatefulWidget {
  final bool isActive;
  final Color primaryColor;
  final Color secondaryColor;

  const _ParticleBackground({
    required this.isActive,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    // 初始化粒子
    for (int i = 0; i < 30; i++) {
      particles.add(Particle(
        random,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      ));
    }

    _controller.addListener(() {
      setState(() {
        for (var particle in particles) {
          particle.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: widget.isActive ? 1.0 : 0.3,
      child: CustomPaint(
        painter: ParticlePainter(
          particles: particles,
          isActive: widget.isActive,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
        child: Container(),
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speed;
  late double radius;
  late Color color;
  final math.Random random;
  final Color primaryColor;
  final Color secondaryColor;

  Particle(
    this.random, {
    required this.primaryColor,
    required this.secondaryColor,
  }) {
    reset();
  }

  void reset() {
    x = random.nextDouble();
    y = random.nextDouble();
    speed = random.nextDouble() * 0.002 + 0.001;
    radius = random.nextDouble() * 2 + 1;
    
    // 使用主题颜色
    final colors = [
      primaryColor,
      secondaryColor,
      primaryColor.withOpacity(0.8),
      secondaryColor.withOpacity(0.8),
    ];
    final colorIndex = random.nextInt(colors.length);
    color = colors[colorIndex].withOpacity(random.nextDouble() * 0.5 + 0.1);
  }

  void update() {
    y -= speed;
    if (y < 0) {
      reset();
      y = 1.0;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final bool isActive;
  final Color primaryColor;
  final Color secondaryColor;

  ParticlePainter({
    required this.particles,
    required this.isActive,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = isActive
            ? particle.color
            : particle.color.withOpacity(particle.color.opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
