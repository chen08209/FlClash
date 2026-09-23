import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrafficUsage extends StatelessWidget {
  const TrafficUsage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 2),
      child: RepaintBoundary(
        child: CommonCard(
          radius: DashboardWidgetMetrics.radiusOf(context),
          infoPadding: DashboardWidgetMetrics.paddingOf(
            context,
          ).copyWith(bottom: 0),
          info: Info(
            label: appLocalizations.trafficUsage,
            glyph: AppGlyphs.dataUsage,
          ),
          onPressed: () {},
          child: Consumer(
            builder: (_, ref, _) {
              final totalTraffic = ref.watch(totalTrafficProvider);
              return _TrafficUsageBody(
                up: totalTraffic.up,
                down: totalTraffic.down,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrafficUsageBody extends StatelessWidget {
  const _TrafficUsageBody({required this.up, required this.down});

  final num up;
  final num down;

  @override
  Widget build(BuildContext context) {
    final upColor = globalState.theme.darken3PrimaryContainer;
    final downColor = globalState.theme.darken2SecondaryContainer;
    return Padding(
      padding: DashboardWidgetMetrics.paddingOf(context).copyWith(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: _TrafficChart(
              up: up,
              down: down,
              upColor: upColor,
              downColor: downColor,
            ),
          ),
          _TrafficDataItem(
            icon: GlyphIcon(AppGlyphs.arrowUp, color: upColor, size: 14),
            value: up,
          ),
          const SizedBox(height: 8),
          _TrafficDataItem(
            icon: GlyphIcon(AppGlyphs.arrowDown, color: downColor, size: 14),
            value: down,
          ),
        ],
      ),
    );
  }
}

const _minChartSize = 56.0;
const _maxChartSize = 96.0;

class _TrafficChart extends StatelessWidget {
  const _TrafficChart({
    required this.up,
    required this.down,
    required this.upColor,
    required this.downColor,
  });

  final num up;
  final num down;
  final Color upColor;
  final Color downColor;

  @override
  Widget build(BuildContext context) {
    final legendWidth = _TrafficLegend.widthOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final besideLegend = constraints.maxWidth - legendWidth - 8;
          final showsLegend = besideLegend >= _minChartSize.ap;
          final chartSize = showsLegend
              ? min(_maxChartSize.ap, besideLegend)
              : _maxChartSize.ap;
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: chartSize,
                  maxHeight: chartSize,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DonutChart(
                    data: [
                      DonutChartData(value: up.toDouble(), color: upColor),
                      DonutChartData(value: down.toDouble(), color: downColor),
                    ],
                  ),
                ),
              ),
              if (showsLegend) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: _TrafficLegend(upColor: upColor, downColor: downColor),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TrafficLegend extends StatelessWidget {
  const _TrafficLegend({required this.upColor, required this.downColor});

  final Color upColor;
  final Color downColor;

  static double widthOf(BuildContext context) {
    final (uploadLabel, downloadLabel) = _labels(context);
    return max(
          globalState.measure.computeTextSize(uploadLabel).width,
          globalState.measure.computeTextSize(downloadLabel).width,
        ) +
        24;
  }

  static (Text, Text) _labels(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final labelStyle = context.textTheme.bodySmall;
    return (
      _label(appLocalizations.upload, labelStyle),
      _label(appLocalizations.download, labelStyle),
    );
  }

  static Text _label(String text, TextStyle? style) {
    return Text(
      maxLines: 1,
      text,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (uploadLabel, downloadLabel) = _labels(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendEntry(color: upColor, label: uploadLabel),
        const SizedBox(height: 4),
        _LegendEntry(color: downColor, label: downloadLabel),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final Text label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 8,
          decoration: ShapeDecoration(color: color, shape: AppShape.full),
        ),
        const SizedBox(width: 4),
        label,
      ],
    );
  }
}

class _TrafficDataItem extends StatelessWidget {
  const _TrafficDataItem({required this.icon, required this.value});

  final GlyphIcon icon;
  final num value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: Text(
                  value.traffic.value,
                  style: context.textTheme.bodySmall,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Text(value.traffic.unit, style: context.textTheme.bodySmall?.toLighter),
      ],
    );
  }
}
