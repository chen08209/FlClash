import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrafficUsage extends StatelessWidget {
  const TrafficUsage({super.key});

  Widget getTrafficDataItem(
    BuildContext context,
    IconData iconData,
    TrafficValue trafficValue,
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
              Icon(
                iconData,
                size: 18,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                flex: 1,
                child: Text(
                  trafficValue.showValue,
                  style: context.textTheme.labelLarge?.copyWith(fontSize: 18),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          trafficValue.showUnit,
          style: context.textTheme.labelMedium?.toLight(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      info: Info(
        label: appLocalizations.trafficUsage,
        iconData: Icons.data_saver_off,
      ),
      child: Selector<AppState, List<Traffic>>(
        selector: (_, appState) => appState.traffics,
        builder: (_, traffics, __) {
          final trafficTotal = traffics.isNotEmpty
              ? traffics.reduce(
                  (value, element) {
                    return Traffic(
                      up: element.up.value + value.up.value,
                      down: element.down.value + value.down.value,
                    );
                  },
                )
              : Traffic();
          final upTrafficValue = trafficTotal.up;
          final downTrafficValue = trafficTotal.down;
          return Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: getTrafficDataItem(
                    context,
                    Icons.arrow_upward,
                    upTrafficValue,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Flexible(
                  flex: 1,
                  child: getTrafficDataItem(
                    context,
                    Icons.arrow_downward,
                    downTrafficValue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
