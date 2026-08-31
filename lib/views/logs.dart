import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class LogListController extends ValueNotifier<LogsState> {
  LogListController() : super(const LogsState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void updateKeywords(List<String> keywords) {
    value = value.copyWith(keywords: keywords);
  }

  void setLogs(List<Log> logs) {
    if (identical(logs, value.logs)) {
      return;
    }
    value = value.copyWith(
      logs: value.autoScrollToEnd
          ? logs
          : retainTrimmedHead(value.logs, logs, pausedMaxLogsLength),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<Log> logs) {
    value = value.copyWith(autoScrollToEnd: true, logs: logs);
  }
}

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> {
  final _listController = LogListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _listController.setLogs(ref.read(logsProvider).list);
    ref.listenManual(logsProvider.select((state) => state.revision), (_, _) {
      updateLogsThrottler();
    });
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        tooltip: context.appLocalizations.exportLogs,
        onPressed: () {
          _handleExport();
        },
        icon: const Icon(Icons.save_as_outlined),
      ),
    ];
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      return ref.read(logsProvider.notifier).exportLogs();
    }, title: appLocalizations.exportLogs);
    if (res != true) return;
    unawaited(
      dialogs.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.exportSuccess),
      ),
    );
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
      _listController.setLogs(ref.read(logsProvider).list);
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      actions: _buildActions(),
      onKeywordsUpdate: _listController.updateKeywords,
      searchState: AppBarSearchState(onSearch: _listController.search),
      title: appLocalizations.logs,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _listController,
        builder: (_, state, _) {
          final autoScrollToEnd = state.autoScrollToEnd;
          return FadeRotationScaleBox(
            child: FloatingActionButton(
              key: ValueKey(autoScrollToEnd),
              onPressed: () {
                if (autoScrollToEnd) {
                  _listController.setAutoScrollToEnd(false);
                } else {
                  _listController.resumeAutoScrollToEnd(
                    ref.read(logsProvider).list,
                  );
                }
              },
              child: autoScrollToEnd
                  ? const Icon(Icons.block)
                  : const Icon(Icons.vertical_align_top),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<LogsState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final logs = state.list;
          if (logs.isEmpty) {
            return NullStatus(
              illustration: const LogEmptyIllustration(),
              label: appLocalizations.nullTip(appLocalizations.logs),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: FloatingScrollbar(
              controller: _scrollController,
              hintBuilder: (fraction) {
                final index = (fraction * (logs.length - 1)).round();
                return logs[index].dateTime;
              },
              child: ScrollToEndBox(
                onCancelToEnd: () {
                  _listController.setAutoScrollToEnd(false);
                },
                controller: _scrollController,
                enable: state.autoScrollToEnd,
                dataSource: logs,
                child: SuperListView.separated(
                  physics: const NextClampingScrollPhysics(),
                  reverse: true,
                  shrinkWrap: true,
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: 16 + BottomInsetScope.of(context),
                  ),
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (_, index) {
                    final log = logs[index];
                    return LogItem(
                      log: log,
                      onClick: (value) {
                        context.commonScaffoldState?.addKeyword(value);
                      },
                    );
                  },
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ).copyWith(bottom: 12),
      onTap: () {},
      minVerticalPadding: 0,
      title: SelectableText(
        log.payload,
        style: context.textTheme.bodyLarge?.copyWith(
          color: log.logLevel.color(context),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonChip(
              label: log.logLevel.name,
              onPressed: () => onClick?.call(log.logLevel.name),
            ),
            Flexible(
              child: Text(
                log.dateTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
