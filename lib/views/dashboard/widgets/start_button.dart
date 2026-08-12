import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartButton extends ConsumerStatefulWidget {
  const StartButton({super.key});

  @override
  ConsumerState<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<StartButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;
  bool isStart = false;

  @override
  void initState() {
    super.initState();
    isStart = ref.read(isStartProvider);
    _controller = AnimationController(
      vsync: this,
      value: isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutBack,
    );
    ref.listenManual(isStartProvider, (prev, next) {
      if (next != isStart) {
        isStart = next;
        updateController();
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void handleSwitchStart() {
    isStart = !isStart;
    updateController();
    debouncer.call(FunctionTag.updateStatus, () {
      globalState.container
          .read(setupActionProvider.notifier)
          .updateStatus(isStart, isInit: !ref.read(initProvider));
    }, duration: commonDuration);
  }

  void updateController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isStart && mounted) {
        _controller?.forward();
      } else {
        _controller?.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) {
      return Container();
    }
    final suspend = ref.watch(suspendProvider);
    final theme = Theme.of(context);
    final appLocalizations = context.appLocalizations;
    final hourDigits = ref.watch(
      runTimeProvider.select((state) {
        final hours = (state ?? 0) ~/ 3600000;
        final digits = hours.toString().length;
        return digits < 2 ? 2 : digits;
      }),
    );
    return RepaintBoundary(
      child: Theme(
        data: theme.copyWith(
          floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
            sizeConstraints: const BoxConstraints(minWidth: 56, maxWidth: 200),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller!.view,
          builder: (_, child) {
            final textWidth = suspend
                ? globalState.measure
                          .computeTextSize(
                            Text(
                              appLocalizations.suspended,
                              style: context.textTheme.titleMedium,
                            ),
                          )
                          .width +
                      24
                : globalState.measure
                          .computeTextSize(
                            Text(
                              '${'0' * hourDigits}:00:00',
                              style: context.textTheme.titleMedium?.toSoftBold,
                            ),
                          )
                          .width +
                      16;
            return FloatingActionButton(
              clipBehavior: Clip.antiAlias,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              heroTag: null,
              onPressed: () {
                handleSwitchStart();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 56,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16 - 8 * _animation.value,
                    ),
                    alignment: Alignment.centerLeft,
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _animation,
                    ),
                  ),
                  SizedBox(width: textWidth * _animation.value, child: child!),
                ],
              ),
            );
          },
          child: suspend
              ? Text(
                  appLocalizations.suspended,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                )
              : Consumer(
                  builder: (_, ref, _) {
                    final runTime = ref.watch(runTimeProvider);
                    final text = utils.getTimeText(runTime);
                    return Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context).textTheme.titleMedium?.toSoftBold
                          .copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
