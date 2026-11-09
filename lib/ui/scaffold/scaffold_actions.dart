part of 'scaffold.dart';

class _KeywordStrip extends StatelessWidget {
  const _KeywordStrip({required this.keywords});

  final List<ScaffoldKeyword> keywords;

  static const _inset = 16.0;
  static const _sectionGap = 20.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TonalButtonSize.section.button,
      child: WidthBuilder(
        builder: (_, width) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _inset),
          itemCount: keywords.length,
          separatorBuilder: (_, index) => SizedBox(
            width: keywords[index + 1].startsSection ? _sectionGap : 8,
          ),
          itemBuilder: (_, index) {
            final keyword = keywords[index];
            return ConstrainedBox(
              key: ValueKey(keyword.key),
              constraints: BoxConstraints(
                maxWidth: math.max(0, width - 2 * _inset),
              ),
              child: Chip(
                label: keyword.label,
                onDeleted: keyword.onDeleted,
                onPressed: keyword.onPressed,
                selected: keyword.selected,
              ),
            );
          },
        ),
      ),
    );
  }
}

const _maxBarButtons = 3;
const _maxGroupedActions = 2;

Widget _presentAction(Widget action, {required bool gap}) =>
    gap ? action : BarItemPresence(child: action);

Widget _barButton(IconButtonData data, {Widget? icon}) => ElasticPress(
  enabled: !data.isLoading && data.onPressed != null,
  child: AppBarActionButton(data: data, icon: icon),
);

/// [Scaffold.selectionActions] as the bar shows them, searching or not.
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

({List<IconButtonData> shown, List<PopupMenuItem> overflow}) _foldBarActions({
  required bool hasLead,
  IconButtonData? primary,
  List<IconButtonData> icons = const [],
  IconButtonData? confirmation,
  int widgetCount = 0,
  List<PopupMenuItem> menuItems = const [],
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
          PopupMenuItem(
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

  final List<PopupMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return PopupAnchor(
      targetBuilder: (open) => IconButton(
        tooltip: UiLocalizations.of(context).more,
        onPressed: open,
        icon: const BarItemGlyph(child: GlyphIcon(Glyphs.more)),
      ),
      popupBuilder: (_) => PopupMenu(items: items),
    );
  }
}

/// What the surface asks of this scaffold's search and pop button: it and a
/// phone page pushed over the one with the tab bar search from a field docked
/// over their foot instead of a button that takes the bar over.
class _SheetForm {
  const _SheetForm({
    required this.isCompact,
    required this.dockedSearch,
    required this.pop,
  });

  factory _SheetForm.of(
    BuildContext context, {
    required AppBarSearchState? searchState,
    required bool searchInBar,
    required bool hasConfirmationAction,
  }) {
    final surface = ScaffoldSurface.of(context);
    // iOS 27 docks the search of a phone page with no tab bar under it at its
    // foot, a glass field in sight at rest.
    final docksSearch =
        surface.isCompact ||
        (!searchInBar &&
            !surface.isModal &&
            ViewScope.isMobileOf(context) &&
            ModalRoute.of(context)?.impliesAppBarDismissal == true);
    return _SheetForm(
      isCompact: surface.isCompact,
      dockedSearch: docksSearch ? searchState : null,
      pop: !surface.isModal
          ? null
          : _SheetPop.of(
              context,
              surface.provider!,
              hasConfirmationAction:
                  hasConfirmationAction && searchState == null,
            ),
    );
  }

  final bool isCompact;
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
    return PressRegion(
      onTap: onPressed,
      shape: AppShape.sm,
      overlay: PressRegion.focusOverlay,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: compact ? 2 : 4,
        children: [
          Flexible(child: Text(title)),
          GlyphIcon(
            Glyphs.chevronDown,
            size: compact ? 16 : 20,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const BaseScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body, title: title);
  }
}

IconButtonData sortModeAction(
  BuildContext context, {
  required bool sorting,
  required VoidCallback? onPressed,
}) {
  final localizations = UiLocalizations.of(context);
  return IconButtonData(
    glyph: Glyphs.sort,
    onPressed: onPressed,
    tooltip: localizations.sort,
    isSelected: sorting,
  );
}
