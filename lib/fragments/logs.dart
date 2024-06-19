import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class LogsFragment extends StatefulWidget {
  const LogsFragment({super.key});

  @override
  State<LogsFragment> createState() => _LogsFragmentState();
}

class _LogsFragmentState extends State<LogsFragment> {
  final logsNotifier = ValueNotifier<LogsAndKeywords>(const LogsAndKeywords());
  final scrollController = ScrollController(
    keepScrollOffset: false,
  );
  List<GlobalObjectKey<_LogItemState>> keys = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = globalState.appController.appState;
      logsNotifier.value = logsNotifier.value.copyWith(logs: appState.logs);
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        final logs = appState.logs;
        if (!const ListEquality<Log>().equals(
          logsNotifier.value.logs,
          logs,
        )) {
          logsNotifier.value = logsNotifier.value.copyWith(logs: logs);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    logsNotifier.dispose();
    scrollController.dispose();
    timer = null;
  }

  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      commonScaffoldState?.actions = [
        IconButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: LogsSearchDelegate(
                logs: logsNotifier.value,
              ),
            );
          },
          icon: const Icon(Icons.search),
        ),
        const SizedBox(
          width: 8,
        )
      ];
    });
  }

  _addKeyword(String keyword) {
    final isContains = logsNotifier.value.keywords.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(logsNotifier.value.keywords)
      ..add(keyword);
    logsNotifier.value = logsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  _deleteKeyword(String keyword) {
    final isContains = logsNotifier.value.keywords.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(logsNotifier.value.keywords)
      ..remove(keyword);
    logsNotifier.value = logsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool?>(
      selector: (_, appState) =>
          appState.currentLabel == 'logs' ||
          appState.viewMode == ViewMode.mobile &&
              appState.currentLabel == "tools",
      builder: (_, isCurrent, child) {
        if (isCurrent == null || isCurrent) {
          _initActions();
        }
        return child!;
      },
      child: ValueListenableBuilder<LogsAndKeywords>(
        valueListenable: logsNotifier,
        builder: (_, state, __) {
          var logs = state.filteredLogs;
          if (logs.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullLogsDesc,
            );
          }
          logs = logs.reversed.toList();
          keys = logs
              .map((log) => GlobalObjectKey<_LogItemState>(log.dateTime))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.keywords.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final keyword in state.keywords)
                        CommonChip(
                          label: keyword,
                          type: ChipType.delete,
                          onPressed: () {
                            _deleteKeyword(keyword);
                          },
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemBuilder: (_, index) {
                    final log = logs[index];
                    return LogItem(
                      key: Key(log.dateTime.toString()),
                      log: log,
                      onClick: _addKeyword,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 0,
                    );
                  },
                  itemCount: logs.length,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class LogsSearchDelegate extends SearchDelegate {
  ValueNotifier<LogsAndKeywords> logsNotifier;

  LogsSearchDelegate({
    required LogsAndKeywords logs,
  }) : logsNotifier = ValueNotifier(logs);

  @override
  void dispose() {
    super.dispose();
    logsNotifier.dispose();
  }

  get state => logsNotifier.value;

  List<Log> get _results {
    final lowQuery = query.toLowerCase();
    return logsNotifier.value.filteredLogs
        .where(
          (log) =>
              (log.payload?.toLowerCase().contains(lowQuery) ?? false) ||
              log.logLevel.name.contains(lowQuery),
        )
        .toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
            return;
          }
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
      const SizedBox(
        width: 8,
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  _addKeyword(String keyword) {
    final isContains = logsNotifier.value.keywords.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(logsNotifier.value.keywords)..add(keyword);
    logsNotifier.value = logsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  _deleteKeyword(String keyword) {
    final isContains = logsNotifier.value.keywords.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(logsNotifier.value.keywords)..remove(keyword);
    logsNotifier.value = logsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: logsNotifier,
      builder: (_, __, ___) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.keywords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final keyword in state.keywords)
                      CommonChip(
                        label: keyword,
                        type: ChipType.delete,
                        onPressed: () {
                          _deleteKeyword(keyword);
                        },
                      ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, index) {
                  final log = _results[index];
                  return LogItem(
                    key: Key(log.dateTime.toString()),
                    log: log,
                    onClick: (value) {
                      _addKeyword(value);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 0,
                  );
                },
                itemCount: _results.length,
              ),
            )
          ],
        );
      },
    );
  }
}

class LogItem extends StatefulWidget {
  final Log log;
  final Function(String)? onClick;

  const LogItem({
    super.key,
    required this.log,
    this.onClick,
  });

  @override
  State<LogItem> createState() => _LogItemState();
}

class _LogItemState extends State<LogItem> {
  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    return ListTile(
      title: SelectableText(log.payload ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
            ),
            child: SelectableText(
              "${log.dateTime}",
              style: context.textTheme.bodySmall
                  ?.copyWith(color: context.colorScheme.primary),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: CommonChip(
              onPressed: () {
                if (widget.onClick == null) return;
                widget.onClick!(log.logLevel.name);
              },
              label: log.logLevel.name,
            ),
          ),
        ],
      ),
    );
  }
}
