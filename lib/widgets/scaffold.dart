import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'button.dart';
import 'chip.dart';
import 'inherited.dart';
import 'loading.dart';
import 'navigation_dock.dart';
import 'popup.dart';
import 'search_field.dart';
import 'sheet.dart';
import 'sheet_header.dart';

typedef OnKeywordsUpdateCallback = void Function(List<String> keywords);

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class CommonScaffold extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final bool isLoading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;

  /// The page's main action. A page shows it as its floating action button;
  /// a bottom sheet, and a phone's home page whose foot the navigation dock
  /// holds, show it in the bar instead.
  final IconButtonData? primaryAction;

  /// Folded into the overflow menu once the bar would hold more than two
  /// buttons, as [primaryAction] and [menuItems] are; [actions] never fold.
  final List<IconButtonData> iconActions;
  final List<CommonPopupMenuItem> menuItems;

  /// Folds [primaryAction] ahead of [iconActions], so a bar without search
  /// keeps the first of them in sight instead.
  final bool foldPrimaryAction;
  final bool? isTV;
  final AppBarEditState? editState;
  final AppBarSearchState? searchState;
  final List<IconButtonData> searchActions;
  final OnKeywordsUpdateCallback? onKeywordsUpdate;
  final bool? resizeToAvoidBottomInset;
  final VoidCallback? backAction;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.title,
    this.actions,
    this.centerTitle,
    this.backAction,
    this.editState,
    this.isLoading = false,
    this.searchState,
    this.searchActions = const [],
    this.floatingActionButton,
    this.primaryAction,
    this.iconActions = const [],
    this.menuItems = const [],
    this.foldPrimaryAction = false,
    this.isTV,
    this.onKeywordsUpdate,
    this.resizeToAvoidBottomInset,
  });

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isFabExtendedNotifier = ValueNotifier(true);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final _textController = TextEditingController();
  final _searchFocusNode = FocusNode();

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

  bool get _hasActions {
    return _appBarState.value.searchState != null ||
        widget.primaryAction != null ||
        widget.iconActions.isNotEmpty ||
        widget.menuItems.isNotEmpty ||
        widget.actions?.isNotEmpty == true;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(
      AppBarState(editState: widget.editState, searchState: widget.searchState),
    );
    _loadingNotifier.value = widget.isLoading;
    HardwareKeyboard.instance.addHandler(_handleSearchShortcut);
  }

  Future<void> _updateSearchState(AppBarSearchStateBuilder builder) async {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(_appBarState.value.searchState),
    );
  }

  void _handleToSearch() {
    _updateSearchState((state) => state?.copyWith(query: ''));
  }

  bool _handleSearchShortcut(KeyEvent event) {
    if (event is! KeyDownEvent ||
        _appBarState.value.searchState == null ||
        _isEdit ||
        !controlSingleActivator(
          LogicalKeyboardKey.keyF,
        ).accepts(event, HardwareKeyboard.instance) ||
        !_isFrontmost) {
      return false;
    }
    if (_isSearch || context.isInBottomSheet) {
      _searchFocusNode.requestFocus();
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    } else {
      _handleToSearch();
    }
    return true;
  }

  // Kept-alive pages and pages under another route stay mounted too.
  bool get _isFrontmost {
    if (!mounted ||
        context.getInheritedWidgetOfExactType<PageActivityScope>()?.isActive ==
            false) {
      return false;
    }
    BuildContext? current = context;
    while (current != null && current.mounted) {
      final route = ModalRoute.of(current);
      if (route == null) {
        return true;
      }
      if (!route.isCurrent) {
        return false;
      }
      current = route.navigator?.context;
    }
    return true;
  }

  Color get _searchingBackgroundColor =>
      context.colorScheme.brightness == Brightness.dark
      ? Colors.grey.shade900
      : Colors.white;

  Widget _buildSearchingAppBarTheme(Widget child) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: _searchingBackgroundColor,
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
      },
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
    if (oldWidget.isLoading != widget.isLoading) {
      _loadingNotifier.value = widget.isLoading;
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
    _popAppBarLayer();
  }

  void handleExitSearching() {
    if (!_isSearch) {
      return;
    }
    _handleClearInput();
    _updateSearchState((state) => state?.copyWith(query: null));
  }

  void _handleExitAppBarLayer() {
    handleExitSearching();
    if (_isEdit) {
      _appBarState.value.editState?.onExit();
    }
  }

  void _popAppBarLayer() {
    if (!_isEdit && !_isSearch) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleSearchShortcut);
    _appBarState.dispose();
    _textController.dispose();
    _searchFocusNode.dispose();
    _isFabExtendedNotifier.dispose();
    _loadingNotifier.dispose();
    _keywordsNotifier.dispose();
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

  Widget _buildDockedSearch(AppBarSearchState searchState) {
    final theme = Theme.of(context);
    final fieldPadding =
        (BottomInsetScope.dockedSearchHeight -
            globalState.measure.bodyLargeHeight) /
        2;
    return Padding(
      padding: EdgeInsets.only(
        left: BottomInsetScope.dockedSearchMargin,
        right: BottomInsetScope.dockedSearchMargin,
        bottom:
            BottomInsetScope.dockedSearchMargin +
            MediaQuery.paddingOf(context).bottom,
      ),
      // Filled, so the field carries its own surface and the list runs under
      // it rather than under a band the width of the sheet.
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            border: AppShape.input.copyWith(borderRadius: AppRadius.full),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: fieldPadding,
            ),
          ),
        ),
        child: SearchField(
          controller: _textController,
          focusNode: _searchFocusNode,
          onChanged: searchState.onSearch,
        ),
      ),
    );
  }

  Widget _buildSheetPopButton(
    VoidCallback? backAction, {
    required bool useCloseIcon,
  }) {
    final appLocalizations = context.appLocalizations;
    return AppBarActionButton(
      data: useCloseIcon
          ? IconButtonData(
              glyph: AppGlyphs.close,
              onPressed: context.safeNestedPop,
              tooltip: appLocalizations.close,
            )
          : IconButtonData(
              glyph: AppGlyphs.backFor(Theme.of(context).platform),
              onPressed: backAction ?? () => Navigator.of(context).pop(),
              tooltip: appLocalizations.back,
            ),
    );
  }

  Widget? _buildLeading(VoidCallback? backAction, {required _SheetPop? pop}) {
    final button = _buildLeadingButton(backAction, pop: pop);
    return button == null ? null : Center(child: ElasticPress(child: button));
  }

  Widget? _buildLeadingButton(
    VoidCallback? backAction, {
    required _SheetPop? pop,
  }) {
    if (_isEdit) {
      return IconButton(
        tooltip: context.appLocalizations.close,
        onPressed: _popAppBarLayer,
        icon: const GlyphIcon(AppGlyphs.close),
      );
    }
    if (_isSearch) {
      return IconButton(
        tooltip: context.appLocalizations.back,
        onPressed: _popAppBarLayer,
        icon: const GlyphIcon(AppGlyphs.arrowBack),
      );
    }
    if (pop != null) {
      return pop.asSuffix
          ? null
          : _buildSheetPopButton(backAction, useCloseIcon: pop.useCloseIcon);
    }
    if (backAction != null) {
      return BackButton(
        onPressed: () {
          if (!mounted) {
            return;
          }
          backAction();
        },
      );
    }
    final route = ModalRoute.of(context);
    if (route?.impliesAppBarDismissal != true) {
      return null;
    }
    return route is PageRoute && route.fullscreenDialog
        ? const CloseButton()
        : const BackButton();
  }

  Widget _buildTitle(AppBarSearchState? startState) {
    final appLocalizations = context.appLocalizations;
    return _isSearch
        ? TextField(
            autofocus: true,
            controller: _textController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            inputFormatters: TextInputLimits.limit(TextInputLimits.search),
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

  List<Widget> _buildActions(
    bool hasSearch,
    IconButtonData? primaryAction,
    VoidCallback? backAction,
    _SheetForm form,
  ) {
    final appLocalizations = context.appLocalizations;
    final pop = form.pop;
    final lead = _isSearch
        ? IconButtonData(
            glyph: AppGlyphs.close,
            tooltip: appLocalizations.clearSearch,
            onPressed: _handleClear,
          )
        : hasSearch && !form.hasDockedSearch
        ? IconButtonData(
            glyph: AppGlyphs.search,
            tooltip: appLocalizations.search,
            onPressed: _handleToSearch,
          )
        : null;
    final widgets = _isSearch
        ? const <Widget>[]
        : widget.actions ?? const <Widget>[];
    final fold = _isSearch
        ? _foldBarActions(hasLead: true, icons: widget.searchActions)
        : _foldBarActions(
            hasLead: lead != null,
            primary: primaryAction,
            foldPrimary: widget.foldPrimaryAction,
            icons: widget.iconActions,
            widgetCount: widgets.length,
            menuItems: widget.menuItems,
          );
    final popAsSuffix = !_isSearch && !_isEdit && pop?.asSuffix == true;
    final shown = [?lead, ...fold.shown];
    final overflow = fold.overflow.isEmpty
        ? null
        : _OverflowMenuButton(items: fold.overflow);
    if (widgets.isEmpty &&
        !popAsSuffix &&
        shown.length + (overflow == null ? 0 : 1) == 2) {
      return genActions([
        AppBarButtonGroup(
          children: [
            for (final data in shown) AppBarActionButton(data: data),
            ?overflow,
          ],
        ),
      ], edge: AppBarActionEdge.container);
    }
    return genActions([
      for (final data in shown)
        ElasticPress(
          enabled: !data.isLoading,
          child: AppBarActionButton(data: data),
        ),
      for (final action in widgets) ElasticPress(child: action),
      if (overflow != null) ElasticPress(child: overflow),
      if (popAsSuffix)
        ElasticPress(
          child: _buildSheetPopButton(
            backAction,
            useCloseIcon: pop!.useCloseIcon,
          ),
        ),
    ], edge: AppBarActionEdge.container);
  }

  Widget _buildAppBarWrap(Widget child) {
    final appBar = _BarButtonTheme(
      child: _isSearch ? _buildSearchingAppBarTheme(child) : child,
    );
    if (_isEdit || _isSearch) {
      return BackLayerScope(onBack: _handleExitAppBarLayer, child: appBar);
    }
    return appBar;
  }

  PreferredSizeWidget _buildAppBar(
    VoidCallback? backAction,
    _SheetForm form, {
    required IconButtonData? primaryAction,
  }) {
    final isBottomSheet = form.isBottomSheet;
    final ownBar = widget.appBar;
    return PreferredSize(
      preferredSize: Size.fromHeight(
        isBottomSheet ? sheetToolbarHeight : kToolbarHeight,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (ownBar != null)
            _BarButtonTheme(child: ownBar)
          else
            ValueListenableBuilder<AppBarState>(
              valueListenable: _appBarState,
              builder: (_, state, _) {
                final appBar = _buildAppBarWrap(
                  AppBar(
                    clipBehavior: Clip.none,
                    automaticallyImplyLeading: false,
                    animateColor: true,
                    // A searching bar carries its own opaque theme.
                    forceMaterialTransparency: isBottomSheet || !_isSearch,
                    toolbarHeight: isBottomSheet ? sheetToolbarHeight : null,
                    centerTitle: widget.centerTitle ?? isBottomSheet,
                    titleTextStyle: isBottomSheet
                        ? context.textTheme.titleLarge?.adjustSize(-4)
                        : null,
                    leading: _buildLeading(backAction, pop: form.pop),
                    title: _buildTitle(state.searchState),
                    actions: _buildActions(
                      state.searchState != null,
                      primaryAction,
                      backAction,
                      form,
                    ),
                  ),
                );
                if (isBottomSheet) {
                  return appBar;
                }
                final top = MediaQuery.paddingOf(context).top;
                return FloatingHeader(
                  backgroundColor:
                      widget.backgroundColor ?? context.colorScheme.surface,
                  fadeStart:
                      (top + kToolbarHeight / 2) / (top + kToolbarHeight),
                  child: appBar,
                );
              },
            ),
          ValueListenableBuilder(
            valueListenable: _loadingNotifier,
            builder: (_, value, _) {
              return value == true
                  ? const LinearProgressIndicator()
                  : Container();
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
    final backAction = widget.backAction ?? backActionProvider?.backAction;
    final form = _SheetForm.of(
      context,
      hasOwnBar: widget.appBar != null,
      searchState: widget.searchState,
      hasActions: _hasActions,
    );
    final isBottomSheet = form.isBottomSheet;
    final isTV = widget.isTV ?? system.isTV;
    final bottomInset = BottomInsetScope.of(context);
    final primaryAction = widget.primaryAction;
    final actionInBar =
        form.isBottomSheet || (!isTV && DockedPageScope.of(context));
    final fabSlot = actionInBar
        ? null
        : widget.floatingActionButton ??
              (primaryAction == null
                  ? null
                  : _PrimaryActionFab(data: primaryAction));
    final hasFab = !isTV && fabSlot != null;
    // A snap sheet fills the height its detent gives it and clips its own
    // corners; any other bottom sheet sizes to its content and brings both.
    final hugsContent = isBottomSheet && SheetOverhangScope.of(context) == null;
    // The page's own bar floats over its body, which leaves the bar's height
    // at its top through MediaQuery padding, as extendBodyBehindAppBar does.
    final barFloats = !isBottomSheet && widget.appBar == null;
    final body = SafeArea(
      top: !barFloats,
      child: ValueListenableBuilder(
        valueListenable: _keywordsNotifier,
        builder: (context, keywords, _) {
          if (widget.onKeywordsUpdate != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onKeywordsUpdate!(keywords);
            });
          }
          final hasHeader = keywords.isNotEmpty || (isTV && fabSlot != null);
          final barInset = MediaQuery.paddingOf(context).top;
          final overlap = barFloats
              ? barInset
              : isBottomSheet
              ? sheetAppBarHeight
              : 0.0;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hugsContent ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (hasHeader) SizedBox(height: barInset),
              if (isTV && fabSlot != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CommonScaffoldFabExtendedProvider(
                    isExtended: true,
                    child: fabSlot,
                  ),
                ),
              if (keywords.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: isBottomSheet ? sheetAppBarHeight : 16,
                    bottom: 16,
                  ),
                  child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final keyword in keywords)
                        CommonChip(
                          label: keyword,
                          onDeleted: () {
                            _deleteKeyword(keyword);
                          },
                        ),
                    ],
                  ),
                ),
              Flexible(
                fit: hugsContent ? FlexFit.loose : FlexFit.tight,
                child: hasHeader
                    ? MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: FloatingBarScope(inset: 0, child: widget.body),
                      )
                    : widget.body,
              ),
            ],
          );
          final scoped = FloatingBarScope(
            inset: overlap,
            child: overlap > 0
                ? _FocusClearOfBar(inset: overlap, child: content)
                : content,
          );
          if (keywords.isEmpty) {
            return scoped;
          }
          return TopInsetScope(inset: 0, child: scoped);
        },
      ),
    );
    final fabChild = ValueListenableBuilder<bool>(
      valueListenable: _isFabExtendedNotifier,
      builder: (_, isExtended, child) {
        return CommonScaffoldFabExtendedProvider(
          isExtended: isExtended,
          child: child!,
        );
      },
      child: fabSlot,
    );
    final appBar = _buildAppBar(
      backAction,
      form,
      primaryAction: actionInBar ? primaryAction : null,
    );
    final insetBody = form.hasDockedSearch
        ? BottomInsetScope(
            inset: bottomInset + BottomInsetScope.dockedSearchInset,
            child: body,
          )
        : body;
    final content = NotificationListener<UserScrollNotification>(
      child: DockedPageScope(
        docked: false,
        child: hasFab
            ? BottomInsetScope(
                inset: bottomInset + BottomInsetScope.floatingActionButtonInset,
                child: insetBody,
              )
            : insetBody,
      ),
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.reverse) {
          _isFabExtendedNotifier.value = false;
        } else if (notification.direction == ScrollDirection.forward) {
          _isFabExtendedNotifier.value = true;
        }
        return true;
      },
    );
    final fab = hasFab
        ? SheetOverhangLift(
            child: bottomInset > 0
                ? Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: fabChild,
                  )
                : fabChild,
          )
        : null;
    if (!isBottomSheet) {
      return AppBarInsetScope(
        child: Scaffold(
          appBar: appBar,
          extendBodyBehindAppBar: barFloats,
          body: content,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.backgroundColor,
          floatingActionButton: fab,
        ),
      );
    }
    final sheetBody = FloatingHeaderBody(
      backgroundColor:
          widget.backgroundColor ?? context.colorScheme.surfaceContainerLow,
      header: SheetToolBar(appBar: appBar),
      footer: form.dockedSearch == null
          ? null
          : _buildDockedSearch(form.dockedSearch!),
      body: content,
    );
    if (!hugsContent) {
      return AppBarInsetScope(
        child: Scaffold(
          body: sheetBody,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.backgroundColor,
          floatingActionButton: fab,
        ),
      );
    }
    return AppBarInsetScope(
      child: ClipRSuperellipse(
        borderRadius: AppRadius.top(AppCorner.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: sheetBody),
            SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
            if (!form.hasDockedSearch)
              SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}

/// Holds a body whose top stays put clear of the bar floating over it.
class AppBarClearance extends StatelessWidget {
  const AppBarClearance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.appBarInset),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: FloatingBarScope(inset: 0, child: child),
      ),
    );
  }
}

/// Flutter reveals a focused control against the viewport alone, which runs
/// under a floating bar, so keyboard and remote traversal would park it there.
class _FocusClearOfBar extends StatefulWidget {
  const _FocusClearOfBar({required this.inset, required this.child});

  final double inset;
  final Widget child;

  @override
  State<_FocusClearOfBar> createState() => _FocusClearOfBarState();
}

class _FocusClearOfBarState extends State<_FocusClearOfBar> {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    final manager = FocusManager.instance;
    final focused = manager.primaryFocus?.context;
    if (manager.highlightMode != FocusHighlightMode.traditional ||
        focused == null ||
        focused.findAncestorStateOfType<_FocusClearOfBarState>() != this) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(focused));
  }

  void _reveal(BuildContext focused) {
    if (!mounted || !focused.mounted) {
      return;
    }
    var scrollable = Scrollable.maybeOf(focused);
    while (scrollable != null && scrollable.position.axis != Axis.vertical) {
      scrollable = Scrollable.maybeOf(scrollable.context);
    }
    final body = context.findRenderObject();
    final target = focused.findRenderObject();
    final viewport = scrollable?.context.findRenderObject();
    if (scrollable == null ||
        body is! RenderBox ||
        target is! RenderBox ||
        viewport is! RenderBox) {
      return;
    }
    final barBottom = body.localToGlobal(Offset.zero).dy + widget.inset;
    final covered = barBottom - target.localToGlobal(Offset.zero).dy;
    if (covered <= 0 || viewport.localToGlobal(Offset.zero).dy >= barBottom) {
      return;
    }
    final position = scrollable.position;
    final delta = axisDirectionIsReversed(position.axisDirection)
        ? covered
        : -covered;
    position.jumpTo(
      (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _PrimaryActionFab extends StatelessWidget {
  const _PrimaryActionFab({required this.data});

  static const _duration = Duration(milliseconds: 400);

  final IconButtonData data;

  @override
  Widget build(BuildContext context) {
    final isLoading = data.isLoading;
    return IgnorePointer(
      ignoring: isLoading,
      child: AnimatedScale(
        scale: isLoading ? 0 : 1,
        duration: _duration,
        curve: Curves.easeInOutBack,
        child: AnimatedOpacity(
          opacity: isLoading ? 0 : 1,
          duration: _duration,
          child: CommonFloatingActionButton(
            onPressed: data.onPressed,
            icon: GlyphIcon(data.glyph, fill: 1),
            label: data.tooltip ?? '',
          ),
        ),
      ),
    );
  }
}

const _maxBarActions = 2;

({List<IconButtonData> shown, List<CommonPopupMenuItem> overflow})
_foldBarActions({
  required bool hasLead,
  IconButtonData? primary,
  bool foldPrimary = false,
  List<IconButtonData> icons = const [],
  int widgetCount = 0,
  List<CommonPopupMenuItem> menuItems = const [],
}) {
  final count =
      (hasLead ? 1 : 0) +
      (primary == null ? 0 : 1) +
      icons.length +
      widgetCount +
      (menuItems.isEmpty ? 0 : 1);
  if (count <= _maxBarActions) {
    return (shown: [?primary, ...icons], overflow: menuItems);
  }
  final shown = hasLead
      ? null
      : foldPrimary && icons.isNotEmpty
      ? icons.first
      : primary;
  return (
    shown: [?shown],
    overflow: [
      for (final data in [?primary, ...icons])
        if (!identical(data, shown))
          CommonPopupMenuItem(
            glyph: data.glyph,
            label: data.tooltip ?? '',
            onPressed: data.isLoading ? null : data.onPressed,
          ),
      ...menuItems,
    ],
  );
}

class _OverflowMenuButton extends StatelessWidget {
  const _OverflowMenuButton({required this.items});

  final List<CommonPopupMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return CommonPopupBox(
      targetBuilder: (open) => IconButton(
        tooltip: context.appLocalizations.more,
        onPressed: () => open(offset: Offset(0, context.isMobileView ? 0 : 20)),
        icon: const GlyphIcon(AppGlyphs.more),
      ),
      popupBuilder: (_) => CommonPopupMenu(items: items),
    );
  }
}

/// An app bar action from [IconButtonData], standing in a spinner while the
/// action runs.
class AppBarActionButton extends StatelessWidget {
  const AppBarActionButton({super.key, required this.data});

  final IconButtonData data;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: data.tooltip,
      onPressed: data.isLoading ? null : data.onPressed,
      icon: data.isLoading
          ? const SizedBox.square(
              dimension: _barIconSize,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: CommonCircleLoading(),
              ),
            )
          : GlyphIcon(data.glyph),
    );
  }
}

/// Two app bar buttons sharing one filled pill, which answers a press on
/// either as a single button does.
class AppBarButtonGroup extends StatelessWidget {
  const AppBarButtonGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ElasticPress(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.colorScheme.secondaryContainer,
          shape: AppShape.full,
        ),
        child: _BarButtonTheme(
          grouped: true,
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Fills every button in an app bar and, as iOS does, leaves a press to the
/// swell of [ElasticPress]; inside an [AppBarButtonGroup] the group is filled.
class _BarButtonTheme extends StatelessWidget {
  const _BarButtonTheme({this.grouped = false, required this.child});

  final bool grouped;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final fill = grouped ? Colors.transparent : colorScheme.secondaryContainer;
    final foreground = colorScheme.onSecondaryContainer;
    final disabledForeground = foreground.withValues(alpha: 0.38);
    ButtonStyle feedback(Color? tint) => ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty<Color?>.fromMap({
        if (tint != null) WidgetState.focused: tint.withValues(alpha: 0.1),
        WidgetState.pressed: Colors.transparent,
        if (tint != null) WidgetState.hovered: tint.withValues(alpha: 0.08),
      }),
    );
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: feedback(foreground).merge(
          IconButton.styleFrom(
            backgroundColor: fill,
            foregroundColor: foreground,
            disabledBackgroundColor: fill,
            disabledForegroundColor: disabledForeground,
            fixedSize: const Size.square(_barButtonSize),
            minimumSize: const Size.square(_barButtonSize),
            padding: EdgeInsets.zero,
            iconSize: _barIconSize,
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: FilledButtonTheme(
        data: FilledButtonThemeData(
          style: feedback(grouped ? foreground : null).merge(
            FilledButton.styleFrom(
              backgroundColor: grouped ? fill : null,
              foregroundColor: grouped ? foreground : null,
              disabledBackgroundColor: grouped ? fill : null,
              disabledForegroundColor: grouped ? disabledForeground : null,
              minimumSize: const Size.square(_barButtonSize),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: AppShape.full,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        child: IconTheme.merge(
          data: const IconThemeData(fill: 1),
          child: child,
        ),
      ),
    );
  }
}

/// What the surface a scaffold sits on asks of its chrome.
///
/// A sheet page is a pushed route and wears a page's chrome. A bottom sheet
/// floats its bar over the body and searches from a field docked over its
/// foot instead of a button that takes the bar over.
class _SheetForm {
  const _SheetForm({
    required this.isSheet,
    required this.isBottomSheet,
    required this.dockedSearch,
    required this.pop,
  });

  factory _SheetForm.of(
    BuildContext context, {
    required bool hasOwnBar,
    required AppBarSearchState? searchState,
    required bool hasActions,
  }) {
    final provider = SheetProvider.of(context);
    final isModal = provider != null && provider.type != SheetType.page;
    final isBottomSheet = provider?.type == SheetType.bottomSheet;
    return _SheetForm(
      isSheet: provider != null,
      isBottomSheet: isBottomSheet,
      dockedSearch: isBottomSheet && !hasOwnBar ? searchState : null,
      pop: !isModal || hasOwnBar
          ? null
          : _SheetPop.of(context, provider, hasActions: hasActions),
    );
  }

  final bool isSheet;
  final bool isBottomSheet;
  final AppBarSearchState? dockedSearch;
  final _SheetPop? pop;

  bool get hasDockedSearch => dockedSearch != null;
}

/// How a sheet's own pop button reads: [useCloseIcon] where it dismisses the
/// sheet, and [asSuffix] where it is the only thing the bar's trailing holds.
class _SheetPop {
  const _SheetPop({required this.useCloseIcon, required this.asSuffix});

  factory _SheetPop.of(
    BuildContext context,
    SheetProvider provider, {
    required bool hasActions,
  }) {
    final useCloseIcon =
        provider.nestedNavigatorPop == null ||
        ModalRoute.of(context)?.impliesAppBarDismissal == false;
    return _SheetPop(
      useCloseIcon: useCloseIcon,
      asSuffix: useCloseIcon && !hasActions,
    );
  }

  final bool useCloseIcon;
  final bool asSuffix;
}

const double appBarActionSpace = 4;

const double _barButtonSize = 35;
const double _barIconSize = 20;
const double _barButtonGap = 8;
const double _iconButtonTapPadding = 4;

/// Where a filled button sits from the app bar edge, leading included: the
/// layout margin iOS gives a compact and a regular width.
double appBarActionInset(bool compact) => compact ? 16 : 20;

double _iconActionInset(bool isMobileView) => isMobileView ? 4 : 8;

double appBarLeadingWidth(bool compact) =>
    _barButtonSize + appBarActionInset(compact) * 2;

/// A phone view or a sheet: an iOS compact width.
bool _isCompactBar(BuildContext context, bool isMobileView) {
  final sheet = SheetProvider.of(context)?.type;
  return isMobileView || (sheet != null && sheet != SheetType.page);
}

enum AppBarActionEdge {
  icon,
  container;

  double spaceOf(BuildContext context, bool isMobileView) => switch (this) {
    icon => _iconActionInset(isMobileView) - _tapPaddingOf(context),
    container => appBarActionInset(_isCompactBar(context, isMobileView)),
  };

  double get gap => switch (this) {
    icon => appBarActionSpace,
    container => _barButtonGap,
  };
}

/// Only the touch platforms ask for the 48px target that pads the container out.
double _tapPaddingOf(BuildContext context) =>
    Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded
    ? _iconButtonTapPadding
    : 0;

List<Widget> genActions(
  List<Widget> actions, {
  double? space,
  required AppBarActionEdge edge,
}) {
  return <Widget>[
    ...actions.separated(SizedBox(width: space ?? edge.gap)),
    _ActionEdgeGap(edge),
  ];
}

class _ActionEdgeGap extends ConsumerWidget {
  const _ActionEdgeGap(this.edge);

  final AppBarActionEdge edge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: edge.spaceOf(context, ref.watch(isMobileViewProvider)),
    );
  }
}

class AppBarInsetScope extends ConsumerWidget {
  const AppBarInsetScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final compact = _isCompactBar(context, ref.watch(isMobileViewProvider));
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          leadingWidth: appBarLeadingWidth(compact),
        ),
      ),
      child: child,
    );
  }
}

class BaseScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final List<CommonPopupMenuItem> menuItems;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.title,
    this.actions = const [],
    this.menuItems = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: body,
      title: title,
      actions: actions,
      menuItems: menuItems,
    );
  }
}
