import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrafficUsage extends StatelessWidget {
  const TrafficUsage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: getWidgetHeight(2),
      child: RepaintBoundary(
        child: CommonCard(
          info: Info(
            label: appLocalizations.trafficUsage,
            iconData: Icons.data_saver_off,
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
      padding: baseInfoEdgeInsets.copyWith(top: 0),
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
            icon: Icon(Icons.arrow_upward, color: upColor, size: 14),
            value: up,
          ),
          const SizedBox(height: 8),
          _TrafficDataItem(
            icon: Icon(Icons.arrow_downward, color: downColor, size: 14),
            value: down,
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DonutChart(
              data: [
                DonutChartData(value: up.toDouble(), color: upColor),
                DonutChartData(value: down.toDouble(), color: downColor),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _TrafficLegend(upColor: upColor, downColor: downColor),
          ),
        ],
      ),
    );
  }
}

class _TrafficLegend extends StatelessWidget {
  const _TrafficLegend({required this.upColor, required this.downColor});

  final Color upColor;
  final Color downColor;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final labelStyle = context.textTheme.bodySmall;
    return LayoutBuilder(
      builder: (_, container) {
        final uploadLabel = _label(appLocalizations.upload, labelStyle);
        final downloadLabel = _label(appLocalizations.download, labelStyle);
        final maxLabelWidth = max(
          globalState.measure.computeTextSize(uploadLabel).width,
          globalState.measure.computeTextSize(downloadLabel).width,
        );
        if (maxLabelWidth + 24 > container.maxWidth) {
          return Container();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendEntry(color: upColor, label: uploadLabel),
            const SizedBox(height: 4),
            _LegendEntry(color: downColor, label: downloadLabel),
          ],
        );
      },
    );
  }

  Text _label(String text, TextStyle? style) {
    return Text(
      maxLines: 1,
      text,
      overflow: TextOverflow.ellipsis,
      style: style,
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
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 4),
        label,
      ],
    );
  }
}

class _TrafficDataItem extends StatelessWidget {
  const _TrafficDataItem({required this.icon, required this.value});

  final Icon icon;
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
