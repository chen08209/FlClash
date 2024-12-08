import 'dart:async';
import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestsFragment extends StatefulWidget {
  const RequestsFragment({super.key});

  @override
  State<RequestsFragment> createState() => _RequestsFragmentState();
}

class _RequestsFragmentState extends State<RequestsFragment> {
  final requestsNotifier =
      ValueNotifier<ConnectionsAndKeywords>(const ConnectionsAndKeywords());
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = globalState.appController.appState;
      requestsNotifier.value =
          requestsNotifier.value.copyWith(connections: appState.requests);
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        final maxLength = Platform.isAndroid ? 1000 : 60;
        final requests = appState.requests.safeSublist(
          appState.requests.length - maxLength,
        );
        if (!connectionListEquality.equals(
          requestsNotifier.value.connections,
          requests,
        )) {
          requestsNotifier.value =
              requestsNotifier.value.copyWith(connections: requests);
        }
      });
    });
  }

  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final commonScaffoldState =
            context.findAncestorStateOfType<CommonScaffoldState>();
        commonScaffoldState?.actions = [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: RequestsSearchDelegate(
                  state: requestsNotifier.value,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ];
      },
    );
  }

  _addKeyword(String keyword) {
    final isContains = requestsNotifier.value.keywords.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(requestsNotifier.value.keywords)
      ..add(keyword);
    requestsNotifier.value = requestsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  _deleteKeyword(String keyword) {
    final isContains = requestsNotifier.value.keywords.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(requestsNotifier.value.keywords)
      ..remove(keyword);
    requestsNotifier.value = requestsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _scrollController.dispose();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool?>(
      selector: (_, appState) =>
          appState.currentLabel == 'requests' ||
          appState.viewMode == ViewMode.mobile &&
              appState.currentLabel == "tools",
      builder: (_, isCurrent, child) {
        if (isCurrent == null || isCurrent) {
          _initActions();
        }
        return child!;
      },
      child: ValueListenableBuilder<ConnectionsAndKeywords>(
        valueListenable: requestsNotifier,
        builder: (_, state, __) {
          var connections = state.filteredConnections;
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullRequestsDesc,
            );
          }
          connections = connections.reversed.toList();
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
                    runSpacing: 6,
                    spacing: 6,
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
                  controller: _scrollController,
                  itemBuilder: (_, index) {
                    final connection = connections[index];
                    return ConnectionItem(
                      key: Key(connection.id),
                      connection: connection,
                      onClick: _addKeyword,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 0,
                    );
                  },
                  itemCount: connections.length,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class RequestsSearchDelegate extends SearchDelegate {
  ValueNotifier<ConnectionsAndKeywords> requestsNotifier;

  RequestsSearchDelegate({
    required ConnectionsAndKeywords state,
  }) : requestsNotifier = ValueNotifier<ConnectionsAndKeywords>(state);

  get state => requestsNotifier.value;

  List<Connection> get _results {
    final lowerQuery = query.toLowerCase().trim();
    return requestsNotifier.value.filteredConnections.where((request) {
      final lowerNetwork = request.metadata.network.toLowerCase();
      final lowerHost = request.metadata.host.toLowerCase();
      final lowerDestinationIP = request.metadata.destinationIP.toLowerCase();
      final lowerProcess = request.metadata.process.toLowerCase();
      final lowerChains = request.chains.join("").toLowerCase();
      return lowerNetwork.contains(lowerQuery) ||
          lowerHost.contains(lowerQuery) ||
          lowerDestinationIP.contains(lowerQuery) ||
          lowerProcess.contains(lowerQuery) ||
          lowerChains.contains(lowerQuery);
    }).toList();
  }

  _addKeyword(String keyword) {
    final isContains = requestsNotifier.value.keywords.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(requestsNotifier.value.keywords)
      ..add(keyword);
    requestsNotifier.value = requestsNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  _deleteKeyword(String keyword) {
    final isContains = requestsNotifier.value.keywords.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(requestsNotifier.value.keywords)
      ..remove(keyword);
    requestsNotifier.value = requestsNotifier.value.copyWith(
      keywords: keywords,
    );
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

  @override
  void dispose() {
    requestsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: requestsNotifier,
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
                  runSpacing: 6,
                  spacing: 6,
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
                  final connection = _results[index];
                  return ConnectionItem(
                    key: Key(connection.id),
                    connection: connection,
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
