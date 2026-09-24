import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntranetIP extends StatelessWidget {
  const IntranetIP({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        infoPadding: DashboardWidgetMetrics.paddingOf(
          context,
        ).copyWith(bottom: 0),
        info: Info(
          label: appLocalizations.intranetIP,
          glyph: AppGlyphs.devices,
        ),
        onPressed: () {},
        child: Container(
          padding: DashboardWidgetMetrics.paddingOf(context).copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height:
                    globalState.measure.bodyMediumHeight *
                        DashboardWidgetMetrics.textScaleOf(context) +
                    2,
                child: Consumer(
                  builder: (_, ref, _) {
                    final localIp = ref.watch(localIpProvider);
                    return FadeThroughBox(
                      child: localIp != null
                          ? TooltipText(
                              text: Text(
                                localIp.isNotEmpty
                                    ? localIp
                                    : appLocalizations.noNetwork,
                                style: context.textTheme.bodyMedium?.toLight
                                    .adjustSize(1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(2),
                              child: const AspectRatio(
                                aspectRatio: 1,
                                child: CommonCircleLoading(),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
