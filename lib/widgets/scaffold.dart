import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:flutter/material.dart';

import 'chip.dart';

typedef OnKeywordsUpdateCallback = void Function(List<String> keywords);

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class CommonScaffold extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;
  final AppBarEditState? editState;
  final AppBarSearchState? searchState;
  final OnKeywordsUpdateCallback? onKeywordsUpdate;
  final bool? resizeToAvoidBottomInset;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.title,
    this.actions,
    this.centerTitle,
    this.editState,
    this.searchState,
    this.floatingActionButton,
    this.onKeywordsUpdate,
    this.resizeToAvoidBottomInset,
  });

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<Widget?> _floatingActionButton = ValueNotifier(null);
  final ValueNotifier<bool> _loadingVisible = ValueNotifier(false);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final _textController = TextEditingController();

  bool get _isSearch {
    return _appBarState.value.searchState?.query != null;
  }

  bool get _isEdit {
    final editState = _appBarState.value.editState;
    if (editState == null) {
      return false;
    }
    return editState.editCount > 0;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(
      AppBarState(editState: widget.editState, searchState: widget.searchState),
    );
  }

  Future<void> _updateSearchState(AppBarSearchStateBuilder builder) async {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(_appBarState.value.searchState),
    );
  }

  void handleToSearch() {
    _updateSearchState((state) => state?.copyWith(query: ''));
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

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editState != widget.editState) {
      _appBarState.value = _appBarState.value.copyWith(
        editState: widget.editState,
      );
    }
    if (oldWidget.searchState != widget.searchState) {
      _appBarState.value = _appBarState.value.copyWith(
        searchState: widget.searchState,
      );
    }
  }

  void _handleClearInput() {
    _textController.text = '';
    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch('');
    }
  }

  void _handleClear() {
    if (_textController.text.isNotEmpty) {
      _handleClearInput();
      return;
    }
    _updateSearchState((state) => state?.copyWith(query: null));
  }

  void handleExitSearching() {
    if (!_isSearch) {
      return;
    }
    _handleClearInput();
    _updateSearchState((state) => state?.copyWith(query: null));
  }

  @override
  void dispose() {
    _appBarState.dispose();
    _textController.dispose();
    _floatingActionButton.dispose();
    _loadingVisible.dispose();
    super.dispose();
  }

  void addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)..add(keyword);
    _keywordsNotifier.value = keywords;
  }

  void _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)
      ..remove(keyword);
    _keywordsNotifier.value = keywords;
  }

  Widget? _buildLeading(VoidCallback? backAction) {
    if (_isEdit) {
      return IconButton(
        onPressed: _appBarState.value.editState?.onExit,
        icon: Icon(Icons.close),
      );
    }
    if (_isSearch) {
      return IconButton(
        onPressed: handleExitSearching,
        icon: Icon(Icons.arrow_back),
      );
    }
    return backAction != null
        ? BackButton(
            onPressed: () {
              if (!mounted) {
                return;
              }
              backAction();
            },
          )
        : null;
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
            decoration: InputDecoration(hintText: appLocalizations.search),
          )
        : Text(
            !_isEdit
                ? widget.title!
                : appLocalizations.selectedCountTitle(
                    '${_appBarState.value.editState?.editCount ?? 0}',
                  ),
          );
  }

  List<Widget> _buildActions(bool hasSearch, List<Widget> actions) {
    if (_isSearch) {
      return genActions([
        IconButton(onPressed: _handleClear, icon: Icon(Icons.close)),
      ]);
    }
    return genActions([
      if (hasSearch && widget.searchState?.autoAddSearch == true)
        IconButton(
          onPressed: () {
            _updateSearchState((state) => state?.copyWith(query: ''));
          },
          icon: Icon(Icons.search),
        ),
      ...actions,
    ]);
  }

  Widget _buildAppBarWrap(Widget child) {
    final appBar = _isSearch ? _buildSearchingAppBarTheme(child) : child;
    if (_isEdit || _isSearch) {
      return SystemBackBlock(
        child: CommonPopScope(
          onPop: (context) {
            if (_isEdit || _isSearch) {
              handleExitSearching();
              _appBarState.value.editState?.onExit();
              return false;
            }
            return true;
          },
          child: appBar,
        ),
      );
    }
    return appBar;
  }

  PreferredSizeWidget _buildAppBar(VoidCallback? backAction) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          widget.appBar ??
              ValueListenableBuilder<AppBarState>(
                valueListenable: _appBarState,
                builder: (_, state, _) {
                  return _buildAppBarWrap(
                    AppBar(
                      automaticallyImplyLeading: backAction != null
                          ? false
                          : true,
                      animateColor: true,
                      centerTitle: widget.centerTitle ?? false,
                      leading: _buildLeading(backAction),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.appBar != null || widget.title != null);
    final backActionProvider = CommonScaffoldBackActionProvider.of(context);
    final body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: _keywordsNotifier,
            builder: (_, keywords, _) {
              if (widget.onKeywordsUpdate != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onKeywordsUpdate!(keywords);
                });
              }
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
          Expanded(child: widget.body),
        ],
      ),
    );
    return Scaffold(
      appBar: _buildAppBar(backActionProvider?.backAction),
      body: body,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      backgroundColor: widget.backgroundColor,
      floatingActionButton:
          widget.floatingActionButton ??
          ValueListenableBuilder<Widget?>(
            valueListenable: _floatingActionButton,
            builder: (_, value, _) {
              return value ?? SizedBox();
            },
          ),
    );
  }
}

List<Widget> genActions(List<Widget> actions, {double? space}) {
  return <Widget>[
    ...actions.separated(SizedBox(width: space ?? 4)),
    SizedBox(width: 8),
  ];
}

class CommonScaffoldBackActionProvider extends InheritedWidget {
  final VoidCallback? backAction;

  const CommonScaffoldBackActionProvider({
    super.key,
    required this.backAction,
    required super.child,
  });

  static CommonScaffoldBackActionProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CommonScaffoldBackActionProvider>();
  }

  @override
  bool updateShouldNotify(CommonScaffoldBackActionProvider oldWidget) =>
      backAction != oldWidget.backAction;
}

class BaseScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.title,
    this.actions = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(body: body, title: title, actions: actions);
  }
}
