import 'dart:math';

import 'package:fl_clash/enum/enum.dart';

import 'constant.dart';

double getWindowHeaderHeight({required bool isDesktop, required bool isMacOS}) {
  if (!isDesktop) return 0;
  return isMacOS ? 28 : 40;
}

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
