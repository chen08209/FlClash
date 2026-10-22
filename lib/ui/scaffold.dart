import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fl_clash/common/iterable.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/keyboard.dart';
import 'package:fl_clash/ui/l10n.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/models.dart';
import 'package:fl_clash/ui/pop_scope.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:fl_clash/ui/view_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'builder.dart';
import 'button.dart';
import 'chip.dart';
import 'dialog.dart';
import 'goo.dart';
import 'inherited.dart';
import 'liquid_glass.dart';
import 'loading.dart';
import 'motion.dart';
import 'navigation_dock.dart';
import 'popup.dart';
import 'search_field.dart';
import 'sheet.dart';
import 'sheet_header.dart';
import 'sheet_navigator.dart';
import 'sortable.dart';

typedef OnKeywordsUpdateCallback = void Function(List<String> keywords);

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class CommonScaffold extends StatefulWidget {
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final Widget? titleWidget;
  final List<CommonPopupMenuItem> titleMenuItems;
  final bool isLoading;
  final List<Widget>? actions;

  final IconButtonData? primaryAction;

  /// Folded into the overflow menu once the bar would hold more than three
  /// buttons, as [primaryAction] and [menuItems] are; [actions] never fold.
  final List<IconButtonData> iconActions;
  final List<CommonPopupMenuItem> menuItems;

  /// Answers a form: last in the bar, and in a form sheet the filled default
  /// at its foot beside cancel, where SwiftUI sets one on macOS.
  final IconButtonData? confirmationAction;

  /// Folds [primaryAction] ahead of [iconActions], so a bar without search
  /// keeps the first of them in sight instead.
  final bool foldPrimaryAction;
  final AppBarSearchState? searchState;
  final List<IconButtonData> searchActions;

  /// Keeps search a button in the bar on a phone page that would dock it at
  /// its foot, for one whose foot carries a bar of its own.
  final bool searchInBar;

  /// Shown searching or not and never folded; the first two share a button
  /// group and any after them stand alone.
  final List<IconButtonData> selectionActions;
  final OnKeywordsUpdateCallback? onKeywordsUpdate;
  final bool? resizeToAvoidBottomInset;
  final VoidCallback? backAction;

  /// Puts the toggle of the sort mode in the bar.
  final bool canSort;

  const CommonScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.title,
    this.titleWidget,
    this.titleMenuItems = const [],
    this.actions,
    this.backAction,
    this.isLoading = false,
    this.searchState,
    this.searchActions = const [],
    this.searchInBar = false,
    this.selectionActions = const [],
    this.primaryAction,
    this.iconActions = const [],
    this.menuItems = const [],
    this.confirmationAction,
    this.foldPrimaryAction = false,
    this.onKeywordsUpdate,
    this.resizeToAvoidBottomInset,
    this.canSort = false,
  });

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final _textController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final _searchMotion = AnimationController.unbounded(vsync: this);
  late final Animation<double> _barUnderSearch = _searchMotion.drive(
    _FadeUnderSearch(),
  );
  late final Animation<double> _searchOverBar = _searchMotion.drive(
    _FadeOverBar(),
  );
  final _searchOrigin = ValueNotifier<Rect?>(null);
  final _searchCovered = ValueNotifier(false);
  final _searchButtonKey = GlobalKey();
  final _barKey = GlobalKey();
  var _searchFillsBar = true;
  var _searchDocked = false;
  var _sorting = false;

  bool get _isSearch {
    return _appBarState.value.searchState?.query != null;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(AppBarState(searchState: widget.searchState));
    _loadingNotifier.value = widget.isLoading;
    _searchFocusNode.addListener(_handleSearchFocusChange);
    _searchMotion.addStatusListener((status) {
      if (!status.isAnimating) {
        _searchCovered.value = _isSearch;
      }
    });
    HardwareKeyboard.instance.addHandler(_handleSearchShortcut);
  }

  Future<void> _updateSearchState(AppBarSearchStateBuilder builder) async {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(_appBarState.value.searchState),
    );
  }

  void _handleToSearch() {
    _searchOrigin.value = _measureSearchOrigin();
    _updateSearchState((state) => state?.copyWith(query: ''));
    _moveSearch(1);
  }

  Rect? _measureSearchOrigin() {
    final button = _searchButtonKey.currentContext?.findRenderObject();
    final bar = _barKey.currentContext?.findRenderObject();
    if (button is! RenderBox || bar is! RenderBox || !button.hasSize) {
      return null;
    }
    return button.localToGlobal(Offset.zero, ancestor: bar) & button.size;
  }

  void _moveSearch(double target) {
    _searchCovered.value = false;
    if (context.disableAnimations) {
      _searchMotion.value = target;
      _searchCovered.value = _isSearch;
      return;
    }
    _searchMotion.animateWith(
      SpringSimulation(
        _searchSpring,
        _searchMotion.value,
        target,
        _searchMotion.velocity,
        snapToEnd: true,
      ),
    );
  }

  // A bar's field at its end folds back once left empty, as a toolbar search
  // field does on macOS; one across the bar waits for its cancel button.
  void _handleSearchFocusChange() {
    if (_searchFocusNode.hasFocus ||
        _searchFillsBar ||
        _textController.text.isNotEmpty) {
      return;
    }
    handleExitSearching();
  }

  void _toggleSorting() {
    setState(() {
      _sorting = !_sorting;
    });
  }

  bool _handleSearchShortcut(KeyEvent event) {
    if (event is! KeyDownEvent ||
        _appBarState.value.searchState == null ||
        _sorting ||
        !controlSingleActivator(
          LogicalKeyboardKey.keyF,
        ).accepts(event, HardwareKeyboard.instance) ||
        !_isFrontmost) {
      return false;
    }
    if (_isSearch || _searchDocked) {
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

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState != widget.searchState) {
      final query = _appBarState.value.searchState?.query;
      _appBarState.value = _appBarState.value.copyWith(
        searchState: widget.searchState?.copyWith(query: query),
      );
      if (widget.searchState == null) {
        _searchMotion.value = 0;
        _searchCovered.value = false;
      }
    }
    if (oldWidget.isLoading != widget.isLoading) {
      _loadingNotifier.value = widget.isLoading;
    }
    if (oldWidget.canSort && !widget.canSort) {
      _sorting = false;
    }
  }

  void _handleClearInput() {
    _textController.text = '';
    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch('');
    }
  }

  void handleExitSearching() {
    if (!_isSearch) {
      return;
    }
    _handleClearInput();
    _searchFocusNode.unfocus();
    _updateSearchState((state) => state?.copyWith(query: null));
    _moveSearch(0);
    // The covered bar, search button included, returns with the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchOrigin.value = _measureSearchOrigin() ?? _searchOrigin.value;
      }
    });
  }

  void _handleCancelDockedSearch() {
    _handleClearInput();
    _searchFocusNode.unfocus();
  }

  void _handleExitAppBarLayer() {
    handleExitSearching();
    if (_sorting) {
      _toggleSorting();
    }
  }

  void _popAppBarLayer() {
    if (!_isSearch) {
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
    _searchMotion.dispose();
    _searchOrigin.dispose();
    _searchCovered.dispose();
    _loadingNotifier.dispose();
    _keywordsNotifier.dispose();
    super.dispose();
  }

  void addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    _setKeywords(List<String>.from(_keywordsNotifier.value)..add(keyword));
  }

  void _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    _setKeywords(List<String>.from(_keywordsNotifier.value)..remove(keyword));
  }

  void _setKeywords(List<String> keywords) {
    _keywordsNotifier.value = keywords;
    widget.onKeywordsUpdate?.call(keywords);
  }

  Widget _buildDockedSearch(AppBarSearchState searchState) {
    final colorScheme = context.colorScheme;
    final glass = LiquidGlassScope.of(context);
    const height = BottomInsetScope.dockedSearchHeight;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final field = ElasticPress(
      child: GooPane(
        child: SearchField(
          height: height,
          controller: _textController,
          focusNode: _searchFocusNode,
          onChanged: searchState.onSearch,
        ),
      ),
    );
    final cancel = TextFieldTapRegion(
      child: TonalButtonTheme(
        size: TonalButtonSize.docked,
        child: _barButton(
          IconButtonData(
            glyph: AppGlyphs.close,
            tooltip: UiLocalizations.of(context).cancel,
            onPressed: _handleCancelDockedSearch,
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(
        left: BottomInsetScope.dockedSearchMargin,
        right: BottomInsetScope.dockedSearchMargin,
        bottom: BottomInsetScope.dockedSearchMargin,
      ),
      // A surface of its own, so the list runs under it, not a sheet-wide band.
      child: SafeArea(
        left: false,
        top: false,
        right: false,
        child: GooSurface(
          glass: glass ? LiquidGlassStyle.pill(colorScheme) : null,
          color: SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
          shadows: glass
              ? dockGlassShadows(colorScheme)
              : dockShadows(colorScheme),
          child: ListenableBuilder(
            listenable: Listenable.merge([_searchFocusNode, _textController]),
            builder: (context, _) {
              final active =
                  _searchFocusNode.hasFocus || _textController.text.isNotEmpty;
              // iOS 27 offers the cancel button while its bottom field is in
              // use, drawn out of the field's end.
              return TweenAnimationBuilder<double>(
                tween: Tween(end: active ? 1 : 0),
                duration: context.motionDuration(_searchSettleDuration),
                curve: _searchCurve,
                builder: (_, t, _) {
                  final grown = math.max(t, 0.0);
                  return SizedBox(
                    height: height,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          width: height,
                          height: height,
                          child: ExcludeFocus(
                            excluding: !active,
                            child: ExcludeSemantics(
                              excluding: !active,
                              child: IgnorePointer(
                                ignoring: !active,
                                child: Transform(
                                  alignment: AlignmentDirectional.centerStart,
                                  transform: Matrix4.translationValues(
                                    (rtl ? -1 : 1) * height / 2 * (1 - t),
                                    0,
                                    0,
                                  )..scaleByDouble(grown, grown, 1, 1),
                                  child: Opacity(
                                    opacity: _shownAt(t),
                                    child: cancel,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 0,
                          bottom: 0,
                          start: 0,
                          end: (height + _searchFieldGap) * grown,
                          child: field,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  VoidCallback get _closeSheet =>
      SheetProvider.of(context)?.onClose ?? () => context.safeNestedPop();

  Widget _buildSheetPopButton(
    VoidCallback? backAction, {
    required bool useCloseIcon,
  }) {
    final localizations = UiLocalizations.of(context);
    return AppBarActionButton(
      data: useCloseIcon
          ? IconButtonData(
              glyph: AppGlyphs.close,
              onPressed: _closeSheet,
              tooltip: localizations.close,
            )
          : IconButtonData(
              glyph: AppGlyphs.backFor(Theme.of(context).platform),
              onPressed: backAction ?? () => Navigator.of(context).pop(),
              tooltip: localizations.back,
            ),
    );
  }

  Widget? _buildLeading(VoidCallback? backAction, {required _SheetPop? pop}) {
    final button = _buildLeadingButton(backAction, pop: pop);
    if (button == null) {
      return null;
    }
    final hidden = _sorting;
    return Center(
      child: ExcludeFocus(
        excluding: hidden,
        child: ExcludeSemantics(
          excluding: hidden,
          child: IgnorePointer(
            ignoring: hidden,
            child: AnimatedOpacity(
              opacity: hidden ? 0 : 1,
              duration: context.motionDuration(kThemeAnimationDuration),
              child: ElasticPress(child: button),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeadingButton(
    VoidCallback? backAction, {
    required _SheetPop? pop,
  }) {
    if (pop != null) {
      return pop.atFoot
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

  Widget _buildTitle({required bool compact}) {
    return widget.titleWidget ??
        (widget.titleMenuItems.isEmpty
            ? Text(widget.title!)
            : CommonPopupBox(
                placement: PopupPlacement.overAnchorStart,
                targetBuilder: (open) => _TitleMenuButton(
                  title: widget.title!,
                  compact: compact,
                  onPressed: open,
                ),
                popupBuilder: (_) =>
                    CommonPopupMenu(items: widget.titleMenuItems),
              ));
  }

  List<Widget> _buildActions(
    bool hasSearch,
    IconButtonData? primaryAction,
    _SheetForm form,
  ) {
    if (_sorting) {
      return genActions([
        if (widget.canSort)
          ElasticPress(
            child: AppBarActionButton(
              data: sortModeAction(
                context,
                sorting: true,
                onPressed: _toggleSorting,
              ),
            ),
          ),
      ], edge: AppBarActionEdge.container);
    }
    final lead = hasSearch && !form.hasDockedSearch
        ? IconButtonData(
            glyph: AppGlyphs.search,
            tooltip: UiLocalizations.of(context).search,
            onPressed: _handleToSearch,
          )
        : null;
    final widgets = widget.actions ?? const <Widget>[];
    final selection = _SelectionButtons(widget.selectionActions);
    final atFoot = form.pop?.atFoot == true;
    final fold = _foldBarActions(
      hasLead: lead != null,
      primary: primaryAction,
      foldPrimary: widget.foldPrimaryAction,
      icons: [
        if (widget.canSort)
          sortModeAction(context, sorting: false, onPressed: _toggleSorting),
        ...widget.iconActions,
      ],
      confirmation: atFoot ? null : widget.confirmationAction,
      widgetCount: widgets.length + selection.slots,
      menuItems: widget.menuItems,
    );
    final shown = [?lead, ...fold.shown];
    final grouped = shown.length > 1 ? shown.take(_maxGroupedActions) : null;
    final actions = [
      if (grouped != null)
        TonalButtonGroup(
          children: [
            for (final data in grouped) AppBarActionButton(data: data),
          ],
        ),
      for (final data in shown.skip(grouped?.length ?? 0)) _barButton(data),
      ...selection.build(),
      for (final action in widgets) ElasticPress(child: action),
      if (fold.overflow.isNotEmpty)
        ElasticPress(child: _OverflowMenuButton(items: fold.overflow)),
    ];
    if (lead != null) {
      actions.first = KeyedSubtree(key: _searchButtonKey, child: actions.first);
    }
    return genActions(actions, edge: AppBarActionEdge.container);
  }

  Widget _buildBarSearch({required bool fills}) {
    final selection = _SelectionButtons(widget.selectionActions);
    final fold = _foldBarActions(
      hasLead: fills,
      icons: widget.searchActions,
      widgetCount: selection.slots,
    );
    final colorScheme = context.colorScheme;
    final actions = [
      ...selection.build(),
      for (final data in fold.shown) _barButton(data),
      if (fold.overflow.isNotEmpty)
        ElasticPress(child: _OverflowMenuButton(items: fold.overflow)),
    ];
    final buttonCount =
        selection.buttons + fold.shown.length + (fold.overflow.isEmpty ? 0 : 1);
    return _BarSearch(
      motion: _searchMotion,
      opacity: _searchOverBar,
      origin: _searchOrigin,
      searching: _isSearch,
      actions: actions,
      actionsWidth:
          buttonCount * TonalButtonSize.bar.button +
          math.max(0, actions.length - 1) * _barButtonGap,
      cancel: fills
          ? _barButton(
              IconButtonData(
                glyph: AppGlyphs.close,
                tooltip: UiLocalizations.of(context).cancel,
                onPressed: _popAppBarLayer,
              ),
            )
          : null,
      glass: LiquidGlassScope.of(context)
          ? LiquidGlassStyle.regular(colorScheme)
          : null,
      color: context.raisedSurfaceLevel.colorOf(colorScheme),
      // The field's own buttons stay off the bar's button fills and glass.
      field: IconButtonTheme(
        data: IconButtonTheme.of(context),
        child: SearchField(
          autofocus: true,
          controller: _textController,
          focusNode: _searchFocusNode,
          onChanged: (value) => _appBarState.value.searchState?.onSearch(value),
        ),
      ),
    );
  }

  Widget _buildFootActions(IconButtonData confirmation) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: AlertActions(
        actions: [
          TextButton(
            onPressed: _closeSheet,
            child: Text(UiLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: confirmation.isLoading ? null : confirmation.onPressed,
            child: confirmation.isLoading
                ? CommonCircleLoading(size: TonalButtonSize.bar.icon)
                : Text(confirmation.tooltip!),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarWrap(Widget appBar, {required bool barSearch}) {
    return TonalButtonTheme(
      glass: LiquidGlassScope.of(context),
      child: Stack(
        key: _barKey,
        fit: StackFit.passthrough,
        children: [
          appBar,
          if (barSearch)
            Positioned.fill(child: _buildBarSearch(fills: _searchFillsBar)),
          if (_isSearch || _sorting)
            BackLayerScope(
              onBack: _handleExitAppBarLayer,
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(Widget appBar) {
    final top = MediaQuery.paddingOf(context).top;
    return FloatingHeader(
      backgroundColor:
          widget.backgroundColor ??
          SurfaceLevel.page.colorOf(context.colorScheme),
      fadeStart: top / (top + pageToolbarHeight),
      overhang: _headerOverhang,
      child: appBar,
    );
  }

  PreferredSizeWidget _buildAppBar(VoidCallback? backAction, _SheetForm form) {
    final isCompact = form.isCompact;
    final isMobileView = ViewScope.isMobileOf(context);
    final pushed =
        form.pop == null &&
        widget.titleWidget == null &&
        isMobileView &&
        ModalRoute.of(context)?.impliesAppBarDismissal == true;
    final compactTitle = isCompact || pushed;
    final titleEndInset = appBarActionInset(
      _isCompactBar(context, isMobileView),
    );
    // Under a sheet the bar drops its actions, so none reads as the sheet's.
    final uncovered = ReverseAnimation(sheetCoverOf(context));
    return PreferredSize(
      preferredSize: Size.fromHeight(
        isCompact ? sheetToolbarHeight : pageToolbarHeight,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([_appBarState, _searchCovered]),
            builder: (_, _) {
              final state = _appBarState.value;
              final leading = _buildLeading(backAction, pop: form.pop);
              final barSearch =
                  state.searchState != null && !form.hasDockedSearch;
              final covered = barSearch && _searchCovered.value;
              final hidesBar = covered && _searchFillsBar;
              Widget underSearch(Widget child, {required bool fades}) =>
                  barSearch && fades
                  ? _UnderBarSearch(
                      opacity: _barUnderSearch,
                      searching: _isSearch,
                      child: child,
                    )
                  : child;
              final appBar = AppBar(
                clipBehavior: Clip.none,
                automaticallyImplyLeading: false,
                animateColor: true,
                forceMaterialTransparency: true,
                toolbarHeight: isCompact ? sheetToolbarHeight : null,
                centerTitle: isCompact,
                titleTextStyle: compactTitle
                    ? AppTextStyle.headline.of(context)
                    : AppTextStyle.pageTitle.of(context),
                leading: hidesBar ? null : leading,
                // The leading slot already trails its button by a margin.
                titleSpacing: leading == null ? null : 0,
                title: hidesBar
                    ? null
                    : leading == null || isCompact
                    ? _buildTitle(compact: compactTitle)
                    : Padding(
                        padding: EdgeInsetsDirectional.only(end: titleEndInset),
                        child: _buildTitle(compact: compactTitle),
                      ),
                actions: [
                  if (!covered)
                    for (final action in _buildActions(
                      state.searchState != null,
                      widget.primaryAction,
                      form,
                    ))
                      FadeTransition(
                        opacity: uncovered,
                        child: underSearch(action, fades: !_searchFillsBar),
                      ),
                ],
              );
              final bar = _buildAppBarWrap(
                underSearch(appBar, fades: _searchFillsBar),
                barSearch: barSearch,
              );
              return isCompact
                  ? bar
                  : _buildFloatingHeader(_WindowControlsClearance(child: bar));
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
    assert(widget.title != null || widget.titleWidget != null);
    final backAction = widget.backAction;
    final form = _SheetForm.of(
      context,
      searchState: widget.searchState,
      searchInBar: widget.searchInBar,
      hasConfirmationAction: widget.confirmationAction != null,
    );
    final isCompact = form.isCompact;
    _searchFillsBar = _isCompactBar(context, ViewScope.isMobileOf(context));
    _searchDocked = form.hasDockedSearch;
    final bottomInset = BottomInsetScope.of(context);
    // A detent sheet fills the height its detent gives it and clips its own
    // corners; any other bottom sheet sizes to its content and brings both.
    final hugsContent = isCompact && !SheetOverhangScope.fillsDetentOf(context);
    // The page's bar floats over its body, which leaves the bar's height at
    // its top through MediaQuery padding, as extendBodyBehindAppBar does.
    final barFloats = !isCompact;
    final sortableBody = SortModeScope(sorting: _sorting, child: widget.body);
    final body = SafeArea(
      top: !barFloats,
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: _keywordsNotifier,
        builder: (context, keywords, _) {
          final hasKeywords = keywords.isNotEmpty;
          final barInset = MediaQuery.paddingOf(context).top;
          final overlap = barFloats
              ? barInset
              : isCompact
              ? sheetAppBarHeight
              : 0.0;
          // A wrapper toggled with the strip would remount the body.
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hugsContent ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (hasKeywords)
                Padding(
                  padding: EdgeInsets.only(top: overlap + 4, bottom: 16),
                  child: _KeywordStrip(
                    keywords: keywords,
                    onDeleted: _deleteKeyword,
                  ),
                ),
              Flexible(
                fit: hugsContent ? FlexFit.loose : FlexFit.tight,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: hasKeywords,
                  child: FloatingBarScope(
                    inset: hasKeywords ? 0 : overlap,
                    child: sortableBody,
                  ),
                ),
              ),
            ],
          );
          return TopInsetScope(
            inset: hasKeywords ? 0 : TopInsetScope.of(context),
            child: FloatingBarScope(
              inset: overlap,
              child: overlap > 0
                  ? _FocusClearOfBar(inset: overlap, child: content)
                  : content,
            ),
          );
        },
      ),
    );
    final appBar = _buildAppBar(backAction, form);
    final content = form.hasDockedSearch
        ? BottomInsetScope(
            inset: bottomInset + BottomInsetScope.dockedSearchInset,
            child: body,
          )
        : body;
    if (!isCompact) {
      final docked = form.dockedSearch;
      return AppBarInsetScope(
        child: Scaffold(
          appBar: appBar,
          extendBodyBehindAppBar: barFloats,
          body: _BodyScope(
            child: docked == null
                ? content
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      content,
                      if (!_sorting)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildDockedSearch(docked),
                        ),
                    ],
                  ),
          ),
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.backgroundColor,
        ),
      );
    }
    final sheetBody = FloatingHeaderBody(
      backgroundColor:
          widget.backgroundColor ??
          SurfaceLevel.page.colorOf(context.colorScheme),
      header: SheetToolBar(appBar: appBar, dragHandle: form.hasDragHandle),
      footer: form.dockedSearch == null || _sorting
          ? null
          : _buildDockedSearch(form.dockedSearch!),
      body: content,
    );
    final footed = form.pop?.atFoot == true
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: hugsContent ? FlexFit.loose : FlexFit.tight,
                child: sheetBody,
              ),
              _buildFootActions(widget.confirmationAction!),
            ],
          )
        : sheetBody;
    if (!hugsContent) {
      return AppBarInsetScope(
        child: Scaffold(
          body: footed,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.backgroundColor,
        ),
      );
    }
    final hugging = Column(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: footed)],
    );
    return AppBarInsetScope(
      child: form.hasDragHandle
          ? ClipRSuperellipse(
              borderRadius: AppRadius.top(AppCorner.xxl),
              child: hugging,
            )
          : hugging,
    );
  }
}

// iOS 27's bar search opening, as the simulator shows it: about 3% over, at
// its peak 0.24 s in.
final _searchSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 390,
  ratio: 0.75,
);
const _searchSettleDuration = Duration(milliseconds: 450);
final _searchCurve = SpringCurve(_searchSpring, seconds: 0.45);
const double _searchFieldGap = 12;
const double _regularSearchWidth = 280;

double _shownAt(double t) => ((t - 0.5) / 0.4).clamp(0.0, 1.0);

// Below this much of its spring the field stands on the button group it grows
// from, the group in full beneath it, and fades: the group's glyphs come up
// inside one pill, with no edge of the field beside it.
const double _searchHandover = 0.2;

class _FadeUnderSearch extends Animatable<double> {
  @override
  double transform(double t) =>
      1 - ((t - _searchHandover) / _searchHandover).clamp(0.0, 1.0);
}

class _FadeOverBar extends Animatable<double> {
  @override
  double transform(double t) => (t / _searchHandover).clamp(0.0, 1.0);
}

/// What a bar's search covers: faded out as the field opens over it, and out
/// of reach while it is open.
class _UnderBarSearch extends StatelessWidget {
  const _UnderBarSearch({
    required this.opacity,
    required this.searching,
    required this.child,
  });

  final Animation<double> opacity;
  final bool searching;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ExcludeFocus(
        excluding: searching,
        child: ExcludeSemantics(
          excluding: searching,
          child: IgnorePointer(ignoring: searching, child: child),
        ),
      ),
    );
  }
}

/// The field a bar's search button opens into, grown out of that button on
/// [motion]: across the bar to a [cancel] button where there is one, as iOS
/// 27 opens one over a page above a tab bar, else at the bar's end, as iPadOS
/// does. The [actions] that still apply while searching lead the field. The
/// buttons beside it grow out of its ends and flow into it under a press, as
/// iOS's do.
class _BarSearch extends StatelessWidget {
  const _BarSearch({
    required this.motion,
    required this.opacity,
    required this.origin,
    required this.searching,
    required this.actions,
    required this.actionsWidth,
    required this.cancel,
    required this.glass,
    required this.color,
    required this.field,
  });

  final Animation<double> motion;
  final Animation<double> opacity;
  final ValueListenable<Rect?> origin;
  final bool searching;
  final List<Widget> actions;
  final double actionsWidth;
  final Widget? cancel;
  final LiquidGlassStyle? glass;
  final Color color;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final cancel = this.cancel;
    final inset = appBarActionInset(cancel != null);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final height = TonalButtonSize.bar.button;
    return ExcludeFocus(
      excluding: !searching,
      child: IgnorePointer(
        ignoring: !searching,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final top =
                constraints.maxHeight - (pageToolbarHeight + height) / 2;
            final start = (rtl ? padding.right : padding.left) + inset;
            final end = width - (rtl ? padding.left : padding.right) - inset;
            final actionsRoom = actionsWidth > 0
                ? actionsWidth + _searchFieldGap
                : 0.0;
            final fieldEnd = cancel == null
                ? end
                : end - height - _searchFieldGap;
            final fieldStart = cancel == null
                ? math.max(start + actionsRoom, end - _regularSearchWidth)
                : start + actionsRoom;
            final actionsStart = fieldStart - actionsRoom;
            Rect place(double from, double to) => Rect.fromLTRB(
              rtl ? width - to : from,
              top,
              rtl ? width - from : to,
              top + height,
            );
            final slot = place(fieldStart, math.max(fieldStart, fieldEnd));
            final actionsRect = place(
              actionsStart,
              actionsStart + actionsWidth,
            );
            final search = AnimatedBuilder(
              animation: Listenable.merge([motion, origin]),
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                minWidth: slot.width,
                maxWidth: slot.width,
                child: field,
              ),
              builder: (_, content) {
                if (!searching && !motion.isAnimating) {
                  return const SizedBox.shrink();
                }
                final t = motion.value;
                final shown = _shownAt(t);
                final grown = math.max(
                  0.0,
                  (t - _searchHandover) / (1 - _searchHandover),
                );
                final from = origin.value ?? place(fieldEnd - height, fieldEnd);
                final fieldRect = Rect.lerp(from, slot, grown)!;
                Widget grow(Rect rest, Widget child, {required bool leads}) {
                  final facesRight = leads != rtl;
                  final edge = facesRight ? rest.right : rest.left;
                  final reach = lerpDouble(
                    height / 2,
                    -_searchFieldGap,
                    grown,
                  )!;
                  final anchor = facesRight
                      ? fieldRect.left + reach
                      : fieldRect.right - reach;
                  return Positioned.fromRect(
                    rect: rest,
                    child: Transform(
                      alignment: facesRight
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      transform: Matrix4.translationValues(anchor - edge, 0, 0)
                        ..scaleByDouble(grown, grown, 1, 1),
                      child: Opacity(opacity: shown, child: child),
                    ),
                  );
                }

                return TextFieldTapRegion(
                  child: Stack(
                    children: [
                      Positioned.fromRect(
                        rect: fieldRect,
                        child: ElasticPress(
                          child: GooPane(
                            child: ClipRSuperellipse(
                              borderRadius: AppRadius.full,
                              child: Opacity(opacity: shown, child: content),
                            ),
                          ),
                        ),
                      ),
                      if (actions.isNotEmpty)
                        grow(
                          actionsRect,
                          Row(
                            children: [
                              ...actions.separated(
                                const SizedBox(width: _barButtonGap),
                              ),
                            ],
                          ),
                          leads: true,
                        ),
                      if (cancel != null)
                        grow(place(end - height, end), cancel, leads: false),
                    ],
                  ),
                );
              },
            );
            return LiquidGlassFade(
              opacity: opacity,
              child: GooSurface(
                glass: glass,
                color: color,
                child: TonalButtonTheme(glass: glass != null, child: search),
              ),
            );
          },
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

class _KeywordStrip extends StatelessWidget {
  const _KeywordStrip({required this.keywords, required this.onDeleted});

  final List<String> keywords;
  final ValueChanged<String> onDeleted;

  static const _inset = 16.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TonalButtonSize.section.button,
      child: WidthBuilder(
        builder: (_, width) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _inset),
          itemCount: keywords.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final keyword = keywords[index];
            return ConstrainedBox(
              key: ValueKey(keyword),
              constraints: BoxConstraints(
                maxWidth: math.max(0, width - 2 * _inset),
              ),
              child: CommonChip(
                label: keyword,
                onDeleted: () => onDeleted(keyword),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Keeps rebuilds in the body to its own layer (.agents/architecture.md).
class _BodyScope extends StatelessWidget {
  const _BodyScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _BodyBoundary(child: LayoutBuilder(builder: (_, _) => child));
  }
}

class _BodyBoundary extends SingleChildRenderObjectWidget {
  const _BodyBoundary({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBodyBoundary();
}

class _RenderBodyBoundary extends RenderProxyBox {
  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    child?.layout(constraints);
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

const _maxBarButtons = 3;
const _maxGroupedActions = 2;

Widget _barButton(IconButtonData data) => ElasticPress(
  enabled: !data.isLoading && data.onPressed != null,
  child: AppBarActionButton(data: data),
);

/// [CommonScaffold.selectionActions] as the bar shows them, searching or not.
class _SelectionButtons {
  const _SelectionButtons(this.actions);

  final List<IconButtonData> actions;

  Iterable<IconButtonData> get _singles => actions.skip(_maxGroupedActions);

  int get slots => (actions.isEmpty ? 0 : 1) + _singles.length;

  int get buttons => actions.length;

  List<Widget> build() => [
    if (actions.isNotEmpty)
      TonalButtonGroup(
        children: [
          for (final data in actions.take(_maxGroupedActions))
            AppBarActionButton(data: data),
        ],
      ),
    for (final data in _singles) _barButton(data),
  ];
}

({List<IconButtonData> shown, List<CommonPopupMenuItem> overflow})
_foldBarActions({
  required bool hasLead,
  IconButtonData? primary,
  bool foldPrimary = false,
  List<IconButtonData> icons = const [],
  IconButtonData? confirmation,
  int widgetCount = 0,
  List<CommonPopupMenuItem> menuItems = const [],
}) {
  final foldable = [?primary, ...icons];
  final fixed =
      (hasLead ? 1 : 0) + widgetCount + (confirmation == null ? 0 : 1);
  if (fixed + foldable.length + (menuItems.isEmpty ? 0 : 1) <= _maxBarButtons) {
    return (shown: [...foldable, ?confirmation], overflow: menuItems);
  }
  final slots = _maxBarButtons - 1 - fixed;
  final kept = (foldPrimary ? [...icons, ?primary] : foldable)
      .take(slots < 0 ? 0 : slots)
      .toList();
  bool isKept(IconButtonData data) => kept.any((it) => identical(it, data));
  return (
    shown: [
      for (final data in foldable)
        if (isKept(data)) data,
      ?confirmation,
    ],
    overflow: [
      for (final data in foldable)
        if (!isKept(data))
          CommonPopupMenuItem(
            glyph: data.glyph,
            label: data.tooltip ?? '',
            checked: data.isSelected,
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
        tooltip: UiLocalizations.of(context).more,
        onPressed: open,
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
    final colorScheme = context.colorScheme;
    return IconButton(
      tooltip: data.tooltip,
      isSelected: data.isSelected,
      style: data.isSelected == true
          ? IconButton.styleFrom(
              backgroundColor: TonalButtonTheme.glassOf(context)
                  ? null
                  : colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
      onPressed: data.isLoading ? null : data.onPressed,
      icon: data.isLoading
          ? CommonCircleLoading(size: TonalButtonSize.bar.icon)
          : GlyphIcon(data.glyph),
    );
  }
}

/// What the surface a scaffold sits on asks of its chrome.
///
/// A sheet page is a pushed route and wears a page's chrome. A bottom sheet
/// floats its bar over the body; it and a phone page pushed over the one with
/// the tab bar search from a field docked over their foot instead of a button
/// that takes the bar over.
class _SheetForm {
  const _SheetForm({
    required this.isCompact,
    required this.hasDragHandle,
    required this.dockedSearch,
    required this.pop,
  });

  factory _SheetForm.of(
    BuildContext context, {
    required AppBarSearchState? searchState,
    required bool searchInBar,
    required bool hasConfirmationAction,
  }) {
    final provider = SheetProvider.of(context);
    final isModal = provider != null && provider.type != SheetType.page;
    final isCompact = provider?.type.isCompact ?? false;
    // iOS 27 docks the search of a phone page with no tab bar under it at its
    // foot, a glass field in sight at rest.
    final docksSearch =
        isCompact ||
        (!searchInBar &&
            !isModal &&
            ViewScope.isMobileOf(context) &&
            ModalRoute.of(context)?.impliesAppBarDismissal == true);
    return _SheetForm(
      isCompact: isCompact,
      hasDragHandle: provider?.type == SheetType.bottomSheet,
      dockedSearch: docksSearch ? searchState : null,
      pop: !isModal
          ? null
          : _SheetPop.of(
              context,
              provider,
              hasConfirmationAction:
                  hasConfirmationAction && searchState == null,
            ),
    );
  }

  final bool isCompact;
  final bool hasDragHandle;
  final AppBarSearchState? dockedSearch;
  final _SheetPop? pop;

  bool get hasDockedSearch => dockedSearch != null;
}

/// How a sheet's own pop button reads: [useCloseIcon] where it dismisses the
/// sheet. It leads the bar wherever it is, as SwiftUI places a close in
/// `.cancellationAction`, unless [atFoot] turns it into a form's cancel.
class _SheetPop {
  const _SheetPop({required this.useCloseIcon, required this.atFoot});

  factory _SheetPop.of(
    BuildContext context,
    SheetProvider provider, {
    required bool hasConfirmationAction,
  }) {
    final useCloseIcon =
        provider.nestedNavigatorPop == null ||
        ModalRoute.of(context)?.impliesAppBarDismissal == false;
    final atFoot =
        useCloseIcon &&
        hasConfirmationAction &&
        provider.type == SheetType.formSheet;
    return _SheetPop(useCloseIcon: useCloseIcon, atFoot: atFoot);
  }

  final bool useCloseIcon;
  final bool atFoot;
}

const double appBarActionSpace = 4;

const double _barButtonGap = 8;
const double _headerOverhang = 16;
const double _iconButtonTapPadding = 4;

/// Where a filled button sits from the app bar edge, leading included: the
/// layout margin iOS gives a compact and a regular width.
double appBarActionInset(bool compact) => compact ? 16 : 20;

double _iconActionInset(bool isMobileView) => isMobileView ? 4 : 8;

double appBarLeadingWidth(bool compact) =>
    TonalButtonSize.bar.button + appBarActionInset(compact) * 2;

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

/// Only the touch platforms ask for the 48 dp target that pads the container out.
double _tapPaddingOf(BuildContext context) =>
    Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded
    ? _iconButtonTapPadding
    : 0;

List<Widget> genActions(
  List<Widget> actions, {
  required AppBarActionEdge edge,
}) {
  return <Widget>[
    ...actions.separated(SizedBox(width: edge.gap)),
    _ActionEdgeGap(edge),
  ];
}

class _ActionEdgeGap extends StatelessWidget {
  const _ActionEdgeGap(this.edge);

  final AppBarActionEdge edge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: edge.spaceOf(context, ViewScope.isMobileOf(context)),
    );
  }
}

class AppBarInsetScope extends StatelessWidget {
  const AppBarInsetScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = _isCompactBar(context, ViewScope.isMobileOf(context));
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          leadingWidth: appBarLeadingWidth(compact),
          toolbarHeight: pageToolbarHeight,
        ),
      ),
      child: child,
    );
  }
}

/// A route over the home page on the root navigator fills the window, with
/// neither the window header nor the sidebar keeping it off the buttons.
class _TitleMenuButton extends StatelessWidget {
  const _TitleMenuButton({
    required this.title,
    required this.compact,
    required this.onPressed,
  });

  final String title;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // No ink: the padding it needs would move the title off its place in the
    // bar, and a press turns the title into its menu at once.
    return InkWell(
      onTap: onPressed,
      customBorder: AppShape.sm,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: compact ? 2 : 4,
        children: [
          Flexible(child: Text(title)),
          GlyphIcon(
            AppGlyphs.chevronDown,
            size: compact ? 16 : 20,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _WindowControlsClearance extends StatelessWidget {
  const _WindowControlsClearance({required this.child});

  final Widget child;

  static bool _fillsWindow(BuildContext context) {
    final route = ModalRoute.of(context);
    return route != null &&
        route.opaque &&
        !route.isFirst &&
        route.navigator == Navigator.maybeOf(context, rootNavigator: true);
  }

  @override
  Widget build(BuildContext context) {
    final controls = ViewScope.windowControlsOf(context);
    if (controls.isEmpty || !_fillsWindow(context)) {
      return child;
    }
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: padding.copyWith(left: math.max(padding.left, controls.width)),
      ),
      child: child,
    );
  }
}

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const BaseScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(body: body, title: title);
  }
}
