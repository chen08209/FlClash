import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/loading.dart';
import 'package:fl_clash/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusManager extends StatefulWidget {
  final Widget child;

  const StatusManager({super.key, required this.child});

  @override
  State<StatusManager> createState() => StatusManagerState();
}

class StatusManagerState extends State<StatusManager> {
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  final _bufferMessages = Queue<CommonMessage>();
  final _activeTimers = <String, Timer>{};
  bool _isDisplayingMessage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _bufferMessages.clear();
    super.dispose();
  }

  void message(String text, {MessageActionState? actionState}) {
    final commonMessage = CommonMessage(
      id: utils.uuidV4,
      text: text,
      actionState: actionState,
    );
    _bufferMessages.add(commonMessage);
    commonPrint.log('message: $text');
    _processQueue();
  }

  void _cancelMessage(String id) {
    _bufferMessages.removeWhere((msg) => msg.id == id);
    if (_activeTimers.containsKey(id)) {
      _removeMessage(id);
    }
  }

  void _processQueue() {
    if (_isDisplayingMessage || _bufferMessages.isEmpty) {
      return;
    }
    _isDisplayingMessage = true;
    final message = _bufferMessages.removeFirst();
    _messagesNotifier.value = List.from(_messagesNotifier.value)..add(message);
    final timer = Timer(message.duration, () {
      _removeMessage(message.id);
    });
    _activeTimers[message.id] = timer;
  }

  void _removeMessage(String id) {
    _activeTimers.remove(id)?.cancel();
    final currentMessages = List<CommonMessage>.from(_messagesNotifier.value);
    currentMessages.removeWhere((msg) => msg.id == id);
    _messagesNotifier.value = currentMessages;
    _isDisplayingMessage = false;
    _processQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Consumer(
          builder: (_, ref, child) {
            final top = ref.watch(overlayTopOffsetProvider);
            return Container(
              margin: EdgeInsets.only(
                top: top + MediaQuery.of(context).viewPadding.top + 8,
              ),
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: AnimatedSize(
                  duration: animateDuration,
                  child: ValueListenableBuilder(
                    valueListenable: _messagesNotifier,
                    builder: (_, messages, _) {
                      return FadeThroughBox(
                        alignment: Alignment.centerRight,
                        child: messages.isEmpty
                            ? SizedBox()
                            : LayoutBuilder(
                                key: Key(messages.last.id),
                                builder: (_, constraints) {
                                  return Dismissible(
                                    key: ValueKey(messages.last.id),
                                    onDismissed: (_) {
                                      _cancelMessage(messages.last.id);
                                    },
                                    child: Card(
                                      shape: const RoundedSuperellipseBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(14),
                                        ),
                                      ),
                                      elevation: 10,
                                      color: context
                                          .colorScheme
                                          .surfaceContainerHigh,
                                      child: Container(
                                        width: min(constraints.maxWidth, 500),
                                        constraints: BoxConstraints(
                                          minHeight: 54,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                messages.last.text,
                                                maxLines: 3,
                                                style: context
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                      color: context
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            if (messages.last.actionState !=
                                                null)
                                              CommonMinFilledButtonTheme(
                                                child: FilledButton.tonal(
                                                  onPressed: () async {
                                                    _cancelMessage(
                                                      messages.last.id,
                                                    );
                                                    messages.last.actionState!
                                                        .action();
                                                  },
                                                  child: Text(
                                                    messages
                                                        .last
                                                        .actionState!
                                                        .actionText,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ),
              ),
              LoadingIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}

class LoadingIndicator extends ConsumerWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final loading = ref.watch(loadingProvider);
    final isMobileView = ref.watch(isMobileViewProvider);
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: midDuration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: loading && isMobileView
          ? Container(
              height: 54,
              margin: EdgeInsets.only(top: 8, left: 14, right: 14),
              child: Material(
                elevation: 3,
                color: context.colorScheme.surfaceContainer,
                surfaceTintColor: context.colorScheme.surfaceTint,
                shape: const RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          context.appLocalizations.loading,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: CommonCircleLoading(),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
