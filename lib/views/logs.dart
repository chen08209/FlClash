import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> {
  final _logsStateNotifier = ValueNotifier<LogsState>(LogsState());
  late ScrollController _scrollController;

  List<Log> _logs = [];

  @override
  void initState() {
    super.initState();
    _logs = globalState.appState.logs.list;
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(logs: _logs);
    ref.listenManual(logsProvider.select((state) => state.list), (prev, next) {
      if (prev != next) {
        final isEquality = logListEquality.equals(prev, next);
        if (!isEquality) {
          _logs = next;
          updateLogsThrottler();
        }
      }
    });
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        onPressed: () {
          _handleExport();
        },
        icon: const Icon(Icons.save_as_outlined),
      ),
    ];
  }

  void _onSearch(String value) {
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(query: value);
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  void dispose() {
    _logsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final res = await globalState.appController.safeRun<bool>(
      () async {
        return await globalState.appController.exportLogs();
      },
      needLoading: true,
      title: appLocalizations.exportLogs,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.exportSuccess),
    );
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
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

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      actions: _buildActions(),
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      title: appLocalizations.logs,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _logsStateNotifier,
        builder: (_, state, _) {
          final autoScrollToEnd = state.autoScrollToEnd;
          return FadeRotationScaleBox(
            child: FloatingActionButton(
              key: ValueKey(autoScrollToEnd),
              onPressed: () {
                _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
                  autoScrollToEnd: !_logsStateNotifier.value.autoScrollToEnd,
                );
              },
              child: autoScrollToEnd
                  ? const Icon(Icons.block)
                  : const Icon(Icons.vertical_align_top),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<LogsState>(
        valueListenable: _logsStateNotifier,
        builder: (context, state, _) {
          final logs = state.list;
          if (logs.isEmpty) {
            return NullStatus(
              illustration: LogEmptyIllustration(),
              label: appLocalizations.nullTip(appLocalizations.logs),
            );
          }
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
              .separated(const Divider(height: 0))
              .toList();
          return Align(
            alignment: Alignment.topCenter,
            child: ScrollToEndBox(
              onCancelToEnd: () {
                _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
                  autoScrollToEnd: false,
                );
              },
              controller: _scrollController,
              enable: state.autoScrollToEnd,
              dataSource: logs,
              child: CommonScrollBar(
                controller: _scrollController,
                child: SuperListView.builder(
                  physics: NextClampingScrollPhysics(),
                  reverse: true,
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemBuilder: (_, index) {
                    return items[index];
                  },
                  itemCount: items.length,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;
  final Function(String)? onClick;

  const LogItem({super.key, required this.log, this.onClick});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {},
      title: Text(
        log.payload,
        style: context.textTheme.bodyLarge?.copyWith(color: log.logLevel.color),
      ),
      subtitle: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonChip(
                onPressed: () {
                  if (onClick == null) return;
                  onClick!(log.logLevel.name);
                },
                label: log.logLevel.name,
              ),
              Text(
                log.dateTime,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.opacity80,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
