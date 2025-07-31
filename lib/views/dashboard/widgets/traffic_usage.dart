import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrafficUsage extends StatelessWidget {
  const TrafficUsage({super.key});

  Widget _buildTrafficDataItem(
    BuildContext context,
    Icon icon,
    num trafficValue,
  ) {
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
                  trafficValue.traffic.value,
                  style: context.textTheme.bodySmall,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          trafficValue.traffic.unit,
          style: context.textTheme.bodySmall?.toLighter,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = globalState.theme.darken3PrimaryContainer;
    final secondaryColor = globalState.theme.darken2SecondaryContainer;
    return SizedBox(
      height: getWidgetHeight(2),
      child: CommonCard(
        info: Info(
          label: appLocalizations.trafficUsage,
          iconData: Icons.data_saver_off,
        ),
        onPressed: () {},
        child: Consumer(
          builder: (_, ref, _) {
            final totalTraffic = ref.watch(totalTrafficProvider);
            final upTotalTrafficValue = totalTraffic.up;
            final downTotalTrafficValue = totalTraffic.down;
            return Padding(
              padding: baseInfoEdgeInsets.copyWith(top: 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: DonutChart(
                              data: [
                                DonutChartData(
                                  value: upTotalTrafficValue.toDouble(),
                                  color: primaryColor,
                                ),
                                DonutChartData(
                                  value: downTotalTrafficValue.toDouble(),
                                  color: secondaryColor,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: LayoutBuilder(
                              builder: (_, container) {
                                final uploadText = Text(
                                  maxLines: 1,
                                  appLocalizations.upload,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall,
                                );
                                final downloadText = Text(
                                  maxLines: 1,
                                  appLocalizations.download,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall,
                                );
                                final uploadTextSize = globalState.measure
                                    .computeTextSize(uploadText);
                                final downloadTextSize = globalState.measure
                                    .computeTextSize(downloadText);
                                final maxTextWidth = max(
                                  uploadTextSize.width,
                                  downloadTextSize.width,
                                );
                                if (maxTextWidth + 24 > container.maxWidth) {
                                  return Container();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          maxLines: 1,
                                          appLocalizations.upload,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: secondaryColor,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          maxLines: 1,
                                          appLocalizations.download,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTrafficDataItem(
                    context,
                    Icon(Icons.arrow_upward, color: primaryColor, size: 14),
                    upTotalTrafficValue,
                  ),
                  const SizedBox(height: 8),
                  _buildTrafficDataItem(
                    context,
                    Icon(Icons.arrow_downward, color: secondaryColor, size: 14),
                    downTotalTrafficValue,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
