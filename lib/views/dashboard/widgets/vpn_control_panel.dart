import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnControlPanel extends ConsumerWidget {
  const VpnControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStart = ref.watch(runTimeProvider.notifier).isStart;
    final theme = Theme.of(context);
    
    return SizedBox(
      height: getWidgetHeight(4),
      child: CommonCard(
        info: Info(
          label: appLocalizations.networkSpeed,
          iconData: Icons.speed_sharp,
        ),
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 连接状态指示器
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isStart 
                      ? [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.primary.withOpacity(0.1),
                        ]
                      : [
                          theme.colorScheme.surfaceVariant,
                          theme.colorScheme.surface,
                        ],
                  ),
                  boxShadow: isStart ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Icon(
                    isStart ? Icons.shield : Icons.shield_outlined,
                    size: 60,
                    color: isStart 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 状态文本
              Text(
                isStart 
                  ? '已连接' 
                  : '未连接',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isStart 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              // 运行时间
              if (isStart)
                Consumer(
                  builder: (_, ref, __) {
                    final runTime = ref.watch(runTimeProvider);
                    return Text(
                      _formatRunTime(runTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              // 实时速度显示
              Consumer(
                builder: (_, ref, __) {
                  final traffics = ref.watch(trafficsProvider).list;
                  final lastTraffic = traffics.isNotEmpty 
                    ? traffics.last 
                    : Traffic();
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上传速度
                        _buildSpeedIndicator(
                          context,
                          icon: Icons.arrow_upward,
                          label: appLocalizations.upload,
                          speed: lastTraffic.up.toString(),
                          color: theme.colorScheme.primary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                        // 下载速度
                        _buildSpeedIndicator(
                          context,
                          icon: Icons.arrow_downward,
                          label: appLocalizations.download,
                          speed: lastTraffic.down.toString(),
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String speed,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            speed,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRunTime(int? milliseconds) {
    if (milliseconds == null) return '';
    
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
