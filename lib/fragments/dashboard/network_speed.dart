import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkSpeed extends StatefulWidget {
  const NetworkSpeed({super.key});

  @override
  State<NetworkSpeed> createState() => _NetworkSpeedState();
}

class _NetworkSpeedState extends State<NetworkSpeed> {
  List<Point> initPoints = const [Point(0, 0), Point(1, 0)];

  List<Point> _getPoints(List<Traffic> traffics) {
    List<Point> trafficPoints = traffics
        .toList()
        .asMap()
        .map(
          (index, e) => MapEntry(
            index,
            Point(
              (index + initPoints.length).toDouble(),
              e.speed.toDouble(),
            ),
          ),
        )
        .values
        .toList();

    return [...initPoints, ...trafficPoints];
  }

  Traffic _getLastTraffic(List<Traffic> traffics) {
    if (traffics.isEmpty) return Traffic();
    return traffics.last;
  }

  Widget _getLabel({
    required String label,
    required IconData iconData,
    required TrafficValue value,
  }) {
    final showValue = value.showValue;
    final showUnit = "${value.showUnit}/s";
    final titleLargeSoftBold =
        Theme.of(context).textTheme.titleLarge?.toSoftBold;
    final bodyMedium = Theme.of(context).textTheme.bodySmall?.toLight;
    final valueText = Text(
      showValue,
      style: titleLargeSoftBold,
      maxLines: 1,
    );
    final unitText = Text(
      showUnit,
      style: bodyMedium,
      maxLines: 1,
    );
    final size = globalState.measure.computeTextSize(valueText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Icon(iconData),
            ),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.toSoftBold,
              ),
            ),
          ],
        ),
        SizedBox(
            width: size.width,
            height: size.height,
            child: OverflowBox(
              maxWidth: 156,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: valueText,
                  ),
                  const Flexible(
                    flex: 0,
                    child: SizedBox(
                      width: 4,
                    ),
                  ),
                  Flexible(
                    child: unitText,
                  ),
                ],
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onPressed: () {},
      info: Info(
        label: appLocalizations.networkSpeed,
        iconData: Icons.speed_sharp,
      ),
      child: Selector<AppState, List<Traffic>>(
        selector: (_, appState) => appState.traffics,
        builder: (_, traffics, __) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 0,
                  child: LineChart(
                    color: Theme.of(context).colorScheme.primary,
                    points: _getPoints(traffics),
                    height: 100,
                  ),
                ),
                const Flexible(child: SizedBox(height: 16)),
                Flexible(
                  flex: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: _getLabel(
                          iconData: Icons.upload,
                          label: appLocalizations.upload,
                          value: _getLastTraffic(traffics).up,
                        ),
                      ),
                      Expanded(
                        child: _getLabel(
                          iconData: Icons.download,
                          label: appLocalizations.download,
                          value: _getLastTraffic(traffics).down,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
