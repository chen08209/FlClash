import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

class TrackerAppWell extends StatelessWidget {
  final TrackerInfo trackerInfo;
  final double size;
  final bool showsState;

  /// A letter tile's share of [size]; the host's `appIconBodies` when null.
  final double? iconBody;

  const TrackerAppWell({
    super.key,
    required this.trackerInfo,
    required this.size,
    this.showsState = true,
    this.iconBody,
  });

  double get _body => (size * (iconBody ?? hostAppIconBody)).roundToDouble();

  Widget _buildWell(BuildContext context, Widget? icon) {
    if (icon != null) {
      return SizedBox.square(dimension: size, child: icon);
    }
    final process = trackerInfo.metadata.process;
    final initial = (process.isNotEmpty ? process : trackerInfo.title)
        .characters
        .firstOrNull
        ?.toUpperCase();
    final body = _body;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: InsetWell(
          size: body,
          label: initial ?? '',
          style:
              (body < 24
                      ? AppTextStyle.caption2
                      : body < 36
                      ? AppTextStyle.subheadline
                      : AppTextStyle.body)
                  .of(context, emphasized: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final process = trackerInfo.metadata.process;
    final well = process.isEmpty
        ? _buildWell(context, null)
        : OwnPackageIcon(
            packageName: appIconIdOf(trackerInfo.metadata),
            size: size,
            builder: _buildWell,
          );
    if (!showsState || !trackerInfo.isActive) {
      return well;
    }
    final colorScheme = context.colorScheme;
    final small = size < 24;
    final dot = small ? 6.0 : 10.0;
    final inset = (size - _body) / 2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        well,
        PositionedDirectional(
          end: inset - (small ? 1 : 2),
          bottom: inset - (small ? 1 : 2),
          child: Semantics(
            label: context.appLocalizations.connectionsActive,
            child: Container(
              width: dot,
              height: dot,
              decoration: ShapeDecoration(
                color: colorScheme.success,
                shape: CircleBorder(
                  side: BorderSide(
                    color: context.raisedSurfaceLevel.colorOf(colorScheme),
                    width: small ? 1 : 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
