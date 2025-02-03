import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../enum/enum.dart';
import 'chip.dart';

class CommonScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? sideNavigationBar;
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const CommonScaffold({
    super.key,
    required this.body,
    this.sideNavigationBar,
    this.bottomNavigationBar,
    this.leading,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  CommonScaffold.open({
    Key? key,
    required Widget body,
    required String title,
    required Function onBack,
  }) : this(
          key: key,
          body: body,
          title: title,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () {
              onBack();
            },
          ),
        );

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  final ValueNotifier<CommonAppBarState> _appBarState =
      ValueNotifier(CommonAppBarState());
  final ValueNotifier<Widget?> _floatingActionButton = ValueNotifier(null);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  final _textController = TextEditingController();

  Function(List<String>)? _onKeywordsUpdate;

  Widget? get _sideNavigationBar => widget.sideNavigationBar;

  set actions(List<Widget> actions) {
    _appBarState.value = _appBarState.value.copyWith(actions: actions);
  }

  set onSearch(Function(String)? onSearch) {
    _appBarState.value = _appBarState.value.copyWith(onSearch: onSearch);
  }

  set onKeywordsUpdate(Function(List<String>)? onKeywordsUpdate) {
    _onKeywordsUpdate = onKeywordsUpdate;
  }

  set _searching(bool searching) {
    _appBarState.value = _appBarState.value.copyWith(searching: searching);
  }

  set floatingActionButton(Widget? floatingActionButton) {
    if (_floatingActionButton.value != floatingActionButton) {
      _floatingActionButton.value = floatingActionButton;
    }
  }

  ThemeData _appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        systemOverlayStyle: colorScheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarTextStyle: theme.textTheme.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.inputDecorationTheme.hintStyle,
        border: InputBorder.none,
      ),
    );
  }

  Future<T?> loadingRun<T>(
    Future<T> Function() futureFunction, {
    String? title,
  }) async {
    _loading.value = true;
    try {
      final res = await futureFunction();
      _loading.value = false;
      return res;
    } catch (e) {
      globalState.showMessage(
        title: title ?? appLocalizations.tip,
        message: TextSpan(
          text: e.toString(),
        ),
      );
      _loading.value = false;
      return null;
    }
  }

  _handleClearInput() {
    _textController.text = "";

    if (_appBarState.value.onSearch != null) {
      _appBarState.value.onSearch!("");
    }
  }

  _handleClear() {
    if (_textController.text.isNotEmpty) {
      _handleClearInput();
      return;
    }
    _searching = false;
  }

  _handleExitSearching() {
    _handleClearInput();
    _searching = false;
  }

  @override
  void dispose() {
    _appBarState.dispose();
    _textController.dispose();
    _floatingActionButton.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _appBarState.value = CommonAppBarState();
      _floatingActionButton.value = null;
      _textController.text = "";
      _keywordsNotifier.value = [];
      _onKeywordsUpdate = null;
    }
  }

  addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)..add(keyword);
    _keywordsNotifier.value = keywords;
  }

  _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)
      ..remove(keyword);
    _keywordsNotifier.value = keywords;
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: _keywordsNotifier,
            builder: (_, keywords, __) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_onKeywordsUpdate != null) {
                  _onKeywordsUpdate!(keywords);
                }
              });
              if (keywords.isEmpty) {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final keyword in keywords)
                      CommonChip(
                        label: keyword,
                        type: ChipType.delete,
                        onPressed: () {
                          _deleteKeyword(keyword);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: widget.body,
          ),
        ],
      ),
    );
    final scaffold = Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ValueListenableBuilder<CommonAppBarState>(
              valueListenable: _appBarState,
              builder: (_, state, __) {
                final realActions = [
                  if (state.onSearch != null)
                    IconButton(
                      onPressed: () {
                        _searching = true;
                      },
                      icon: Icon(Icons.search),
                    ),
                  ...state.actions.isNotEmpty
                      ? state.actions
                      : widget.actions ?? []
                ];
                final appBar = AppBar(
                  centerTitle: false,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                    systemNavigationBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                    systemNavigationBarColor: widget.bottomNavigationBar != null
                        ? context.colorScheme.surfaceContainer
                        : context.colorScheme.surface,
                    systemNavigationBarDividerColor: Colors.transparent,
                  ),
                  automaticallyImplyLeading: widget.automaticallyImplyLeading,
                  leading: state.searching
                      ? IconButton(
                          onPressed: _handleExitSearching,
                          icon: Icon(Icons.arrow_back),
                        )
                      : widget.leading,
                  title: state.searching
                      ? TextField(
                          autofocus: true,
                          controller: _textController,
                          style: context.textTheme.titleLarge,
                          onChanged: (value) {
                            if (state.onSearch != null) {
                              state.onSearch!(value);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: appLocalizations.search,
                          ),
                        )
                      : Text(widget.title),
                  actions: [
                    if (state.searching)
                      IconButton(
                        onPressed: _handleClear,
                        icon: Icon(Icons.close),
                      )
                    else
                      ...realActions.separated(
                        SizedBox(
                          width: 4,
                        ),
                      ),
                    SizedBox(
                      width: 8,
                    )
                  ],
                );
                return FadeBox(
                  child: state.searching
                      ? Theme(
                          data: _appBarTheme(context),
                          child: PopScope(
                            canPop: false,
                            onPopInvokedWithResult: (didPop, __) {
                              if (didPop) {
                                return;
                              }
                              if (state.searching) {
                                _handleExitSearching();
                                return;
                              }
                              Navigator.of(context).pop();
                            },
                            child: appBar,
                          ),
                        )
                      : appBar,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _loading,
              builder: (_, value, __) {
                return value == true
                    ? const LinearProgressIndicator()
                    : Container();
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: ValueListenableBuilder<Widget?>(
        valueListenable: _floatingActionButton,
        builder: (_, value, __) {
          return FadeScaleBox(
            child: value ?? SizedBox(),
          );
        },
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
    return _sideNavigationBar != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sideNavigationBar!,
              Expanded(
                flex: 1,
                child: scaffold,
              ),
            ],
          )
        : scaffold;
  }
}
