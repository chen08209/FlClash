import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:flutter/material.dart';

class MessageManager extends StatefulWidget {
  final Widget child;

  const MessageManager({super.key, required this.child});

  @override
  State<MessageManager> createState() => MessageManagerState();
}

class MessageManagerState extends State<MessageManager> {
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  final List<CommonMessage> _bufferMessages = [];
  bool _pushing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    super.dispose();
  }

  Future<void> message(String text) async {
    final commonMessage = CommonMessage(id: utils.uuidV4, text: text);
    commonPrint.log(text);
    _bufferMessages.add(commonMessage);
    await _showMessage();
  }

  Future<void> _showMessage() async {
    if (_pushing == true) {
      return;
    }
    _pushing = true;
    while (_bufferMessages.isNotEmpty) {
      final commonMessage = _bufferMessages.removeAt(0);
      _messagesNotifier.value = List.from(_messagesNotifier.value)
        ..add(commonMessage);
      await Future.delayed(Duration(seconds: 1));
      Future.delayed(commonMessage.duration, () {
        _handleRemove(commonMessage);
      });
    }
  }

  Future<void> _handleRemove(CommonMessage commonMessage) async {
    _messagesNotifier.value = List<CommonMessage>.from(_messagesNotifier.value)
      ..remove(commonMessage);
    if (_bufferMessages.isEmpty) {
      _pushing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ValueListenableBuilder(
          valueListenable: _messagesNotifier,
          builder: (_, messages, _) {
            return Container(
              margin: EdgeInsets.only(
                top: kToolbarHeight + 12,
                left: 12,
                right: 12,
              ),
              child: FadeThroughBox(
                alignment: Alignment.topRight,
                child: messages.isEmpty
                    ? SizedBox()
                    : LayoutBuilder(
                        key: Key(messages.last.id),
                        builder: (_, constraints) {
                          return Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            elevation: 10,
                            color: context.colorScheme.surfaceContainerHigh,
                            child: Container(
                              width: min(constraints.maxWidth, 500),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(messages.last.text)),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      _handleRemove(messages.last);
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
