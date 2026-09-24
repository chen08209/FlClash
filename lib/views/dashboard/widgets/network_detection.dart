import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/probe_start_hold.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkDetection extends ConsumerStatefulWidget {
  const NetworkDetection({super.key});

  @override
  ConsumerState<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends ConsumerState<NetworkDetection>
    with ProbeStartHold<NetworkDetection> {
  late final OutboundIpProbe _probe;

  @override
  void initState() {
    super.initState();
    _probe = ref.read(outboundIpProbeProvider.notifier)..watch(routedOutbound);
  }

  @override
  void dispose() {
    _probe.unwatch(routedOutbound);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final entry = ref.watch(
      outboundIpProbeProvider.select((state) => state.entryOf(routedOutbound)),
    );
    final ipInfo = entry.value;
    final failed = shownPhase(entry) == ProbePhase.failed;
    final emojiTextStyle = context.textTheme.titleMedium?.toLight.copyWith(
      fontFamily: FontFamily.twEmoji.value,
    );
    final titleTextStyle = context.colorScheme.onSurfaceVariant;
    final descTextStyle = context.textTheme.titleSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final textScale = DashboardWidgetMetrics.textScaleOf(context);
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        onPressed: failed ? () => _probe.retry(routedOutbound) : () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: globalState.measure.titleMediumHeight * textScale + 16,
              padding: DashboardWidgetMetrics.paddingOf(
                context,
              ).copyWith(bottom: 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ipInfo != null
                      ? Text(
                          ipInfo.countryCode.countryFlagEmoji,
                          style: emojiTextStyle,
                        )
                      : GlyphIcon(
                          AppGlyphs.networkCheck,
                          color: titleTextStyle,
                        ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: TooltipText(
                      text: Text(
                        appLocalizations.networkDetection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: descTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  AspectRatio(
                    aspectRatio: 1,
                    child: IconButton(
                      tooltip: appLocalizations.tip,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        dialogs.showMessage(
                          title: appLocalizations.tip,
                          message: TextSpan(
                            text: appLocalizations.detectionTip,
                          ),
                          cancelable: false,
                        );
                      },
                      icon: GlyphIcon(
                        size: 16.ap,
                        AppGlyphs.info,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: DashboardWidgetMetrics.paddingOf(
                context,
              ).copyWith(top: 0),
              child: SizedBox(
                height: globalState.measure.bodyMediumHeight * textScale + 2,
                child: FadeThroughBox(
                  child: ipInfo != null
                      ? IpQualityText(
                          ip: ipInfo.ip,
                          openDetails: true,
                          style: context.textTheme.bodyMedium?.adjustSize(1),
                        )
                      : failed
                      ? Text(
                          'Timeout',
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: context.colorScheme.error)
                              .adjustSize(1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(
                          padding: const EdgeInsets.all(2),
                          child: const AspectRatio(
                            aspectRatio: 1,
                            child: CommonCircleLoading(),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
