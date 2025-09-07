import 'package:flutter/material.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/ticket.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final AuthService _authService = AuthService();
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tickets = await _authService.getTicketList();
      setState(() {
        _tickets = tickets;
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
      title: '工单中心',
      actions: [
        IconButton(
          icon: Icon(
            Icons.add,
            color: TechTheme.primaryCyan,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/create_ticket').then((_) {
              // 创建工单后返回时刷新列表
              _fetchTickets();
            });
          },
        ),
      ],
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
                    '加载工单列表中...',
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
                        onPressed: _fetchTickets,
                        color: TechTheme.primaryCyan,
                      ),
                    ],
                  ),
                )
              : _tickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无工单',
                            style: TechTheme.techTextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击右上角 + 号创建工单',
                            style: TechTheme.techTextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TechTheme.techButton(
                            text: '创建工单',
                            onPressed: () {
                              Navigator.pushNamed(context, '/create_ticket').then((_) {
                                _fetchTickets();
                              });
                            },
                            color: TechTheme.neonGreen,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: TechTheme.primaryCyan,
                      backgroundColor: TechTheme.darkBackground,
                      onRefresh: _fetchTickets,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: _tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = _tickets[index];
                            return _buildTicketCard(ticket);
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return TechTheme.techCard(
      animated: true,
      accentColor: TechTheme.primaryCyan,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ticket_detail',
            arguments: {
              'ticketId': ticket.id,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和级别
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
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
            
            // 状态信息
            Row(
              children: [
                // 回复状态
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
                // 工单状态
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
              ],
            ),
            const SizedBox(height: 12),
            
            // 时间信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '创建时间',
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      ticket.formattedCreatedAt,
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '更新时间',
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      ticket.formattedUpdatedAt,
                      style: TechTheme.techTextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
