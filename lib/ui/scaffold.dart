import 'dart:math' as math;

import 'package:fl_clash/common/input_limits.dart';
import 'package:fl_clash/common/iterable.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/keyboard.dart';
import 'package:fl_clash/ui/l10n.dart';
import 'package:fl_clash/ui/measure.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/models.dart';
import 'package:fl_clash/ui/pop_scope.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:fl_clash/ui/view_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'button.dart';
import 'chip.dart';
import 'dialog.dart';
import 'inherited.dart';
import 'liquid_glass.dart';
import 'loading.dart';
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

class CommonScaffoldState extends State<CommonScaffold> {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final _textController = TextEditingController();
  final _searchFocusNode = FocusNode();
  var _sorting = false;

  bool get _isSearch {
    return _appBarState.value.searchState?.query != null;
  }

  bool get _hasActions {
    return widget.canSort ||
        widget.primaryAction != null ||
        widget.iconActions.isNotEmpty ||
        widget.confirmationAction != null ||
        widget.menuItems.isNotEmpty ||
        widget.actions?.isNotEmpty == true;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(AppBarState(searchState: widget.searchState));
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
    if (_isSearch || context.isInCompactSheet) {
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
      SurfaceLevel.card.colorOf(context.colorScheme);

  Widget _buildSearchingAppBarTheme(Widget child) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: _searchingBackgroundColor,
              titleTextStyle: AppTextStyle.body.of(context),
              toolbarTextStyle: AppTextStyle.subheadline.of(context),
            ),
          ),
          child: SurfaceScope(
            level: SurfaceLevel.card,
            child: InputDecorationTheme(
              data: InputDecorationThemeData(
                hintStyle: theme.inputDecorationTheme.hintStyle,
                border: InputBorder.none,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState != widget.searchState) {
      final query = _appBarState.value.searchState?.query;
      _appBarState.value = _appBarState.value.copyWith(
        searchState: widget.searchState?.copyWith(query: query),
      );
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
    final colorScheme = context.colorScheme;
    final glass = LiquidGlassScope.of(context);
    final pill = AppShape.input.copyWith(borderRadius: AppRadius.full);
    final fieldPadding =
        (BottomInsetScope.dockedSearchHeight -
            MeasureScope.of(context).textHeight(AppTextStyle.body)) /
        2;
    final field = InputDecorationTheme(
      data: InputDecorationTheme.of(context).copyWith(
        filled: !glass,
        fillColor: SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
        border: pill.copyWith(borderSide: BorderSide.none),
        focusedBorder: pill.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: fieldPadding,
        ),
      ),
      child: SearchField(
        controller: _textController,
        focusNode: _searchFocusNode,
        onChanged: searchState.onSearch,
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
        child: glass
            ? LiquidGlass(
                style: LiquidGlassStyle.pill(colorScheme),
                shadows: dockGlassShadows(colorScheme),
                child: field,
              )
            : DecoratedBox(
                decoration: ShapeDecoration(
                  shape: AppShape.full,
                  shadows: dockShadows(colorScheme),
                ),
                child: field,
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
    final hidden = _sorting && !_isSearch;
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
    if (_isSearch) {
      return IconButton(
        tooltip: UiLocalizations.of(context).back,
        onPressed: _popAppBarLayer,
        icon: const GlyphIcon(AppGlyphs.arrowBack),
      );
    }
    if (pop != null) {
      return pop.asSuffix || pop.atFoot
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

  Widget _buildTitle(AppBarSearchState? startState, {required bool compact}) {
    final localizations = UiLocalizations.of(context);
    return _isSearch
        ? TextField(
            autofocus: true,
            controller: _textController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            inputFormatters: TextInputLimits.limit(TextInputLimits.search),
            style: AppTextStyle.body.of(context),
            onChanged: (value) {
              if (startState != null) {
                startState.onSearch(value);
              }
            },
            decoration: InputDecoration(hintText: localizations.search),
          )
        : widget.titleWidget ??
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
    VoidCallback? backAction,
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
    final localizations = UiLocalizations.of(context);
    final pop = form.pop;
    final lead = _isSearch
        ? IconButtonData(
            glyph: AppGlyphs.close,
            tooltip: localizations.clearSearch,
            onPressed: _handleClear,
          )
        : hasSearch && !form.hasDockedSearch
        ? IconButtonData(
            glyph: AppGlyphs.search,
            tooltip: localizations.search,
            onPressed: _handleToSearch,
          )
        : null;
    final widgets = _isSearch
        ? const <Widget>[]
        : widget.actions ?? const <Widget>[];
    final selection = widget.selectionActions;
    final selectionGroup = selection.take(_maxGroupedActions);
    final selectionSingles = selection.skip(_maxGroupedActions);
    final selectionCount =
        (selection.isEmpty ? 0 : 1) + selectionSingles.length;
    final popAsSuffix = !_isSearch && pop?.asSuffix == true;
    final pairedPrimary = popAsSuffix ? primaryAction : null;
    final atFoot = pop?.atFoot == true;
    final fold = _isSearch
        ? _foldBarActions(
            hasLead: true,
            icons: widget.searchActions,
            widgetCount: selectionCount,
          )
        : _foldBarActions(
            hasLead: lead != null,
            primary: pairedPrimary == null ? primaryAction : null,
            foldPrimary: widget.foldPrimaryAction,
            icons: [
              if (widget.canSort)
                sortModeAction(
                  context,
                  sorting: false,
                  onPressed: _toggleSorting,
                ),
              ...widget.iconActions,
            ],
            confirmation: atFoot ? null : widget.confirmationAction,
            widgetCount:
                widgets.length +
                selectionCount +
                (pairedPrimary == null ? 0 : 1),
            menuItems: widget.menuItems,
          );
    final shown = [?lead, ...fold.shown];
    final grouped = shown.length > 1 ? shown.take(_maxGroupedActions) : null;
    return genActions([
      if (grouped != null)
        TonalButtonGroup(
          children: [
            for (final data in grouped) AppBarActionButton(data: data),
          ],
        ),
      for (final data in shown.skip(grouped?.length ?? 0))
        ElasticPress(
          enabled: !data.isLoading && data.onPressed != null,
          child: AppBarActionButton(data: data),
        ),
      if (selection.isNotEmpty)
        TonalButtonGroup(
          children: [
            for (final data in selectionGroup) AppBarActionButton(data: data),
          ],
        ),
      for (final data in selectionSingles)
        ElasticPress(
          enabled: !data.isLoading && data.onPressed != null,
          child: AppBarActionButton(data: data),
        ),
      for (final action in widgets) ElasticPress(child: action),
      if (fold.overflow.isNotEmpty)
        ElasticPress(child: _OverflowMenuButton(items: fold.overflow)),
      if (pairedPrimary != null)
        TonalButtonGroup(
          children: [
            AppBarActionButton(data: pairedPrimary),
            _buildSheetPopButton(backAction, useCloseIcon: pop!.useCloseIcon),
          ],
        )
      else if (popAsSuffix)
        ElasticPress(
          child: _buildSheetPopButton(
            backAction,
            useCloseIcon: pop!.useCloseIcon,
          ),
        ),
    ], edge: AppBarActionEdge.container);
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

  Widget _buildAppBarWrap(Widget child) {
    final appBar = TonalButtonTheme(
      glass: LiquidGlassScope.of(context),
      child: _isSearch ? _buildSearchingAppBarTheme(child) : child,
    );
    if (_isSearch || _sorting) {
      return BackLayerScope(onBack: _handleExitAppBarLayer, child: appBar);
    }
    return appBar;
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
          ValueListenableBuilder<AppBarState>(
            valueListenable: _appBarState,
            builder: (_, state, _) {
              final leading = _buildLeading(backAction, pop: form.pop);
              final appBar = _buildAppBarWrap(
                AppBar(
                  clipBehavior: Clip.none,
                  automaticallyImplyLeading: false,
                  animateColor: true,
                  // A searching bar carries its own opaque theme.
                  forceMaterialTransparency: isCompact || !_isSearch,
                  toolbarHeight: isCompact ? sheetToolbarHeight : null,
                  centerTitle: isCompact,
                  titleTextStyle: _isSearch
                      ? null
                      : compactTitle
                      ? AppTextStyle.headline.of(context)
                      : AppTextStyle.pageTitle.of(context),
                  leading: leading,
                  // The leading slot already trails its button by a margin.
                  titleSpacing: leading == null ? null : 0,
                  title: leading == null || isCompact || _isSearch
                      ? _buildTitle(state.searchState, compact: compactTitle)
                      : Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: titleEndInset,
                          ),
                          child: _buildTitle(
                            state.searchState,
                            compact: compactTitle,
                          ),
                        ),
                  actions: [
                    for (final action in _buildActions(
                      state.searchState != null,
                      widget.primaryAction,
                      backAction,
                      form,
                    ))
                      FadeTransition(opacity: uncovered, child: action),
                  ],
                ),
              );
              return isCompact
                  ? appBar
                  : _buildFloatingHeader(
                      _WindowControlsClearance(child: appBar),
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
    assert(widget.title != null || widget.titleWidget != null);
    final backAction = widget.backAction;
    final form = _SheetForm.of(
      context,
      searchState: widget.searchState,
      hasActions: _hasActions,
      hasPrimaryAction: widget.primaryAction != null,
      hasConfirmationAction: widget.confirmationAction != null,
    );
    final isCompact = form.isCompact;
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
      child: ValueListenableBuilder(
        valueListenable: _keywordsNotifier,
        builder: (context, keywords, _) {
          if (widget.onKeywordsUpdate != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onKeywordsUpdate!(keywords);
            });
          }
          final hasKeywords = keywords.isNotEmpty;
          final barInset = MediaQuery.paddingOf(context).top;
          final overlap = barFloats
              ? barInset
              : isCompact
              ? sheetAppBarHeight
              : 0.0;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hugsContent ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (hasKeywords) ...[
                SizedBox(height: barInset),
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: isCompact ? sheetAppBarHeight : 16,
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
              ],
              Flexible(
                fit: hugsContent ? FlexFit.loose : FlexFit.tight,
                child: hasKeywords
                    ? MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: FloatingBarScope(inset: 0, child: sortableBody),
                      )
                    : sortableBody,
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
    final appBar = _buildAppBar(backAction, form);
    final content = form.hasDockedSearch
        ? BottomInsetScope(
            inset: bottomInset + BottomInsetScope.dockedSearchInset,
            child: body,
          )
        : body;
    if (!isCompact) {
      return AppBarInsetScope(
        child: Scaffold(
          appBar: appBar,
          extendBodyBehindAppBar: barFloats,
          body: _BodyScope(child: content),
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
/// floats its bar over the body and searches from a field docked over its
/// foot instead of a button that takes the bar over.
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
    required bool hasActions,
    required bool hasPrimaryAction,
    required bool hasConfirmationAction,
  }) {
    final provider = SheetProvider.of(context);
    final isModal = provider != null && provider.type != SheetType.page;
    final isCompact = provider?.type.isCompact ?? false;
    return _SheetForm(
      isCompact: isCompact,
      hasDragHandle: provider?.type == SheetType.bottomSheet,
      dockedSearch: isCompact ? searchState : null,
      pop: !isModal
          ? null
          : _SheetPop.of(
              context,
              provider,
              // A bottom sheet docks its search at its foot, not in the bar.
              hasActions: hasActions || searchState != null && !isCompact,
              hasPrimaryAction: hasPrimaryAction,
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
/// sheet, and [asSuffix] where it ends the bar, alone or with a primary action.
class _SheetPop {
  const _SheetPop({
    required this.useCloseIcon,
    required this.asSuffix,
    required this.atFoot,
  });

  factory _SheetPop.of(
    BuildContext context,
    SheetProvider provider, {
    required bool hasActions,
    required bool hasPrimaryAction,
    required bool hasConfirmationAction,
  }) {
    final useCloseIcon =
        provider.nestedNavigatorPop == null ||
        ModalRoute.of(context)?.impliesAppBarDismissal == false;
    final atFoot =
        useCloseIcon &&
        hasConfirmationAction &&
        provider.type == SheetType.formSheet;
    return _SheetPop(
      useCloseIcon: useCloseIcon,
      asSuffix: !atFoot && useCloseIcon && (!hasActions || hasPrimaryAction),
      atFoot: atFoot,
    );
  }

  final bool useCloseIcon;
  final bool asSuffix;
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
