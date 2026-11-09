import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:prism_ui/prism_ui.dart';

part 'scaffold_actions.dart';
part 'scaffold_search.dart';

class AppBarSearchState {
  const AppBarSearchState({required this.onSearch, this.query});

  final ValueChanged<String> onSearch;
  final String? query;

  AppBarSearchState withQuery(String? query) =>
      AppBarSearchState(onSearch: onSearch, query: query);
}

class ScaffoldKeyword {
  const ScaffoldKeyword({
    required this.key,
    required this.label,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
    this.startsSection = false,
  });

  final Object key;
  final String label;
  final VoidCallback? onDeleted;

  final VoidCallback? onPressed;
  final bool selected;

  final bool startsSection;
}

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class Scaffold extends StatefulWidget {
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final Widget? titleWidget;
  final List<PopupMenuItem> titleMenuItems;
  final bool isLoading;
  final List<Widget>? actions;

  final IconButtonData? primaryAction;

  /// Folded into the overflow menu once the bar would hold more than three
  /// buttons, as [primaryAction] and [menuItems] are; [actions] never fold.
  final List<IconButtonData> iconActions;
  final List<PopupMenuItem> menuItems;

  /// Answers a form: last in the bar, and in a form sheet the filled default
  /// at its foot beside cancel, where SwiftUI sets one on macOS.
  final IconButtonData? confirmationAction;
  final AppBarSearchState? searchState;
  final List<IconButtonData> searchActions;

  /// Keeps search a button in the bar on a phone page that would dock it at
  /// its foot, for one whose foot carries a bar of its own.
  final bool searchInBar;

  /// Shown searching or not and never folded; the first two share a button
  /// group and any after them stand alone.
  final List<IconButtonData> selectionActions;

  /// Removable chips under the bar, kept by the page that filters by them.
  final ValueListenable<List<ScaffoldKeyword>>? keywords;
  final bool? resizeToAvoidBottomInset;
  final VoidCallback? backAction;

  /// Puts the toggle of the sort mode in the bar.
  final bool canSort;

  const Scaffold({
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
    this.keywords,
    this.resizeToAvoidBottomInset,
    this.canSort = false,
  });

  @override
  State<Scaffold> createState() => ScaffoldState();
}

class ScaffoldState extends State<Scaffold>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<AppBarSearchState?> _appBarState;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final _textController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final _searchMotion = _SearchMotion(this);
  late final Animation<double> _titleUnderSearch = _searchMotion.drive(
    (frame) => frame.titleOpacity,
  );
  late final Animation<double> _actionsUnderSearch = _searchMotion.drive(
    (frame) => frame.actionsOpacity,
  );
  late final Animation<double> _searchOverBar = _searchMotion.drive(
    (frame) => frame.fieldOpacity,
  );
  late final Animation<double> _leadingUnderSearch = _searchMotion.drive(
    (frame) => frame.leadingOpacity,
  );
  late final Animation<double> _leadUnderSearch = _searchMotion.drive(
    (frame) => frame.leadOpacity,
  );
  final _searchOrigin = ValueNotifier<_SearchOrigin?>(null);
  final _searchCovered = ValueNotifier(false);
  final _searchButtonKey = GlobalKey();
  final _searchLeadKey = GlobalKey();
  final _searchLeadingKey = GlobalKey();
  final _searchFieldKey = GlobalKey();
  final _barKey = GlobalKey();
  var _searchFillsBar = true;
  var _searchDocked = false;
  var _sorting = false;

  bool get _isSearch {
    return _appBarState.value?.query != null;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(widget.searchState);
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
    _appBarState.value = builder(_appBarState.value);
  }

  void _handleToSearch() {
    _searchOrigin.value = _measureSearchOrigin();
    _updateSearchState((state) => state?.withQuery(''));
    _moveSearch(open: true);
  }

  Rect? _measureInBar(GlobalKey key) {
    final bar = _barKey.currentContext?.findRenderObject();
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || bar is! RenderBox || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero, ancestor: bar) & box.size;
  }

  _SearchOrigin? _measureSearchOrigin() {
    final group = _measureInBar(_searchButtonKey);
    return group == null
        ? null
        : _SearchOrigin.of(
            group,
            lead: _measureInBar(_searchLeadKey),
            leading: _measureInBar(_searchLeadingKey),
          );
  }

  void _moveSearch({required bool open}) {
    _searchCovered.value = false;
    if (context.disableAnimations) {
      _searchMotion.jumpTo(open: open);
      _searchCovered.value = _isSearch;
      return;
    }
    final origin = _searchOrigin.value;
    _searchMotion.moveTo(
      open: open,
      returns: origin == null || !origin.lone
          ? _SearchReturn.group
          : !_searchFillsBar
          ? _SearchReturn.morph
          : origin.leading == null
          ? _SearchReturn.droplet
          : _SearchReturn.pinch,
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
        _appBarState.value == null ||
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
  void didUpdateWidget(Scaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState != widget.searchState) {
      final query = _appBarState.value?.query;
      _appBarState.value = widget.searchState?.withQuery(query);
      if (widget.searchState == null) {
        _searchMotion.jumpTo(open: false);
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
    _appBarState.value?.onSearch('');
  }

  void handleExitSearching() {
    if (!_isSearch) {
      return;
    }
    final field = _measureInBar(_searchFieldKey);
    _searchOrigin.value = _searchOrigin.value?.withField(field);
    _handleClearInput();
    _searchFocusNode.unfocus();
    _updateSearchState((state) => state?.withQuery(null));
    _moveSearch(open: false);
    // The covered bar, search button included, returns with the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchOrigin.value =
            _measureSearchOrigin()?.withField(field) ?? _searchOrigin.value;
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
    super.dispose();
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
            glyph: Glyphs.close,
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
          shadows: glass ? const [] : dockShadows(colorScheme),
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

  Widget _buildPopButton({
    required bool useCloseIcon,
    required VoidCallback onPressed,
  }) {
    final localizations = UiLocalizations.of(context);
    return AppBarActionButton(
      data: useCloseIcon
          ? IconButtonData(
              glyph: Glyphs.close,
              onPressed: onPressed,
              tooltip: localizations.close,
            )
          : IconButtonData(
              glyph: Glyphs.backFor(Theme.of(context).platform),
              onPressed: onPressed,
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
              child: BarItemPresence(child: ElasticPress(child: button)),
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
      if (pop.atFoot) {
        return null;
      }
      return _buildPopButton(
        useCloseIcon: pop.useCloseIcon,
        onPressed: pop.useCloseIcon
            ? _closeSheet
            : backAction ?? () => Navigator.of(context).pop(),
      );
    }
    if (backAction != null) {
      return _buildPopButton(
        useCloseIcon: false,
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
    return _buildPopButton(
      useCloseIcon: route is PageRoute && route.fullscreenDialog,
      onPressed: () => Navigator.maybePop(context),
    );
  }

  Widget _buildTitle({required bool compact}) {
    return BarItemPresence.title(
      child:
          widget.titleWidget ??
          (widget.titleMenuItems.isEmpty
              ? Text(widget.title!)
              : PopupAnchor(
                  placement: PopupPlacement.overAnchorStart,
                  bare: true,
                  targetBuilder: (open) => _TitleMenuButton(
                    title: widget.title!,
                    compact: compact,
                    onPressed: open,
                  ),
                  popupBuilder: (_) => PopupMenu(items: widget.titleMenuItems),
                )),
    );
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
            glyph: Glyphs.search,
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
            for (final data in grouped)
              identical(data, lead)
                  ? _SearchLead(
                      key: _searchLeadKey,
                      motion: _searchMotion,
                      child: AppBarActionButton(data: data),
                    )
                  : AppBarActionButton(data: data),
          ],
        ),
      for (final data in shown.skip(grouped?.length ?? 0))
        _barButton(
          data,
          icon: identical(data, lead)
              ? _SearchGlyph(
                  motion: _searchMotion,
                  child: GlyphIcon(data.glyph),
                )
              : null,
        ),
      ...selection.build(),
      for (final action in widgets) ElasticPress(child: action),
      if (fold.overflow.isNotEmpty)
        ElasticPress(child: _OverflowMenuButton(items: fold.overflow)),
    ];
    if (lead != null) {
      actions.first = KeyedSubtree(
        key: _searchButtonKey,
        child: _SearchSwell(
          motion: _searchMotion,
          width: (grouped?.length ?? 1) * TonalButtonSize.bar.button,
          slotWidth: grouped == null ? 0 : TonalButtonSize.bar.button,
          droplet: grouped == null ? _searchOrigin : null,
          liftOf: (frame) => frame.glassLift + frame.groupSwell,
          child: actions.first,
        ),
      );
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
      fieldKey: _searchFieldKey,
      searching: _isSearch,
      actions: actions,
      actionsWidth:
          buttonCount * TonalButtonSize.bar.button +
          math.max(0, actions.length - 1) * barButtonGap,
      cancel: fills
          ? _barButton(
              IconButtonData(
                glyph: Glyphs.close,
                tooltip: UiLocalizations.of(context).cancel,
                // Not a navigator pop: before BackLayerScope's entry lands,
                // that would pop the page itself.
                onPressed: _handleExitAppBarLayer,
              ),
            )
          : null,
      glass: LiquidGlassScope.of(context)
          ? LiquidGlassStyle.regular(colorScheme)
          : null,
      color: context.raisedSurfaceLevel.colorOf(colorScheme),
      // The field's own buttons stay off the bar's button fills and glass.
      field: ButtonTheme(
        data: ButtonTheme.of(context),
        child: SearchField(
          autofocus: true,
          controller: _textController,
          focusNode: _searchFocusNode,
          onChanged: (value) => _appBarState.value?.onSearch(value),
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
                ? ActivityIndicator(size: TonalButtonSize.bar.icon)
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

  PreferredSizeWidget _buildAppBar(VoidCallback? backAction, _SheetForm form) {
    final isCompact = form.isCompact;
    final isMobileView = ViewScope.isMobileOf(context);
    final pushed =
        form.pop == null &&
        isMobileView &&
        ModalRoute.of(context)?.impliesAppBarDismissal == true;
    final compactTitle = isCompact || pushed;
    final titleEndInset = appBarActionInset(
      isCompactBar(context, isMobileView),
    );
    // Under a sheet the bar drops its actions, so none reads as the sheet's.
    final uncovered = ReverseAnimation(sheetCoverOf(context));
    return ScaffoldBar(
      isCompact: isCompact,
      backgroundColor: widget.backgroundColor,
      loading: _loadingNotifier,
      listenable: Listenable.merge([_appBarState, _searchCovered]),
      builder: (_) {
        final searchState = _appBarState.value;
        final leading = _buildLeading(backAction, pop: form.pop);
        final barSearch = searchState != null && !form.hasDockedSearch;
        final covered = barSearch && _searchCovered.value;
        final hidesBar = covered && _searchFillsBar;
        Widget underSearch(Widget child, Animation<double> opacity) => barSearch
            ? _UnderBarSearch(
                opacity: opacity,
                searching: _isSearch,
                child: child,
              )
            : child;
        Widget? underField(Widget? child, Animation<double> opacity) =>
            child == null || !_searchFillsBar
            ? child
            : underSearch(child, opacity);
        final searchLeading = barSearch && _searchFillsBar && leading != null
            ? KeyedSubtree(
                key: _searchLeadingKey,
                child: _SearchSwell(
                  motion: _searchMotion,
                  width: TonalButtonSize.bar.button,
                  liftOf: (frame) => frame.glassLift,
                  child: leading,
                ),
              )
            : leading;
        final appBar = AppBar(
          clipBehavior: Clip.none,
          toolbarHeight: isCompact ? sheetToolbarHeight : null,
          centerTitle: isCompact,
          titleTextStyle: compactTitle
              ? AppTextStyle.headline.of(context)
              : AppTextStyle.pageTitle.of(context),
          leading: hidesBar
              ? null
              : underField(searchLeading, _leadingUnderSearch),
          // The leading slot already trails its button by a margin.
          titleSpacing: leading == null ? null : 0,
          title: hidesBar
              ? null
              : underField(
                  leading == null || isCompact
                      ? _buildTitle(compact: compactTitle)
                      : Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: titleEndInset,
                          ),
                          child: _buildTitle(compact: compactTitle),
                        ),
                  _titleUnderSearch,
                ),
          actions: [
            if (!covered)
              for (final action in _buildActions(
                searchState != null,
                widget.primaryAction,
                form,
              ))
                _presentAction(
                  FadeTransition(
                    opacity: uncovered,
                    child: underSearch(
                      action,
                      action.key == _searchButtonKey
                          ? _leadUnderSearch
                          : _actionsUnderSearch,
                    ),
                  ),
                  gap: action is SizedBox || action is ActionEdgeGap,
                ),
          ],
        );
        return _buildAppBarWrap(appBar, barSearch: barSearch);
      },
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
    _searchFillsBar = isCompactBar(context, ViewScope.isMobileOf(context));
    _searchDocked = form.hasDockedSearch;
    final keywords = widget.keywords;
    final docked = form.dockedSearch;
    return PrismScaffold(
      bar: _buildAppBar(backAction, form),
      body: SortModeScope(sorting: _sorting, child: widget.body),
      headerListenable: keywords,
      headerBuilder: keywords == null
          ? null
          : (_) => keywords.value.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: _KeywordStrip(keywords: keywords.value),
                  ),
      foot: docked == null ? null : _buildDockedSearch(docked),
      footHidden: _sorting,
      footInset: BottomInsetScope.dockedSearchInset,
      footActions: form.pop?.atFoot == true
          ? _buildFootActions(widget.confirmationAction!)
          : null,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
    );
  }
}
