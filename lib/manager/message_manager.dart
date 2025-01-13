import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

class MessageManager extends StatefulWidget {
  final Widget child;

  const MessageManager({
    super.key,
    required this.child,
  });

  @override
  State<MessageManager> createState() => MessageManagerState();
}

class MessageManagerState extends State<MessageManager>
    with SingleTickerProviderStateMixin {
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  double maxWidth = 0;
  Offset offset = Offset.zero;

  late AnimationController _animationController;

  final animationDuration = commonDuration * 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  message(String text) async {
    final commonMessage = CommonMessage(
      id: other.uuidV4,
      text: text,
    );
    _messagesNotifier.value = List.from(_messagesNotifier.value)
      ..add(
        commonMessage,
      );
  }

  _handleRemove(CommonMessage commonMessage) async {
    _messagesNotifier.value = List<CommonMessage>.from(_messagesNotifier.value)
      ..remove(commonMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        LayoutBuilder(
          builder: (context, container) {
            maxWidth = container.maxWidth / 2 + 16;
            return SizedBox(
              width: maxWidth,
              child: ValueListenableBuilder(
                valueListenable: globalState.safeMessageOffsetNotifier,
                builder: (_, offset, child) {
                  this.offset = offset;
                  if (offset == Offset.zero) {
                    return SizedBox();
                  }
                  return Transform.translate(
                    offset: offset,
                    child: child!,
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(
                    right: 0,
                    left: 8,
                    top: 0,
                    bottom: 16,
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      SingleChildScrollView(
                        reverse: true,
                        physics: NeverScrollableScrollPhysics(),
                        child: ValueListenableBuilder(
                          valueListenable: _messagesNotifier,
                          builder: (_, messages, ___) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final message in messages) ...[
                                  if (message != messages.first)
                                    SizedBox(
                                      height: 12,
                                    ),
                                  _MessageItem(
                                    key: GlobalObjectKey(message.id),
                                    message: message,
                                    onRemove: _handleRemove,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class _MessageItem extends StatefulWidget {
  final CommonMessage message;
  final Function(CommonMessage message) onRemove;

  const _MessageItem({
    super.key,
    required this.message,
    required this.onRemove,
  });

  @override
  State<_MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<_MessageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration * 1.5,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0,
        1,
        curve: Curves.easeOut,
      ),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0,
        0.2,
        curve: Curves.easeIn,
      ),
    ));

    _controller.forward();

    Future.delayed(
      widget.message.duration,
      () async {
        await _controller.reverse();
        widget.onRemove(
          widget.message,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              elevation: _controller.value * 12,
              borderRadius: BorderRadius.circular(8),
              color: context.colorScheme.surfaceContainer,
              clipBehavior: Clip.none,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  widget.message.text,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
