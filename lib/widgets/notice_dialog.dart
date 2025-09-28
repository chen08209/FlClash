import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/models/notice.dart';
import 'package:fl_clash/providers/app.dart';

/// 公告弹窗组件
/// 支持启动弹窗展示和轮播图滑动浏览多条公告
class NoticeDialog extends ConsumerStatefulWidget {
  final List<Notice> notices;
  final VoidCallback? onClosed;

  const NoticeDialog({
    super.key,
    required this.notices,
    this.onClosed,
  });

  @override
  ConsumerState<NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends ConsumerState<NoticeDialog>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentIndex = 0;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (_dontShowAgain) {
      await _saveDontShowAgainPreference();
    }
    
    // 播放关闭动画
    await _animationController.reverse();
    
    if (mounted) {
      Navigator.of(context).pop();
      widget.onClosed?.call();
    }
  }

  Future<void> _saveDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('notice_dont_show_until', timestamp + (24 * 60 * 60 * 1000)); // 24小时后再显示
  }

  void _nextPage() {
    if (_currentIndex < widget.notices.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = ref.watch(viewSizeProvider);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.6 * _fadeAnimation.value), // 增加背景遮罩不透明度
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.75,
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    maxHeight: 600,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E27), // 使用账号页面的深蓝黑色背景
                    borderRadius: BorderRadius.circular(16), // 减小圆角，匹配账号页面
                    border: Border.all(
                      color: const Color(0xFF00D9FF), // 使用账号页面的边框颜色
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withOpacity(0.2), // 青色阴影
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 标题栏
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF141A3C), // 使用账号页面的卡片背景色
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D9FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.campaign,
                                color: Color(0xFF00D9FF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '系统公告',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D9FF),
                                ),
                              ),
                            ),
                            // 页面指示器（如果有多条公告）
                            if (widget.notices.length > 1) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D9FF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF00D9FF).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${_currentIndex + 1}/${widget.notices.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF00D9FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
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
                      
                      // 公告内容区域
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemCount: widget.notices.length,
                          itemBuilder: (context, index) {
                            final notice = widget.notices[index];
                            return _buildNoticeContent(notice);
                          },
                        ),
                      ),
                      
                      // 底部操作区域
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A3C), // 使用账号页面的卡片背景色
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF00D9FF).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // 轮播图导航按钮
                            if (widget.notices.length > 1) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _currentIndex > 0 ? _previousPage : null,
                                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                                    style: IconButton.styleFrom(
                                      backgroundColor: _currentIndex > 0 
                                          ? const Color(0xFF00D9FF).withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  
                                  // 页面指示点
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      widget.notices.length,
                                      (index) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index == _currentIndex
                                              ? const Color(0xFF00D9FF)
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 20),
                                  IconButton(
                                    onPressed: _currentIndex < widget.notices.length - 1 ? _nextPage : null,
                                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                                    style: IconButton.styleFrom(
                                      backgroundColor: _currentIndex < widget.notices.length - 1
                                          ? const Color(0xFF00D9FF).withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // 底部按钮
                            Row(
                              children: [
                                // "今日不再显示"选项
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _dontShowAgain,
                                        onChanged: (value) {
                                          setState(() {
                                            _dontShowAgain = value ?? false;
                                          });
                                        },
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        activeColor: const Color(0xFF00D9FF),
                                        checkColor: Colors.black,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _dontShowAgain = !_dontShowAgain;
                                            });
                                          },
                                          child: Text(
                                            '今日不再显示',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 关闭按钮
                                ElevatedButton(
                                  onPressed: _handleClose,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00D9FF),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    '知道了',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
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

  Widget _buildNoticeContent(Notice notice) {
    return Container(
      color: const Color(0xFF0A0E27), // 主背景色
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 公告标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141A3C), // 使用账号页面的卡片背景色
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D9FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D9FF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '发布时间：${_formatDate(notice.updatedDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 公告内容
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A3C), // 使用账号页面的卡片背景色
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3), // 紫色边框
                    width: 1,
                  ),
                ),
                child: Text(
                  notice.content,
                  style: TextStyle(
                    height: 1.6,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),
          
          // 标签（如果有）
          if (notice.tags != null && notice.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: notice.tags!.split(',').map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.2), // 绿色标签
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00FF88).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00FF88),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// 公告管理工具类
class NoticeManager {
  static const String _prefsKeyDontShowUntil = 'notice_dont_show_until';
  static const String _prefsKeyLastShownVersion = 'notice_last_shown_version';

  /// 检查是否应该显示公告
  static Future<bool> shouldShowNotices(List<Notice> notices) async {
    if (notices.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final dontShowUntil = prefs.getInt(_prefsKeyDontShowUntil) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 如果用户选择了今日不再显示，且时间未到，则不显示
    if (dontShowUntil > now) {
      return false;
    }

    return true;
  }

  /// 显示公告弹窗
  static Future<void> showNoticeDialog(
    BuildContext context,
    List<Notice> notices, {
    VoidCallback? onClosed,
  }) async {
    if (!await shouldShowNotices(notices)) {
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 不允许点击背景关闭
      builder: (context) => NoticeDialog(
        notices: notices,
        onClosed: onClosed,
      ),
    );
  }

  /// 清除"今日不再显示"设置
  static Future<void> clearDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyDontShowUntil);
  }
}
