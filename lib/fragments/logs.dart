import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

double _preOffset = 0;

class LogsFragment extends ConsumerStatefulWidget {
  const LogsFragment({super.key});

  @override
  ConsumerState<LogsFragment> createState() => _LogsFragmentState();
}

class _LogsFragmentState extends ConsumerState<LogsFragment> with PageMixin {
  final _logsStateNotifier = ValueNotifier<LogsState>(LogsState());
  final _scrollController = ScrollController(
    initialScrollOffset: _preOffset != 0 ? _preOffset : double.maxFinite,
  );
  final FixedMap<String, double?> _cacheDynamicHeightMap = FixedMap(1000);
  double _currentMaxWidth = 0;

  List<Log> _logs = [];

  @override
  void initState() {
    super.initState();
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
      logs: globalState.appState.logs.list,
    );
    ref.listenManual(
      logsProvider.select((state) => state.list),
      (prev, next) {
        if (prev != next) {
          final isEquality = logListEquality.equals(prev, next);
          if (!isEquality) {
            _logs = next;
            updateLogsThrottler();
          }
        }
      },
      fireImmediately: true,
    );
    ref.listenManual(
      isCurrentPageProvider(
        PageLabel.logs,
        handler: (pageLabel, viewMode) =>
            pageLabel == PageLabel.tools && viewMode == ViewMode.mobile,
      ),
      (prev, next) {
        if (prev != next && next == true) {
          initPageState();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  List<Widget> get actions => [
        IconButton(
          onPressed: () {
            _handleExport();
          },
          icon: const Icon(
            Icons.file_download_outlined,
          ),
        ),
      ];

  @override
  get onSearch => (value) {
        _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
          query: value,
        );
      };

  @override
  get onKeywordsUpdate => (keywords) {
        _logsStateNotifier.value =
            _logsStateNotifier.value.copyWith(keywords: keywords);
      };

  @override
  void dispose() {
    _logsStateNotifier.dispose();
    _scrollController.dispose();
    _cacheDynamicHeightMap.clear();
    super.dispose();
  }

  _handleTryClearCache(double maxWidth) {
    if (_currentMaxWidth != maxWidth) {
      _currentMaxWidth = maxWidth;
      _cacheDynamicHeightMap.clear();
    }
  }

  _handleExport() async {
    final commonScaffoldState = context.commonScaffoldState;
    final res = await commonScaffoldState?.loadingRun<bool>(
      () async {
        return await globalState.appController.exportLogs();
      },
      title: appLocalizations.exportLogs,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.exportSuccess),
    );
  }

  double _calcCacheHeight(String text) {
    final cacheHeight = _cacheDynamicHeightMap.get(text);
    if (cacheHeight != null) {
      return cacheHeight;
    }
    final size = globalState.measure.computeTextSize(
      Text(
        text,
        style: globalState.appController.context.textTheme.bodyLarge,
      ),
      maxWidth: _currentMaxWidth,
    );
    _cacheDynamicHeightMap.put(text, size.height);
    return size.height;
  }

  double _getItemHeight(Log log) {
    final measure = globalState.measure;
    final bodySmallHeight = measure.bodySmallHeight;
    final bodyMediumHeight = measure.bodyMediumHeight;
    final height = _calcCacheHeight(log.payload ?? "");
    return height + bodySmallHeight + 8 + bodyMediumHeight + 40;
  }

  updateLogsThrottler() {
    throttler.call("logs", () {
      final isEquality = logListEquality.equals(
        _logs,
        _logsStateNotifier.value.logs,
      );
      if (isEquality) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
          logs: _logs,
        );
      });
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _handleTryClearCache(constraints.maxWidth - 40);
        return Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<LogsState>(
            valueListenable: _logsStateNotifier,
            builder: (_, state, __) {
              final logs = state.list;
              if (logs.isEmpty) {
                return NullStatus(
                  label: appLocalizations.nullLogsDesc,
                );
              }
              final items = logs
                  .map<Widget>(
                    (log) => LogItem(
                      key: Key(log.dateTime.toString()),
                      log: log,
                      onClick: (value) {
                        context.commonScaffoldState?.addKeyword(value);
                      },
                    ),
                  )
                  .separated(
                    const Divider(
                      height: 0,
                    ),
                  )
                  .toList();
              return NotificationListener<ScrollEndNotification>(
                onNotification: (details) {
                  _preOffset = details.metrics.pixels;
                  return false;
                },
                child: CommonScrollBar(
                  controller: _scrollController,
                  child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    physics: NextClampingScrollPhysics(),
                    controller: _scrollController,
                    itemBuilder: (_, index) {
                      return items[index];
                    },
                    itemExtentBuilder: (index, __) {
                      final item = items[index];
                      if (item.runtimeType == Divider) {
                        return 0;
                      }
                      final log = logs[(index / 2).floor()];
                      return _getItemHeight(log);
                    },
                    itemCount: items.length,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;
  final Function(String)? onClick;

  const LogItem({
    super.key,
    required this.log,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: SelectableText(
        log.payload ?? '',
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "${log.dateTime}",
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: CommonChip(
              onPressed: () {
                if (onClick == null) return;
                onClick!(log.logLevel.name);
              },
              label: log.logLevel.name,
            ),
          ),
        ],
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // 禁用过度滚动效果
  }
}
