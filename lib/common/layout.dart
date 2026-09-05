import 'dart:math';
import 'dart:ui' show Size;

import 'package:fl_clash/enum/enum.dart';

import 'constant.dart';

double getWindowHeaderHeight({required bool isDesktop, required bool isMacOS}) {
  if (!isDesktop) return 0;
  return isMacOS ? 28 : 32;
}

/// Windows 11 draws its caption buttons 46 wide over a 32 tall title bar
/// and renders every glyph as a 10x10 Segoe Fluent icon.
const captionButtonWidth = 46.0;
const captionGlyphSize = 10.0;

/// The pin is not a caption button: it keeps the round Material button in a
/// square slot the height of the bar, with a regular icon size.
const pinIconSize = 16.0;

Size getCaptionButtonSize(double headerHeight) =>
    Size(captionButtonWidth, headerHeight);

bool showsWindowHeader({
  required bool isDesktop,
  required bool isMacOS,
  required int version,
  required bool isMobileView,
}) {
  if (!isDesktop) return false;
  return !(isMacOS && (version <= 10 || !isMobileView));
}

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

const profileItemMinWidth = 270.0;

int getProfilesColumns(
  double viewWidth, {
  double spacing = 0,
  double minItemWidth = profileItemMinWidth,
}) {
  final columns = (viewWidth + spacing) / (minItemWidth + spacing);
  return max(columns.floor(), 1);
}
