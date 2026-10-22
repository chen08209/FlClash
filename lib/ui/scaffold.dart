import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

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
    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch('');
    }
  }

  void handleExitSearching() {
    if (!_isSearch) {
      return;
    }
    final field = _measureInBar(_searchFieldKey);
    _searchOrigin.value = _searchOrigin.value?.withField(field);
    _handleClearInput();
    _searchFocusNode.unfocus();
    _updateSearchState((state) => state?.copyWith(query: null));
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
              Widget underSearch(Widget child, Animation<double> opacity) =>
                  barSearch
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
              final searchLeading =
                  barSearch && _searchFillsBar && leading != null
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
                automaticallyImplyLeading: false,
                animateColor: true,
                forceMaterialTransparency: true,
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
                      state.searchState != null,
                      widget.primaryAction,
                      form,
                    ))
                      FadeTransition(
                        opacity: uncovered,
                        child: underSearch(
                          action,
                          action.key == _searchButtonKey
                              ? _leadUnderSearch
                              : _actionsUnderSearch,
                        ),
                      ),
                ],
              );
              final bar = _buildAppBarWrap(appBar, barSearch: barSearch);
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

// iOS 27's bar search, as the simulator shows it. Opening, its button group
// gives up the search button and the field grows out of what is left, about
// 3% over at its peak 0.24 s on; closing, it shrinks back in 0.15 s, and the
// group takes the search button back with a swell. A back button takes the
// field back, the group its cancel button; the glass swells through the change
// as under a press. Each part starts as the last slows, where iOS pauses.
// A lone button takes a field at the bar's end in on a softer spring, then
// swells; past one across the bar it re-forms out of a droplet that starts a
// quarter of the way to the field at a quarter of its size and overshoots,
// or, while a back button takes the field, pinches off the field's end.
final _searchSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 390,
  ratio: 0.75,
);
final _searchCloseSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 600,
  ratio: 0.75,
);
final _searchMorphSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 241,
  ratio: 0.77,
);
final _droplet = SpringSimulation(dropletSpring, 0, 1, 0);
const double _dropletSize = 0.25;
const _searchSettleDuration = Duration(milliseconds: 450);
final _searchCurve = SpringCurve(_searchSpring, seconds: 0.45);
const double _searchFieldGap = 12;
const double _regularSearchWidth = 280;
const double _searchBlur = 6;

double _shownAt(double t) => ((t - 0.5) / 0.4).clamp(0.0, 1.0);

Rect _lifted(Rect rect, double lift) {
  final scale = 1 + lift * ElasticPress.growthOf(rect.longestSide);
  return Rect.fromCenter(
    center: rect.center,
    width: rect.width * scale,
    height: rect.height * scale,
  );
}

Widget _blurredIn(double opacity, Widget? child) {
  final sigma = _searchBlur * (1 - opacity);
  return Opacity(
    opacity: opacity,
    child: ImageFiltered(
      enabled: sigma > 0,
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    ),
  );
}

class _SearchFrame {
  const _SearchFrame({
    required this.fieldGrowth,
    required this.slotCollapse,
    required this.fieldOpacity,
    required this.titleOpacity,
    required this.actionsOpacity,
    required this.flankOpacity,
    required this.contentOpacity,
    required this.glyphOpacity,
    required this.groupSwell,
    required this.leadingOpacity,
    required this.towardLeading,
    required this.glassLift,
    required this.leadOpacity,
    required this.fieldGlyphOpacity,
    required this.fieldSwell,
    required this.dropletOffset,
    required this.dropletSize,
    required this.flankScale,
  });

  static const closed = _SearchFrame(
    fieldGrowth: 0,
    slotCollapse: 0,
    fieldOpacity: 0,
    titleOpacity: 1,
    actionsOpacity: 1,
    flankOpacity: 0,
    contentOpacity: 0,
    glyphOpacity: 1,
    groupSwell: 0,
    leadingOpacity: 1,
    towardLeading: 0,
    glassLift: 0,
    leadOpacity: 1,
    fieldGlyphOpacity: 0,
    fieldSwell: 0,
    dropletOffset: 0,
    dropletSize: 1,
    flankScale: 1,
  );

  static const open = _SearchFrame(
    fieldGrowth: 1,
    slotCollapse: 1,
    fieldOpacity: 1,
    titleOpacity: 0,
    actionsOpacity: 0,
    flankOpacity: 1,
    contentOpacity: 1,
    glyphOpacity: 0,
    groupSwell: 0,
    leadingOpacity: 0,
    towardLeading: 0,
    glassLift: 0,
    leadOpacity: 0,
    fieldGlyphOpacity: 0,
    fieldSwell: 0,
    dropletOffset: 0,
    dropletSize: 1,
    flankScale: 1,
  );

  final double fieldGrowth;
  final double slotCollapse;
  final double fieldOpacity;
  final double titleOpacity;
  final double actionsOpacity;
  final double flankOpacity;
  final double contentOpacity;
  final double glyphOpacity;
  final double groupSwell;
  final double leadingOpacity;
  final double towardLeading;
  final double glassLift;
  final double leadOpacity;
  final double fieldGlyphOpacity;
  final double fieldSwell;
  final double dropletOffset;
  final double dropletSize;
  final double flankScale;
}

/// How a closing bar's search gives its button back.
enum _SearchReturn { group, morph, droplet, pinch }

/// One opening or closing of a bar's search, in seconds from its start as
/// iOS 27 times each part.
class _SearchMove {
  _SearchMove({
    required this.opens,
    required this.returns,
    required this.from,
    required Simulation this.growth,
    required this.delay,
  });

  _SearchMove.settled({required this.opens})
    : returns = _SearchReturn.group,
      from = opens ? _SearchFrame.open : _SearchFrame.closed,
      growth = null,
      delay = 0;

  final bool opens;
  final _SearchReturn returns;
  final _SearchFrame from;
  final Simulation? growth;
  final double delay;

  double growthAt(double time) =>
      growth?.x(math.max(0, time - delay)) ?? (opens ? 1 : 0);

  double growthVelocityAt(double time) =>
      time < delay ? 0 : growth?.dx(time - delay) ?? 0;

  bool growthSettledAt(double time) =>
      growth?.isDone(math.max(0, time - delay)) ?? true;

  bool isDoneAt(double time) =>
      time >=
          (opens
              ? 0.29
              : switch (returns) {
                  _SearchReturn.group => 0.55,
                  _SearchReturn.morph => 0.75,
                  _SearchReturn.droplet => 0.8,
                  _SearchReturn.pinch => 0.7,
                }) &&
      growthSettledAt(time);

  _SearchFrame at(double time) {
    if (isDoneAt(time)) {
      return opens ? _SearchFrame.open : _SearchFrame.closed;
    }
    double to(
      double from,
      double target,
      double start,
      double end, [
      Curve curve = Curves.linear,
    ]) {
      final t = ((time - start) / (end - start)).clamp(0.0, 1.0);
      return lerpDouble(from, target, curve.transform(t))!;
    }

    final from = this.from;
    if (opens) {
      final actionsOpacity = to(from.actionsOpacity, 0, 0.02, 0.08);
      return _SearchFrame(
        fieldGrowth: growthAt(time),
        slotCollapse: to(from.slotCollapse, 1, 0, 0.08, Curves.easeOut),
        fieldOpacity: to(from.fieldOpacity, 1, 0, 0.05),
        titleOpacity: to(from.titleOpacity, 0, 0, 0.08),
        actionsOpacity: actionsOpacity,
        flankOpacity: to(from.flankOpacity, 1, 0.08, 0.2),
        contentOpacity: to(from.contentOpacity, 1, 0.07, 0.22),
        glyphOpacity: to(from.glyphOpacity, 0, 0, 0.03),
        groupSwell: to(from.groupSwell, 0, 0, 0.1),
        leadingOpacity: to(from.leadingOpacity, 0, 0, 0.02),
        towardLeading: to(from.towardLeading, 0, 0, 0.08),
        glassLift: to(
          to(from.glassLift, 1, 0.02, 0.12, Curves.easeOut),
          0,
          0.16,
          0.29,
          Curves.easeInOut,
        ),
        leadOpacity: to(from.leadOpacity, 0, 0.02, 0.08),
        fieldGlyphOpacity: to(from.fieldGlyphOpacity, 0, 0, 0.03),
        fieldSwell: to(from.fieldSwell, 0, 0, 0.1),
        dropletOffset: to(from.dropletOffset, 0, 0, 0.05),
        dropletSize: to(from.dropletSize, 1, 0, 0.05),
        flankScale: to(from.flankScale, 1, 0, 0.05),
      );
    }
    final returns = this.returns;
    final grouped = returns == _SearchReturn.group;
    final morphs = returns == _SearchReturn.morph;
    final drips = returns == _SearchReturn.droplet;
    final pinches = returns == _SearchReturn.pinch;
    final actionsOpacity = to(from.actionsOpacity, 1, 0.18, 0.26);
    final swell = grouped
        ? to(
            to(from.groupSwell, 1, 0.27, 0.36, Curves.easeOut),
            0,
            0.36,
            0.55,
            Curves.easeInOut,
          )
        : to(from.groupSwell, 0, 0, 0.1) +
              (morphs ? 0.8 * riseAndFall(time - 0.25, 0.26, 18) : 0);
    final droplet = _droplet.x(time);
    return _SearchFrame(
      fieldGrowth: growthAt(time),
      slotCollapse: to(from.slotCollapse, 0, 0.17, 0.33, Curves.easeInOut),
      fieldOpacity: switch (returns) {
        _SearchReturn.group ||
        _SearchReturn.pinch => to(from.fieldOpacity, 0, 0.19, 0.29),
        _SearchReturn.morph => to(from.fieldOpacity, 0, 0.62, 0.7),
        _SearchReturn.droplet => to(from.fieldOpacity, 0, 0.02, 0.12),
      },
      titleOpacity: to(from.titleOpacity, 1, 0.08, 0.19),
      actionsOpacity: actionsOpacity,
      flankOpacity: drips || pinches
          ? to(from.flankOpacity, 0, 0, 0.03)
          : to(from.flankOpacity, 0, 0.11, 0.2),
      contentOpacity: to(from.contentOpacity, 0, 0, 0.04),
      glyphOpacity: switch (returns) {
        _SearchReturn.group => to(from.glyphOpacity, 1, 0.3, 0.46),
        _SearchReturn.morph => to(from.glyphOpacity, 1, 0, 0.02),
        _SearchReturn.droplet => to(from.glyphOpacity, 1, 0.3, 0.5),
        _SearchReturn.pinch => to(from.glyphOpacity, 1, 0.14, 0.3),
      },
      groupSwell: swell,
      leadingOpacity: to(from.leadingOpacity, 1, 0.16, 0.19),
      towardLeading: to(to(from.towardLeading, 1, 0, 0.08), 0, 0.4, 0.41),
      glassLift: grouped || pinches
          ? to(
              to(from.glassLift, 1, 0.06, 0.16, Curves.easeOut),
              0,
              0.21,
              0.32,
              Curves.easeInOut,
            )
          : to(from.glassLift, 0, 0, 0.1),
      leadOpacity: switch (returns) {
        _SearchReturn.group => actionsOpacity,
        _SearchReturn.morph => to(from.leadOpacity, 1, 0.61, 0.62),
        _SearchReturn.droplet ||
        _SearchReturn.pinch => to(from.leadOpacity, 1, 0, 0.02),
      },
      fieldGlyphOpacity: morphs
          ? to(from.fieldGlyphOpacity, 1, 0.33, 0.45)
          : to(from.fieldGlyphOpacity, 0, 0, 0.03),
      fieldSwell: morphs ? swell : to(from.fieldSwell, 0, 0, 0.1),
      dropletOffset: switch (returns) {
        _SearchReturn.droplet =>
          _dropletSize * (1 - droplet - 0.71 * riseAndFall(time, 0.19, 5.7)),
        _SearchReturn.pinch => 0.46 * (1 - droplet),
        _ => to(from.dropletOffset, 0, 0, 0.05),
      },
      dropletSize: switch (returns) {
        _SearchReturn.droplet => lerpDouble(
          _dropletSize,
          1,
          _droplet.x(math.max(0, time - 0.31)),
        )!,
        _SearchReturn.pinch => droplet,
        _ => to(from.dropletSize, 1, 0, 0.05),
      },
      flankScale: drips || pinches
          ? to(from.flankScale, 0, 0, 0.05)
          : to(from.flankScale, 1, 0, 0.05),
    );
  }
}

class _SearchClock extends Simulation {
  _SearchClock(this.move);

  final _SearchMove move;

  @override
  double x(double time) => time;

  @override
  double dx(double time) => 1;

  @override
  bool isDone(double time) => move.isDoneAt(time);
}

class _SearchChannel extends Animatable<double> {
  const _SearchChannel(this.motion, this.of);

  final _SearchMotion motion;
  final double Function(_SearchFrame frame) of;

  @override
  double transform(double t) => of(motion.frame);
}

class _SearchMotion {
  _SearchMotion(TickerProvider vsync)
    : _clock = AnimationController.unbounded(vsync: vsync);

  final AnimationController _clock;
  var _move = _SearchMove.settled(opens: false);
  ({_SearchMove move, double time, _SearchFrame frame})? _last;

  Listenable get listenable => _clock;

  bool get isAnimating => _clock.isAnimating;

  _SearchFrame get frame {
    final time = _clock.value;
    final last = _last;
    if (last != null && identical(last.move, _move) && last.time == time) {
      return last.frame;
    }
    final frame = _move.at(time);
    _last = (move: _move, time: time, frame: frame);
    return frame;
  }

  Animation<double> drive(double Function(_SearchFrame frame) of) =>
      _clock.drive(_SearchChannel(this, of));

  void addStatusListener(AnimationStatusListener listener) =>
      _clock.addStatusListener(listener);

  void moveTo({
    required bool open,
    _SearchReturn returns = _SearchReturn.group,
  }) {
    final time = _clock.value;
    final last = _move;
    _move = _SearchMove(
      opens: open,
      returns: returns,
      from: last.at(time),
      growth: SpringSimulation(
        open
            ? _searchSpring
            : switch (returns) {
                _SearchReturn.group => _searchCloseSpring,
                _SearchReturn.morph => _searchMorphSpring,
                _SearchReturn.droplet => dropletSpring,
                _SearchReturn.pinch => _searchCloseSpring,
              },
        last.growthAt(time),
        open ? 1 : 0,
        last.growthVelocityAt(time),
        snapToEnd: true,
      ),
      // A field already moving turns back at once.
      delay: !last.growthSettledAt(time)
          ? 0
          : open
          ? 0.05
          : returns == _SearchReturn.group || returns == _SearchReturn.pinch
          ? 0.04
          : 0,
    );
    _clock.animateWith(_SearchClock(_move));
  }

  void jumpTo({required bool open}) {
    _move = _SearchMove.settled(opens: open);
    _clock.value = 0;
  }

  void dispose() => _clock.dispose();
}

class _SearchOrigin {
  const _SearchOrigin(
    this.group,
    this.withoutSearch,
    this.leading, {
    this.lone = false,
    this.field,
  });

  factory _SearchOrigin.of(
    Rect group, {
    required Rect? lead,
    required Rect? leading,
  }) {
    final button = TonalButtonSize.bar.button;
    final back = leading == null
        ? null
        : Rect.fromCenter(
            center: leading.center,
            width: button,
            height: button,
          );
    if (lead == null) {
      return _SearchOrigin(group, group, back, lone: true);
    }
    return lead.center.dx < group.center.dx
        ? _SearchOrigin(
            Rect.fromLTRB(
              lead.right - button,
              group.top,
              group.right,
              group.bottom,
            ),
            Rect.fromLTRB(lead.right, group.top, group.right, group.bottom),
            back,
          )
        : _SearchOrigin(
            Rect.fromLTRB(
              group.left,
              group.top,
              lead.left + button,
              group.bottom,
            ),
            Rect.fromLTRB(group.left, group.top, lead.left, group.bottom),
            back,
          );
  }

  final Rect group;
  final Rect withoutSearch;
  final Rect? leading;
  final bool lone;
  final Rect? field;

  double get toField => field == null ? 0 : field!.center.dx - group.center.dx;

  _SearchOrigin withField(Rect? field) =>
      _SearchOrigin(group, withoutSearch, leading, lone: lone, field: field);

  Rect at(double slotCollapse) =>
      Rect.lerp(group, withoutSearch, slotCollapse)!;
}

/// The search button of a bar's button group, which gives its place up while
/// the search is open.
class _SearchLead extends StatelessWidget {
  const _SearchLead({super.key, required this.motion, required this.child});

  final _SearchMotion motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion.listenable,
      builder: (_, child) {
        final frame = motion.frame;
        return ClipRect(
          clipBehavior: frame.slotCollapse > 0 ? Clip.hardEdge : Clip.none,
          child: Align(
            widthFactor: 1 - frame.slotCollapse,
            heightFactor: 1,
            child: _blurredIn(frame.glyphOpacity, child),
          ),
        );
      },
      child: child,
    );
  }
}

/// A button a bar's search grows from or into, swelling as a press does.
class _SearchSwell extends StatelessWidget {
  const _SearchSwell({
    required this.motion,
    required this.width,
    this.slotWidth = 0,
    this.droplet,
    required this.liftOf,
    required this.child,
  });

  final _SearchMotion motion;
  final double width;
  final double slotWidth;

  /// Where a lone button re-forms out of a droplet from.
  final ValueListenable<_SearchOrigin?>? droplet;
  final double Function(_SearchFrame frame) liftOf;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final droplet = this.droplet;
    return AnimatedBuilder(
      animation: Listenable.merge([motion.listenable, ?droplet]),
      builder: (_, child) {
        final frame = motion.frame;
        final width = this.width - slotWidth * frame.slotCollapse;
        final origin = droplet?.value;
        final scale =
            (1 + liftOf(frame) * ElasticPress.growthOf(width)) *
            (origin == null ? 1 : frame.dropletSize);
        final shift = origin == null
            ? 0.0
            : origin.toField * frame.dropletOffset;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(shift, 0, 0)
            ..scaleByDouble(scale, scale, 1, 1),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// The glyph of a lone search button, which fades back in as it re-forms.
class _SearchGlyph extends StatelessWidget {
  const _SearchGlyph({required this.motion, required this.child});

  final _SearchMotion motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion.listenable,
      builder: (_, child) => _blurredIn(motion.frame.glyphOpacity, child),
      child: child,
    );
  }
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
    required this.fieldKey,
    required this.searching,
    required this.actions,
    required this.actionsWidth,
    required this.cancel,
    required this.glass,
    required this.color,
    required this.field,
  });

  final _SearchMotion motion;
  final Animation<double> opacity;
  final ValueListenable<_SearchOrigin?> origin;
  final GlobalKey fieldKey;
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
    final glyph = GlyphIcon(
      AppGlyphs.search,
      fill: 1,
      size: TonalButtonSize.bar.icon,
      color: context.colorScheme.onSurface,
    );
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
              animation: Listenable.merge([motion.listenable, origin]),
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
                final frame = motion.frame;
                final growth = frame.fieldGrowth;
                final grown = math.max(0.0, growth);
                final measured = origin.value;
                final group =
                    measured?.at(frame.slotCollapse) ??
                    place(fieldEnd - height, fieldEnd);
                final leading = cancel == null ? null : measured?.leading;
                final from = leading == null
                    ? group
                    : Rect.lerp(group, leading, frame.towardLeading)!;
                final fieldRect = _lifted(
                  Rect.lerp(from, slot, growth)!,
                  frame.glassLift + frame.fieldSwell,
                );
                Widget grow(
                  Rect rest,
                  Widget child, {
                  required bool leads,
                  Rect? home,
                }) {
                  final facesRight = leads != rtl;
                  final reach = lerpDouble(
                    height / 2,
                    -_searchFieldGap,
                    grown,
                  )!;
                  final anchor = facesRight
                      ? fieldRect.left + reach
                      : fieldRect.right - reach;
                  final size = rest.size * grown;
                  var rect = Rect.fromLTWH(
                    facesRight ? anchor - size.width : anchor,
                    rest.center.dy - size.height / 2,
                    size.width,
                    size.height,
                  );
                  if (home != null) {
                    rect = Rect.lerp(
                      rect,
                      Rect.lerp(home, rest, grown),
                      frame.towardLeading,
                    )!;
                  }
                  rect = _lifted(rect, frame.glassLift);
                  rect = Rect.fromCenter(
                    center: rect.center,
                    width: rect.width * frame.flankScale,
                    height: rect.height * frame.flankScale,
                  );
                  final scale = rect.width / rest.width;
                  return Positioned.fromRect(
                    rect: rest,
                    child: Transform(
                      transform: Matrix4.translationValues(
                        rect.left - rest.left,
                        rect.top - rest.top,
                        0,
                      )..scaleByDouble(scale, scale, 1, 1),
                      child: _blurredIn(frame.flankOpacity, child),
                    ),
                  );
                }

                return TextFieldTapRegion(
                  child: Stack(
                    children: [
                      Positioned.fromRect(
                        rect: fieldRect,
                        child: ElasticPress(
                          key: fieldKey,
                          child: GooPane(
                            child: ClipRSuperellipse(
                              borderRadius: AppRadius.full,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _blurredIn(frame.contentOpacity, content),
                                  if (frame.fieldGlyphOpacity > 0)
                                    _blurredIn(frame.fieldGlyphOpacity, glyph),
                                ],
                              ),
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
                        grow(
                          place(end - height, end),
                          cancel,
                          leads: false,
                          home: leading == null
                              ? null
                              : measured?.withoutSearch,
                        ),
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

Widget _barButton(IconButtonData data, {Widget? icon}) => ElasticPress(
  enabled: !data.isLoading && data.onPressed != null,
  child: AppBarActionButton(data: data, icon: icon),
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
  final kept = foldable.take(slots < 0 ? 0 : slots).toList();
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
  const AppBarActionButton({super.key, required this.data, this.icon});

  final IconButtonData data;

  /// Stands in for the glyph of [data].
  final Widget? icon;

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
          : icon ?? GlyphIcon(data.glyph),
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
