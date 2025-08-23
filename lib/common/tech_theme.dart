import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class TechTheme {
  // 主题基础色 - 深蓝黑色 RGB(10, 14, 39)
  static const Color mainDarkBlue = Color(0xFF0A0E27);
  
  // 科技感配色方案 - 基于主题色的变体
  static const Color primaryCyan = Color(0xFF00D9FF);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color darkBackground = Color(0xFF0A0E27);  // RGB(10, 14, 39)
  static const Color cardBackground = Color(0xFF141A3C);  // 稍亮的变体
  static const Color glassMorphism = Color(0x1AFFFFFF);
  
  // 霓虹色彩 - 与深色背景形成对比
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPink = Color(0xFFFF0080);
  static const Color neonYellow = Color(0xFFFFD700);
  static const Color neonOrange = Color(0xFFFF6B35);
  
  // 渐变色组合
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonGreen, primaryCyan, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF141A3C), Color(0xFF0A0E27)],  // 使用主题色 RGB(10, 14, 39)
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // 毛玻璃效果
  static Widget glassMorphismCard({
    required Widget child,
    double borderRadius = 16,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double blur = 10,
    Color? borderColor,
    double borderWidth = 1,
    Gradient? gradient,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ?? LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.2),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryCyan.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
  
  // 发光效果
  static BoxDecoration glowEffect({
    Color glowColor = primaryCyan,
    double intensity = 0.5,
    double spread = 10,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(intensity),
          blurRadius: spread * 2,
          spreadRadius: spread / 2,
        ),
        BoxShadow(
          color: glowColor.withOpacity(intensity * 0.5),
          blurRadius: spread * 4,
          spreadRadius: spread,
        ),
      ],
    );
  }
  
  // 网格背景
  static Widget gridBackground({
    Color gridColor = primaryCyan,
    double opacity = 0.1,
    double spacing = 30,
  }) {
    return CustomPaint(
      painter: GridPainter(
        gridColor: gridColor.withOpacity(opacity),
        spacing: spacing,
      ),
      child: Container(),
    );
  }
  
  // 脉冲动画效果
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    Color color = primaryCyan,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5 * (1 - value)),
                blurRadius: 20 * value,
                spreadRadius: 10 * value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
  
  // 科技感文字样式
  static TextStyle techTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    bool glowing = false,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? primaryCyan,
      letterSpacing: 1.2,
      shadows: glowing
          ? [
              Shadow(
                color: (color ?? primaryCyan).withOpacity(0.8),
                blurRadius: 8,
              ),
              Shadow(
                color: (color ?? primaryCyan).withOpacity(0.5),
                blurRadius: 16,
              ),
            ]
          : null,
    );
  }
  
  // 数据卡片样式
  static Widget dataCard({
    required String title,
    required String value,
    IconData? icon,
    Color? accentColor,
    required Widget child,
  }) {
    final color = accentColor ?? primaryCyan;
    return glassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: techTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              glowing: true,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // 统一的科技感页面背景
  static Widget pageBackground({
    required Widget child,
    required BuildContext context,
    bool showGrid = true,
    bool showParticles = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [
            darkBackground,
            cardBackground.withOpacity(0.8),
            darkBackground,
          ] : [
            Colors.grey.shade50,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 网格背景
          if (showGrid) 
            Positioned.fill(
              child: gridBackground(
                gridColor: isDark ? primaryCyan : Colors.blue.shade300,
                opacity: isDark ? 0.05 : 0.03,
              ),
            ),
          
          // 粒子背景
          if (showParticles)
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlesPainter(isDark: isDark),
              ),
            ),
          
          // 主要内容
          child,
        ],
      ),
    );
  }

  // 科技感Scaffold
  static Widget techScaffold({
    required BuildContext context,
    String? title,
    Widget? leading,
    List<Widget>? actions,
    required Widget body,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    bool showGrid = true,
    bool showParticles = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: title != null ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        title: Text(
          title,
          style: techTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            glowing: false,
          ),
        ),
        actions: actions,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? [
                darkBackground.withOpacity(0.9),
                cardBackground.withOpacity(0.7),
              ] : [
                Colors.white.withOpacity(0.9),
                Colors.grey.shade100.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ) : null,
      body: pageBackground(
        context: context,
        showGrid: showGrid,
        showParticles: showParticles,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  // 科技感卡片
  static Widget techCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? accentColor,
    bool animated = false,
    VoidCallback? onTap,
  }) {
    final color = accentColor ?? primaryCyan;
    Widget card = Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (animated) {
      card = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: card,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }

  // 科技感按钮
  static Widget techButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
    double width = 150,
    double height = 45,
    bool glowing = true,
  }) {
    final buttonColor = color ?? primaryCyan;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor,
            buttonColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: glowing ? [
          BoxShadow(
            color: buttonColor.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: techTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                glowing: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 科技感输入框
  static Widget techTextField({
    String? hintText,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    IconData? prefixIcon,
    bool obscureText = false,
    Color? accentColor,
  }) {
    final color = accentColor ?? primaryCyan;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: color) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// 网格背景画笔
class GridPainter extends CustomPainter {
  final Color gridColor;
  final double spacing;

  GridPainter({
    required this.gridColor,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 粒子背景画笔
class ParticlesPainter extends CustomPainter {
  final bool isDark;

  ParticlesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 绘制随机分布的粒子
    final random = Random(42); // 固定种子以保持一致性
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      
      // 根据主题选择颜色
      final baseColor = isDark 
          ? TechTheme.primaryCyan 
          : Colors.blue.shade400;
      final opacity = random.nextDouble() * 0.3 + 0.1;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = baseColor.withOpacity(opacity),
      );
    }

    // 绘制连接线
    final linePaint = Paint()
      ..color = (isDark ? TechTheme.primaryCyan : Colors.blue.shade400)
          .withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 20; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final x2 = random.nextDouble() * size.width;
      final y2 = random.nextDouble() * size.height;
      
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ParticlesPainter && oldDelegate.isDark != isDark;
  }
}

// 流光动画组件
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFF141A3C),  // 更新为匹配新主题
    this.highlightColor = const Color(0xFF00D9FF),
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: const GradientRotation(0.5),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
