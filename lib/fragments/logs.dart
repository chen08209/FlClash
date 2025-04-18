import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class LogsFragment extends ConsumerStatefulWidget {
  const LogsFragment({super.key});

  @override
  ConsumerState<LogsFragment> createState() => _LogsFragmentState();
}

class _LogsFragmentState extends ConsumerState<LogsFragment> with PageMixin {
  final _logsStateNotifier = ValueNotifier<LogsState>(
    LogsState(loading: true),
  );
  late ScrollController _scrollController;

  double _currentMaxWidth = 0;
  final _tag = CacheTag.rules;
  bool _isLoad = false;

  List<Log> _logs = [];

  @override
  void initState() {
    super.initState();
    final position = globalState.cacheScrollPosition[_tag] ?? -1;
    _scrollController = ScrollController(
      initialScrollOffset: position > 0 ? position : double.maxFinite,
    );
    _logs = globalState.appState.logs.list;
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
      logs: _logs,
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
    super.dispose();
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

  double _getItemHeight(Log log) {
    final measure = globalState.measure;
    final bodySmallHeight = measure.bodySmallHeight;
    final bodyMediumHeight = measure.bodyMediumHeight;
    final height = globalState.measure
        .computeTextSize(
          Text(
            log.payload,
            style: context.textTheme.bodyLarge,
          ),
          maxWidth: _currentMaxWidth,
        )
        .height;
    return height + bodySmallHeight + 8 + bodyMediumHeight + 40 + 8;
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
        if (mounted) {
          _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
            logs: _logs,
          );
        }
      });
    }, duration: commonDuration);
  }

  _preLoad() {
    if (_isLoad == true) {
      return;
    }
    _isLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final isMobileView = ref.read(isMobileViewProvider);
      if (isMobileView) {
        await Future.delayed(Duration(milliseconds: 300));
      }
      final parts = _logs.batch(10);
      globalState.cacheHeightMap[_tag] ??= FixedMap(
        _logs.length,
      );
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        await Future(
          () {
            for (final log in part) {
              globalState.cacheHeightMap[_tag]?.updateCacheValue(
                log.payload,
                () => _getItemHeight(log),
              );
            }
          },
        );
      }
      _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
        loading: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _currentMaxWidth = constraints.maxWidth - 40;
        return ValueListenableBuilder<LogsState>(
          valueListenable: _logsStateNotifier,
          builder: (_, state, __) {
            _preLoad();
            final logs = state.list;
            final items = logs
                .map<Widget>(
                  (log) => LogItem(
                    key: Key(log.dateTime),
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
            final content = logs.isEmpty
                ? NullStatus(
                    label: appLocalizations.nullLogsDesc,
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: CommonScrollBar(
                      controller: _scrollController,
                      child: ScrollToEndBox(
                        controller: _scrollController,
                        tag: _tag,
                        dataSource: logs,
                        child: CacheItemExtentListView(
                          tag: _tag,
                          reverse: true,
                          shrinkWrap: true,
                          physics: NextClampingScrollPhysics(),
                          controller: _scrollController,
                          itemBuilder: (_, index) {
                            return items[index];
                          },
                          itemExtentBuilder: (index) {
                            if (index.isOdd) {
                              return 0;
                            }
                            return _getItemHeight(logs[index ~/ 2]);
                          },
                          itemCount: items.length,
                          keyBuilder: (int index) {
                            if (index.isOdd) {
                              return "divider";
                            }
                            return logs[index ~/ 2].payload;
                          },
                        ),
                      ),
                    ),
                  );
            return FadeBox(
              child: state.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : content,
            );
          },
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
        log.payload,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            log.dateTime,
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
