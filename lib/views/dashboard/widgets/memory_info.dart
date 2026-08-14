import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

final _memoryStateNotifier = ValueNotifier<num>(0);

class MemoryInfo extends StatefulWidget {
  final Future<num> Function()? memoryReader;

  const MemoryInfo({super.key, @visibleForTesting this.memoryReader});

  @override
  State<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends State<MemoryInfo> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isForeground = false;
  bool _isUpdating = false;
  int _updateGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isForeground) {
        _startUpdating();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isForeground = false;
    _stopUpdating();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isForeground = state == AppLifecycleState.resumed;
    if (_isForeground == isForeground) {
      return;
    }
    _isForeground = isForeground;
    if (isForeground) {
      _startUpdating();
    } else {
      _stopUpdating();
    }
  }

  void _startUpdating() {
    if (!mounted || !_isForeground || _isUpdating) {
      return;
    }
    _isUpdating = true;
    final generation = ++_updateGeneration;
    unawaited(_updateMemory(generation));
  }

  void _stopUpdating() {
    _isUpdating = false;
    _updateGeneration++;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _updateMemory(int generation) async {
    final memoryReader = widget.memoryReader;
    final memory = memoryReader != null
        ? await memoryReader()
        : await _readMemory();
    if (!mounted ||
        !_isForeground ||
        !_isUpdating ||
        generation != _updateGeneration) {
      return;
    }
    _memoryStateNotifier.value = memory;
    _timer = Timer(const Duration(seconds: 2), () {
      _timer = null;
      if (mounted &&
          _isForeground &&
          _isUpdating &&
          generation == _updateGeneration) {
        unawaited(_updateMemory(generation));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: getWidgetHeight(1),
      child: RepaintBoundary(
        child: CommonCard(
          info: Info(
            iconData: Icons.memory,
            label: appLocalizations.memoryInfo,
          ),
          onPressed: () {
            coreController.requestGc();
          },
          child: Container(
            padding: baseInfoEdgeInsets.copyWith(top: 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: globalState.measure.bodyMediumHeight + 2,
                  child: ValueListenableBuilder(
                    valueListenable: _memoryStateNotifier,
                    builder: (_, memory, _) {
                      final traffic = memory.traffic;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            traffic.value,
                            style: context.textTheme.bodyMedium?.toLight
                                .adjustSize(1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            traffic.unit,
                            style: context.textTheme.bodyMedium?.toLight
                                .adjustSize(1),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<num> _readMemory() async {
  final rss = ProcessInfo.currentRss;
  final coreConnected =
      globalState.container.read(coreStatusProvider) == CoreStatus.connected;
  if (system.isDesktop && coreConnected) {
    return await coreController.getMemory() + rss;
  }
  return rss;
}
