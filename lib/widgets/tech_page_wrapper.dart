import 'package:flutter/material.dart';
import 'package:fl_clash/common/tech_theme.dart';

/// 统一的科技感页面包装器
/// 为所有页面提供一致的科技感背景和样式
class TechPageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showGrid;
  final bool showParticles;
  final bool showAppBar;
  final EdgeInsetsGeometry? padding;

  const TechPageWrapper({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showGrid = true,
    this.showParticles = true,
    this.showAppBar = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final wrappedChild = padding != null 
        ? Padding(padding: padding!, child: child)
        : child;

    if (showAppBar && title != null) {
      return TechTheme.techScaffold(
        context: context,
        title: title,
        leading: leading,
        actions: actions,
        body: wrappedChild,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        showGrid: showGrid,
        showParticles: showParticles,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TechTheme.pageBackground(
        context: context,
        showGrid: showGrid,
        showParticles: showParticles,
        child: wrappedChild,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// 科技感列表项组件
class TechListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool animated;

  const TechListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? TechTheme.primaryCyan;
    
    return TechTheme.techCard(
      animated: animated,
      accentColor: color,
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (leading != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: leading,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) 
                  DefaultTextStyle(
                    style: TechTheme.techTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    child: title!,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// 科技感设置项组件
class TechSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;

  const TechSettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? TechTheme.primaryCyan;
    
    return TechListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        color: Colors.white.withOpacity(0.5),
      ),
      onTap: onTap,
      accentColor: color,
    );
  }
}

/// 科技感统计卡片
class TechStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? accentColor;
  final Widget? chart;

  const TechStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.accentColor,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? TechTheme.primaryCyan;
    
    return TechTheme.techCard(
      animated: true,
      accentColor: color,
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
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TechTheme.techTextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TechTheme.techTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  glowing: true,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TechTheme.techTextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
          if (chart != null) ...[
            const SizedBox(height: 12),
            chart!,
          ],
        ],
      ),
    );
  }
}
