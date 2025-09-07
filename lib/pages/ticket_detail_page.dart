import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/ticket.dart';
import 'package:fl_clash/models/ticket_detail.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class TicketDetailPage extends StatefulWidget {
  final int ticketId;

  const TicketDetailPage({
    super.key,
    required this.ticketId,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  TicketDetail? _ticketDetail;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTicketDetail();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 开始自动刷新（每秒一次）
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isLoading) {
        _loadTicketDetail(silent: true);
      }
    });
  }

  // 加载工单详情
  Future<void> _loadTicketDetail({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final ticketDetail = await _authService.getTicketDetail(widget.ticketId);
      if (mounted) {
        final wasAtBottom = _scrollController.hasClients && 
                           _scrollController.position.pixels >= 
                           _scrollController.position.maxScrollExtent - 100;

        setState(() {
          _ticketDetail = ticketDetail;
          _isLoading = false;
          _errorMessage = null;
        });

        // 如果之前在底部，保持在底部
        if (wasAtBottom && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else if (!silent && _scrollController.hasClients) {
          // 首次加载时滚动到底部
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 发送回复
  Future<void> _sendReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入回复内容'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _authService.replyTicket(
        ticketId: widget.ticketId,
        message: message,
      );

      if (mounted) {
        _replyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('回复发送成功'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 立即刷新获取最新消息
        await _loadTicketDetail(silent: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TechPageWrapper(
      title: _ticketDetail?.subject ?? '工单详情',
      child: _isLoading && _ticketDetail == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryCyan),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载工单详情中...',
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null && _ticketDetail == null
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
                        onPressed: _loadTicketDetail,
                        color: TechTheme.primaryCyan,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 工单信息头部
                    if (_ticketDetail != null) _buildTicketHeader(),
                    
                    // 消息列表
                    Expanded(
                      child: _buildMessageList(),
                    ),
                    
                    // 回复输入区域
                    if (_ticketDetail?.status == TicketStatus.open) _buildReplyArea(),
                  ],
                ),
    );
  }

  Widget _buildTicketHeader() {
    final ticket = _ticketDetail!;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: TechTheme.techTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ticket.level.levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ticket.level.levelColor, width: 1),
                ),
                child: Text(
                  ticket.level.levelText,
                  style: TechTheme.techTextStyle(
                    fontSize: 12,
                    color: ticket.level.levelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ticket.replyStatus.replyStatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ticket.replyStatus.replyStatusColor, width: 1),
                ),
                child: Text(
                  ticket.replyStatus.replyStatusText,
                  style: TechTheme.techTextStyle(
                    fontSize: 10,
                    color: ticket.replyStatus.replyStatusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ticket.status.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ticket.status.statusColor, width: 1),
                ),
                child: Text(
                  ticket.status.statusText,
                  style: TechTheme.techTextStyle(
                    fontSize: 10,
                    color: ticket.status.statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '创建于 ${ticket.formattedCreatedAt}',
                style: TechTheme.techTextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_ticketDetail == null || _ticketDetail!.messages.isEmpty) {
      return Center(
        child: Text(
          '暂无消息',
          style: TechTheme.techTextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ticketDetail!.messages.length,
      itemBuilder: (context, index) {
        final message = _ticketDetail!.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(TicketMessage message) {
    final isMe = message.isMe;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.senderColor,
              child: Icon(
                Icons.support_agent,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? TechTheme.primaryCyan : TechTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: isMe ? null : Border.all(
                      color: TechTheme.primaryCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TechTheme.techTextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.senderLabel} · ${message.formattedCreatedAt}',
                  style: TechTheme.techTextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: message.senderColor,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TechTheme.cardBackground,
        border: Border(
          top: BorderSide(color: TechTheme.primaryCyan.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              style: TechTheme.techTextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '输入回复内容...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: TechTheme.primaryCyan.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: TechTheme.primaryCyan.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: TechTheme.primaryCyan, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
              minLines: 1,
              enabled: !_isSending,
            ),
          ),
          const SizedBox(width: 12),
          TechTheme.techButton(
            text: _isSending ? '发送中...' : '发送',
            onPressed: _isSending ? () {} : _sendReply,
            color: TechTheme.neonGreen,
            width: 80,
            height: 40,
          ),
        ],
      ),
    );
  }
}
