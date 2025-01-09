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
  final _floatMessageKey = GlobalKey();
  List<CommonMessage> bufferMessages = [];
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  final _floatMessageNotifier = ValueNotifier<CommonMessage?>(null);
  double maxWidth = 0;

  late AnimationController _animationController;

  Completer? _animationCompleter;
  late Animation<Offset> _floatOffsetAnimation;
  late Animation<Offset> _commonOffsetAnimation;
  final animationDuration = commonDuration * 2;

  _initTransformState() {
    _floatMessageNotifier.value = null;
    _floatOffsetAnimation = Tween(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_animationController);
    _commonOffsetAnimation = _floatOffsetAnimation = Tween(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_animationController);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _initTransformState();
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    _floatMessageNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  message(String text) async {
    final commonMessage = CommonMessage(
      id: other.uuidV4,
      text: text,
    );
    bufferMessages.add(commonMessage);
    await _animationCompleter?.future;
    _showMessage();
  }

  _showMessage() {
    final commonMessage = bufferMessages.removeAt(0);
    _floatOffsetAnimation = Tween(
      begin: Offset(-maxWidth, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.5,
          1,
          curve: Curves.easeInOut,
        ),
      ),
    );
    _floatMessageNotifier.value = commonMessage;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = _floatMessageKey.currentContext?.size ?? Size.zero;
      _commonOffsetAnimation = Tween(
        begin: Offset.zero,
        end: Offset(0, -size.height - 12),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0,
            0.7,
            curve: Curves.easeInOut,
          ),
        ),
      );
      _animationCompleter = Completer();
      _animationCompleter?.complete(_animationController.forward(from: 0));
      await _animationCompleter?.future;
      _initTransformState();
      _messagesNotifier.value = List.from(_messagesNotifier.value)
        ..add(commonMessage);
      Future.delayed(
        commonMessage.duration,
        () {
          _removeMessage(commonMessage);
        },
      );
    });
  }

  Widget _wrapOffset(Widget child) {
    return AnimatedBuilder(
      animation: _animationController.view,
      builder: (context, child) {
        return Transform.translate(
          offset: _commonOffsetAnimation.value,
          child: child!,
        );
      },
      child: child,
    );
  }

  Widget _wrapMessage(CommonMessage message) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: context.colorScheme.secondaryFixedDim,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        child: Text(
          message.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSecondaryFixedVariant,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _floatMessage() {
    return ValueListenableBuilder(
      valueListenable: _floatMessageNotifier,
      builder: (_, message, ___) {
        if (message == null) {
          return SizedBox();
        }
        return AnimatedBuilder(
          key: _floatMessageKey,
          animation: _animationController.view,
          builder: (_, child) {
            if (!_animationController.isAnimating) {
              return Opacity(
                opacity: 0,
                child: child,
              );
            }
            return Transform.translate(
              offset: _floatOffsetAnimation.value,
              child: child,
            );
          },
          child: _wrapMessage(
            message,
          ),
        );
      },
    );
  }

  _removeMessage(CommonMessage commonMessage) async {
    final itemWrapState = GlobalObjectKey(commonMessage.id).currentState
        as _MessageItemWrapState?;
    await itemWrapState?.transform(
      Offset(-maxWidth, 0),
    );
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
                                  if (message != messages.last)
                                    SizedBox(
                                      height: 8,
                                    ),
                                  _MessageItemWrap(
                                    key: GlobalObjectKey(message.id),
                                    child: _wrapOffset(
                                      _wrapMessage(message),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      _floatMessage(),
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

class _MessageItemWrap extends StatefulWidget {
  final Widget child;

  const _MessageItemWrap({
    super.key,
    required this.child,
  });

  @override
  State<_MessageItemWrap> createState() => _MessageItemWrapState();
}

class _MessageItemWrapState extends State<_MessageItemWrap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _nextOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration * 1.5,
    );
  }

  transform(Offset offset) async {
    _nextOffset = offset;
    await _controller.forward(from: 0);
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
        if (_nextOffset == Offset.zero) {
          return child!;
        }
        final offset = Tween(
          begin: Offset.zero,
          end: _nextOffset,
        )
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
              ),
            )
            .value;
        return Transform.translate(
          offset: offset,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
