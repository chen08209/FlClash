import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/models/app_version.dart';
import 'package:fl_clash/providers/app.dart';

/// 版本更新弹窗组件
class VersionUpdateDialog extends ConsumerStatefulWidget {
  final AppVersion versionInfo;
  final String currentVersion;
  final VoidCallback? onClosed;

  const VersionUpdateDialog({
    super.key,
    required this.versionInfo,
    required this.currentVersion,
    this.onClosed,
  });

  @override
  ConsumerState<VersionUpdateDialog> createState() => _VersionUpdateDialogState();
}

class _VersionUpdateDialogState extends ConsumerState<VersionUpdateDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onClosed?.call();
    }
  }

  Future<void> _handleUpdate() async {
    try {
      final uri = Uri.parse(widget.versionInfo.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('无法打开下载链接');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开下载链接失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getUpdateIcon() {
    if (widget.versionInfo.isForcedUpdate) {
      return Icons.priority_high;
    } else if (widget.versionInfo.isOptionalUpdate) {
      return Icons.system_update;
    } else {
      return Icons.info_outline;
    }
  }

  Color _getUpdateColor() {
    if (widget.versionInfo.isForcedUpdate) {
      return const Color(0xFFFF6B35); // 橙红色，表示强制更新
    } else if (widget.versionInfo.isOptionalUpdate) {
      return const Color(0xFF00D9FF); // 青色，表示可选更新
    } else {
      return const Color(0xFF00FF88); // 绿色，表示无需更新
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = ref.watch(viewSizeProvider);
    final updateColor = _getUpdateColor();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: size.width * 0.9,
                  constraints: const BoxConstraints(
                    maxWidth: 380,
                    maxHeight: 500,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E27), // 深蓝黑色背景
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: updateColor.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: updateColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题栏
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A3C),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: updateColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getUpdateIcon(),
                                color: updateColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.versionInfo.isForcedUpdate ? '强制更新' : '版本更新',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: updateColor,
                                ),
                              ),
                            ),
                            if (!widget.versionInfo.isForcedUpdate)
                              IconButton(
                                onPressed: _handleClose,
                                icon: const Icon(Icons.close, color: Colors.white70),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  shape: const CircleBorder(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // 内容区域
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 版本信息卡片
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141A3C),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: updateColor.withOpacity(0.3),
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
                                        '当前版本',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        widget.currentVersion,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '最新版本',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        widget.versionInfo.version,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: updateColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '更新类型',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: updateColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          widget.versionInfo.updateTypeDescription,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: updateColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 更新时间
                            Text(
                              '更新时间：${widget.versionInfo.updateTime}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 操作按钮
                            Row(
                              children: [
                                if (!widget.versionInfo.isForcedUpdate) ...[
                                  // 稍后再说按钮（仅在非强制更新时显示）
                                  Expanded(
                                    child: TextButton(
                                      onPressed: _handleClose,
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        foregroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('稍后再说'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                
                                // 立即更新按钮
                                Expanded(
                                  flex: widget.versionInfo.isForcedUpdate ? 1 : 2,
                                  child: ElevatedButton(
                                    onPressed: _handleUpdate,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: updateColor,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.download,
                                          size: 16,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.versionInfo.isForcedUpdate ? '立即更新' : '更新',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 版本更新管理工具类
class VersionUpdateManager {
  /// 显示版本更新弹窗
  static Future<void> showUpdateDialog(
    BuildContext context,
    AppVersion versionInfo,
    String currentVersion, {
    VoidCallback? onClosed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: !versionInfo.isForcedUpdate, // 强制更新时不允许点击背景关闭
      builder: (context) => VersionUpdateDialog(
        versionInfo: versionInfo,
        currentVersion: currentVersion,
        onClosed: onClosed,
      ),
    );
  }

  /// 检查并显示版本更新
  static Future<void> checkAndShowUpdate(
    BuildContext context,
    AppVersion versionInfo, {
    VoidCallback? onClosed,
  }) async {
    try {
      final currentVersion = await AppVersion.getCurrentVersion();
      final hasNewVersion = await AppVersion.hasNewVersion(versionInfo.version);
      
      if (hasNewVersion && versionInfo.needsUpdate) {
        await showUpdateDialog(
          context,
          versionInfo,
          currentVersion,
          onClosed: onClosed,
        );
      }
    } catch (e) {
      print('检查版本更新失败: $e');
    }
  }
}
