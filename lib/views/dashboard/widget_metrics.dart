import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

const dashboardCellCrossAxisCount = 4;
const _minUnitHeight = 80.0;
const _maxUnitHeight = 120.0;
const _maxTextScale = 1.15;
const _baseInset = 16.0;
const _baseVerticalInset = 14.0;
const _maxInset = 22.0;

enum DashboardGridBand {
  compact(columns: 8),
  medium(columns: 12),
  wide(columns: 16);

  static const _mediumBreakpoint = 480.0;
  static const _wideBreakpoint = 840.0;

  final int columns;

  const DashboardGridBand({required this.columns});

  static DashboardGridBand of(double gridWidth) => switch (gridWidth) {
    < _mediumBreakpoint => compact,
    <= _wideBreakpoint => medium,
    _ => wide,
  };
}

final dashboardMaxGridWidth =
    280.0 * DashboardGridBand.wide.columns / dashboardCellCrossAxisCount;

/// Cards keep the phone height up to the grid the default 680 wide window
/// leaves beside the collapsed sidebar, then grow with it, so the 12-column
/// cards stay under about 2.8:1 and the 16-column ones near 2.2:1.
double dashboardUnitHeight(double gridWidth) {
  const start = 600.0;
  final progress = ((gridWidth - start) / (dashboardMaxGridWidth - start))
      .clamp(0.0, 1.0);
  return (_minUnitHeight + progress * (_maxUnitHeight - _minUnitHeight)).ap;
}

class DashboardWidgetMetrics extends InheritedTheme {
  final double unitHeight;

  DashboardWidgetMetrics({
    super.key,
    required this.unitHeight,
    required Widget child,
  }) : super(child: _DashboardTextScale(child: child));

  static double _unitHeightOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<DashboardWidgetMetrics>()
            ?.unitHeight ??
        _minUnitHeight.ap;
  }

  static double progressOf(BuildContext context) {
    final minUnitHeight = _minUnitHeight.ap;
    final maxUnitHeight = _maxUnitHeight.ap;
    final progress =
        (_unitHeightOf(context) - minUnitHeight) /
        (maxUnitHeight - minUnitHeight);
    return progress.clamp(0.0, 1.0);
  }

  static double textScaleOf(BuildContext context) {
    return 1 + progressOf(context) * (_maxTextScale - 1);
  }

  static double insetOf(BuildContext context) {
    return _lerpInset(context, _baseInset);
  }

  static double verticalInsetOf(BuildContext context) {
    return _lerpInset(context, _baseVerticalInset);
  }

  static double _lerpInset(BuildContext context, double base) {
    return (base + progressOf(context) * (_maxInset - base)).mAp;
  }

  static EdgeInsets paddingOf(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: insetOf(context),
      vertical: verticalInsetOf(context),
    );
  }

  static double heightOf(BuildContext context, num lines) {
    final unitHeight = _unitHeightOf(context);
    return max(lines * (unitHeight + cardSpacing) - cardSpacing, 0);
  }

  static double radiusOf(BuildContext context) {
    return AppCorner.lg * _unitHeightOf(context) / _minUnitHeight.ap;
  }

  /// A row inset by [inset] inside the card stays concentric with it until
  /// the radius passes a third of the row's [height], the same ceiling as
  /// [AppCorner.fit]; past it a continuous corner turns a short row into a
  /// pill while a taller row beside it keeps its corners.
  static double innerRadiusOf(
    BuildContext context, {
    required double inset,
    required double height,
  }) {
    return max(min(radiusOf(context) - inset, height / 3), 0);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DashboardWidgetMetrics(unitHeight: unitHeight, child: child);
  }

  @override
  bool updateShouldNotify(DashboardWidgetMetrics oldWidget) {
    return unitHeight != oldWidget.unitHeight;
  }
}

class _DashboardTextScale extends StatelessWidget {
  final Widget child;

  const _DashboardTextScale({required this.child});

  @override
  Widget build(BuildContext context) {
    final scale = DashboardWidgetMetrics.textScaleOf(context);
    final theme = Theme.of(context);
    // Also at scale 1, so crossing it never changes the subtree's shape.
    return Theme(
      data: scale == 1
          ? theme
          : theme.copyWith(
              textTheme: theme.textTheme.apply(fontSizeFactor: scale),
            ),
      child: child,
    );
  }
}
