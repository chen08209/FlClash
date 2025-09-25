import 'package:flutter/material.dart';
import 'package:fl_clash/services/auth_service.dart';
import 'package:fl_clash/models/ticket.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/widgets/widgets.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  TicketLevel _selectedLevel = TicketLevel.low;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 确保AuthService已初始化
      await _authService.initialize();
      final success = await _authService.createTicket(
        subject: _subjectController.text.trim(),
        level: _selectedLevel,
        message: _messageController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('工单创建成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // 返回工单列表
      } else {
        throw Exception('创建工单失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建工单失败：${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TechPageWrapper(
      title: '创建工单',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 工单标题
              Text(
                '工单标题',
                style: TechTheme.techTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TechTheme.primaryCyan,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                style: TechTheme.techTextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: '工单标题',
                  hintText: '请输入工单标题',
                  prefixIcon: Icon(Icons.title, color: TechTheme.primaryCyan),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TechTheme.primaryCyan.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TechTheme.primaryCyan, width: 2),
                  ),
                  labelStyle: TechTheme.techTextStyle(
                    fontSize: 14,
                    color: TechTheme.primaryCyan,
                  ),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入工单标题';
                  }
                  if (value.trim().length < 3) {
                    return '工单标题至少需要3个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 优先级选择
              Text(
                '优先级',
                style: TechTheme.techTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TechTheme.primaryCyan,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: TicketLevel.values.map((level) {
                  final isSelected = _selectedLevel == level;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLevel = level;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? level.levelColor.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected 
                                  ? level.levelColor 
                                  : Colors.white.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getLevelIcon(level),
                                color: level.levelColor,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level.levelText,
                                style: TechTheme.techTextStyle(
                                  fontSize: 12,
                                  color: level.levelColor,
                                  fontWeight: isSelected 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 工单内容
              Text(
                '工单内容',
                style: TechTheme.techTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TechTheme.primaryCyan,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                style: TechTheme.techTextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: '工单内容',
                  hintText: '请详细描述您遇到的问题或需要帮助的内容...',
                  prefixIcon: Icon(Icons.description, color: TechTheme.primaryCyan),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TechTheme.primaryCyan.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TechTheme.primaryCyan, width: 2),
                  ),
                  labelStyle: TechTheme.techTextStyle(
                    fontSize: 14,
                    color: TechTheme.primaryCyan,
                  ),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入工单内容';
                  }
                  if (value.trim().length < 10) {
                    return '工单内容至少需要10个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: TechTheme.techButton(
                  text: _isSubmitting ? '创建中...' : '创建工单',
                  onPressed: _isSubmitting ? () {} : _submitTicket,
                  color: TechTheme.neonGreen,
                  height: 48,
                ),
              ),

              const SizedBox(height: 16),

              // 取消按钮
              SizedBox(
                width: double.infinity,
                child: TechTheme.techButton(
                  text: '取消',
                  onPressed: _isSubmitting 
                      ? () {} 
                      : () => Navigator.of(context).pop(),
                  color: Colors.grey,
                  height: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLevelIcon(TicketLevel level) {
    switch (level) {
      case TicketLevel.low:
        return Icons.low_priority;
      case TicketLevel.medium:
        return Icons.priority_high;
      case TicketLevel.high:
        return Icons.error;
    }
  }
}
