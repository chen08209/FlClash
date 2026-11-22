import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

const _clearance = 16.0;

/// Starts a tab's content [_clearance] under the tabs, for a first section
/// that passes `atTop` to add no gap of its own.
EdgeInsets detailTabPaddingOf(BuildContext context) {
  final margin = context.listInsets.margin;
  return EdgeInsets.fromLTRB(
    margin,
    _clearance,
    margin,
    margin + context.bottomInset,
  );
}

class DetailTabs extends StatefulWidget {
  final List<(String label, WidgetBuilder builder)> tabs;
  final int initialIndex;

  /// Stays above the control whichever tab shows.
  final Widget? header;

  const DetailTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.header,
  });

  /// Turns the [DetailTabs] around [context] to the tab at [index].
  static void select(BuildContext context, int index) =>
      context.findAncestorStateOfType<_DetailTabsState>()?._select(index);

  @override
  State<DetailTabs> createState() => _DetailTabsState();
}

class _DetailTabsState extends State<DetailTabs> {
  late var _index = widget.initialIndex;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final header = widget.header;
    if (tabs.length == 1 && header == null) {
      return tabs.single.$2(context);
    }
    final index = _index.clamp(0, tabs.length - 1);
    final margin = context.listInsets.margin;
    final compact = ViewScope.isMobileOf(context);
    final control = SegmentedControl<int>(
      size: TonalButtonSize.section,
      stretches: compact,
      segments: [
        for (final (index, (label, _)) in tabs.indexed) (index, label),
      ],
      value: index,
      onChanged: _select,
    );
    return Padding(
      padding: EdgeInsets.only(top: context.contentTopPadding),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: FloatingBarScope(
          inset: 0,
          child: TopInsetScope(
            inset: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      margin,
                      0,
                      margin,
                      compact ? 12 : 16,
                    ),
                    child: header,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: margin),
                  child: compact
                      ? control
                      : Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: control,
                          ),
                        ),
                ),
                Expanded(
                  child: ClipRect(
                    clipper: const _BelowClearance(),
                    child: KeyedSubtree(
                      key: ValueKey(index),
                      child: Builder(builder: tabs[index].$2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BelowClearance extends CustomClipper<Rect> {
  const _BelowClearance();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, _clearance, size.width, size.height);

  @override
  bool shouldReclip(_BelowClearance oldClipper) => false;
}
