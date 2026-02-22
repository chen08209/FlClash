import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/database.dart';
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
      appController.updateStatus(isStart, isInit: !ref.read(initProvider));
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
    return Theme(
      data: Theme.of(context).copyWith(
        floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme
            .copyWith(
              sizeConstraints: BoxConstraints(minWidth: 56, maxWidth: 200),
            ),
      ),
      child: AnimatedBuilder(
        animation: _controller!.view,
        builder: (_, child) {
          final textWidth =
              globalState.measure
                  .computeTextSize(
                    Text(
                      utils.getTimeDifference(DateTime.now()),
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
                  width: 56,
                  alignment: Alignment.center,
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
        child: Consumer(
          builder: (_, ref, _) {
            final runTime = ref.watch(runTimeProvider);
            final text = utils.getTimeText(runTime);
            return Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: Theme.of(context).textTheme.titleMedium?.toSoftBold
                  .copyWith(color: context.colorScheme.onPrimaryContainer),
            );
          },
        ),
      ),
    );
  }
}

class LaunchBrowserButton extends ConsumerWidget {
  const LaunchBrowserButton({super.key});

  Future<void> _launchWithProxy(int port) async {
    final proxyArg = '--proxy-server=http://127.0.0.1:$port';
    if (system.isWindows) {
      // Follow v2rayN style: start browser with proxy args.
      await Process.start('cmd', ['/c', 'start', '', 'msedge', proxyArg]);
      return;
    }
    if (system.isMacOS) {
      await Process.start('open', [
        '-a',
        'Google Chrome',
        '--args',
        proxyArg,
      ]);
      return;
    }
    if (system.isLinux) {
      final commands = [
        'google-chrome',
        'google-chrome-stable',
        'chromium-browser',
        'chromium',
      ];
      for (final command in commands) {
        try {
          await Process.start(command, [proxyArg]);
          return;
        } catch (_) {
          // try next command
        }
      }
      throw 'Chrome is not found on this Linux system.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (system.isAndroid) {
      return const SizedBox.shrink();
    }
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) {
      return const SizedBox.shrink();
    }
    final isStart = ref.watch(isStartProvider);
    final port = ref.watch(proxyStateProvider.select((state) => state.port));
    return FloatingActionButton(
      heroTag: null,
      mini: true,
      tooltip: 'Launch browser with proxy',
      onPressed: !isStart
          ? null
          : () async {
              try {
                await _launchWithProxy(port);
              } catch (e) {
                globalState.showNotifier('Launch browser failed: $e');
              }
            },
      child: const Icon(Icons.language),
    );
  }
}
