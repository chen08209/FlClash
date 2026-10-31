import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

const _clearance = 16.0;

class DetailTabs extends StatefulWidget {
  final List<(String label, WidgetBuilder builder)> tabs;

  const DetailTabs({super.key, required this.tabs});

  @override
  State<DetailTabs> createState() => _DetailTabsState();
}

class _DetailTabsState extends State<DetailTabs> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    if (tabs.length == 1) {
      return tabs.single.$2(context);
    }
    final index = _index.clamp(0, tabs.length - 1);
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedControl<int>(
                    segments: [
                      for (final (index, (label, _)) in tabs.indexed)
                        (index, label),
                    ],
                    value: index,
                    onChanged: (value) => setState(() => _index = value),
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

/// Scrolled rows stop short of the control; a tab at rest starts on its first
/// header's own gap, which is wider, so nothing at rest is cut.
class _BelowClearance extends CustomClipper<Rect> {
  const _BelowClearance();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, _clearance, size.width, size.height);

  @override
  bool shouldReclip(_BelowClearance oldClipper) => false;
}
