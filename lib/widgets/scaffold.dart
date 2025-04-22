import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chip.dart';

class CommonScaffold extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? sideNavigationBar;
  final Color? backgroundColor;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool? centerTitle;
  final AppBarEditState? appBarEditState;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.sideNavigationBar,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.leading,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle,
    this.appBarEditState,
  });

  CommonScaffold.open({
    Key? key,
    required Widget body,
    required String title,
    required Function onBack,
    required List<Widget> actions,
  }) : this(
          key: key,
          body: body,
          title: title,
          automaticallyImplyLeading: false,
          actions: actions,
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
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<Widget?> _floatingActionButton = ValueNotifier(null);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  final _textController = TextEditingController();

  Function(List<String>)? _onKeywordsUpdate;

  Widget? get _sideNavigationBar => widget.sideNavigationBar;

  set actions(List<Widget> actions) {
    _appBarState.value = _appBarState.value.copyWith(actions: actions);
  }

  bool get _isSearch {
    return _appBarState.value.searchState?.isSearch == true;
  }

  bool get _isEdit {
    return _appBarState.value.editState?.isEdit == true;
  }

  set onKeywordsUpdate(Function(List<String>)? onKeywordsUpdate) {
    _onKeywordsUpdate = onKeywordsUpdate;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(
      AppBarState(
        editState: widget.appBarEditState,
      ),
    );
  }

  updateSearchState(
    AppBarSearchState? Function(AppBarSearchState? state) builder,
  ) {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(
        _appBarState.value.searchState,
      ),
    );
  }

  updateEditState(
    AppBarEditState? Function(AppBarEditState? state) builder,
  ) {
    _appBarState.value = _appBarState.value.copyWith(
      editState: builder(
        _appBarState.value.editState,
      ),
    );
  }

  set floatingActionButton(Widget? floatingActionButton) {
    if (_floatingActionButton.value != floatingActionButton) {
      _floatingActionButton.value = floatingActionButton;
    }
  }

  Widget _buildSearchingAppBarTheme(Widget child) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
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
      ),
      child: child,
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

    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch("");
    }
  }

  _handleClear() {
    if (_textController.text.isNotEmpty) {
      _handleClearInput();
      return;
    }
    updateSearchState(
      (state) => state?.copyWith(
        isSearch: false,
      ),
    );
  }

  _handleExitSearching() {
    _handleClearInput();
    updateSearchState(
      (state) => state?.copyWith(
        isSearch: false,
      ),
    );
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
      _appBarState.value = AppBarState();
      _floatingActionButton.value = null;
      _textController.text = "";
      _keywordsNotifier.value = [];
      _onKeywordsUpdate = null;
    } else if (oldWidget.appBarEditState != widget.appBarEditState) {
      _appBarState.value = _appBarState.value.copyWith(
        editState: widget.appBarEditState,
      );
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

  Widget? _buildLeading() {
    if (_isEdit) {
      return IconButton(
        onPressed: _appBarState.value.editState?.onExit,
        icon: Icon(Icons.close),
      );
    }
    return _isSearch
        ? IconButton(
            onPressed: _handleExitSearching,
            icon: Icon(Icons.arrow_back),
          )
        : widget.leading;
  }

  Widget _buildTitle(AppBarSearchState? startState) {
    return _isSearch
        ? TextField(
            autofocus: true,
            controller: _textController,
            style: context.textTheme.titleLarge,
            onChanged: (value) {
              if (startState != null) {
                startState.onSearch(value);
              }
            },
            decoration: InputDecoration(
              hintText: appLocalizations.search,
            ),
          )
        : Text(
            !_isEdit
                ? widget.title!
                : appLocalizations.selectedCountTitle(
                    "${_appBarState.value.editState?.editCount ?? 0}",
                  ),
          );
  }

  List<Widget> _buildActions(
    bool hasSearch,
    List<Widget> actions,
  ) {
    if (_isSearch) {
      return genActions([
        IconButton(
          onPressed: _handleClear,
          icon: Icon(Icons.close),
        ),
      ]);
    }
    return genActions(
      [
        if (hasSearch)
          IconButton(
            onPressed: () {
              updateSearchState(
                (state) => state?.copyWith(
                  isSearch: true,
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
        ...actions
      ],
    );
  }

  Widget _buildAppBarWrap(Widget appBar) {
    if (_isEdit) {
      return CommonPopScope(
        onPop: () {
          if (_isEdit) {
            _appBarState.value.editState?.onExit();
            return false;
          }
          return true;
        },
        child: appBar,
      );
    }
    return _isSearch ? _buildSearchingAppBarTheme(appBar) : appBar;
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
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
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            widget.appBar ??
                ValueListenableBuilder<AppBarState>(
                  valueListenable: _appBarState,
                  builder: (_, state, __) {
                    return _buildAppBarWrap(
                      AppBar(
                        centerTitle: widget.centerTitle ?? false,
                        automaticallyImplyLeading:
                            widget.automaticallyImplyLeading,
                        leading: _buildLeading(),
                        title: _buildTitle(state.searchState),
                        actions: _buildActions(
                          state.searchState != null,
                          state.actions.isNotEmpty
                              ? state.actions
                              : widget.actions ?? [],
                        ),
                      ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.appBar != null || widget.title != null);
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
      appBar: _buildAppBar(),
      body: body,
      backgroundColor: widget.backgroundColor,
      floatingActionButton: ValueListenableBuilder<Widget?>(
        valueListenable: _floatingActionButton,
        builder: (_, value, __) {
          return IntrinsicWidth(
            child: IntrinsicHeight(
              child: FadeScaleBox(
                child: value ?? SizedBox(),
              ),
            ),
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

List<Widget> genActions(List<Widget> actions, {double? space}) {
  return <Widget>[
    ...actions.separated(
      SizedBox(
        width: space ?? 4,
      ),
    ),
    SizedBox(
      width: 8,
    )
  ];
}
