import 'dart:math';

import 'package:fl_clash/enum/enum.dart';

import 'constant.dart';

ViewMode getViewMode(double viewWidth) {
  if (viewWidth <= maxMobileWidth) return ViewMode.mobile;
  if (viewWidth <= maxLaptopWidth) return ViewMode.laptop;
  return ViewMode.desktop;
}

int getProxiesColumns(double viewWidth, ProxiesLayout proxiesLayout) {
  final columns = max((viewWidth / 250).ceil(), 2);
  return switch (proxiesLayout) {
    ProxiesLayout.tight => columns + 1,
    ProxiesLayout.standard => columns,
    ProxiesLayout.loose => columns - 1,
  };
}

/// The narrowest a profile card may be before the quota row inside it, which
/// puts traffic on the left and the expiry date on the right of a single line,
/// runs out of room and starts to ellipsize.
///
/// Derived from the widest realistic row rather than picked by eye:
/// `1023.9 GB / 1023.9 GB` plus a 12px gap plus a `2026-11-03` expiry needs
/// about 227px at the row's 14px type, and the card spends another 92px on
/// horizontal padding, the trailing menu button, and the gap before it.
const profileItemMinWidth = 320.0;

/// The number of columns that fit in [viewWidth] while keeping every card at
/// least [minItemWidth] wide.
///
/// [Grid] puts [spacing] between columns, so a card is not `viewWidth /
/// columns` wide but `(viewWidth + spacing) / columns - spacing`. Dividing
/// [viewWidth] by the minimum alone ignores that and overshoots by a column
/// right at each breakpoint, handing every card less room than was asked for.
/// Inverting the real stride is what makes the minimum an actual guarantee.
int getProfilesColumns(
  double viewWidth, {
  double spacing = 0,
  double minItemWidth = profileItemMinWidth,
}) {
  final columns = (viewWidth + spacing) / (minItemWidth + spacing);
  return max(columns.floor(), 1);
}
