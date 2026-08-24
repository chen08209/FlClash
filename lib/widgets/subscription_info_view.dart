import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';

class SubscriptionInfoView extends StatelessWidget {
  final SubscriptionInfo? subscriptionInfo;

  const SubscriptionInfoView({super.key, this.subscriptionInfo});

  @override
  Widget build(BuildContext context) {
    final info = subscriptionInfo;
    if (info == null || info.total == 0) {
      return const SizedBox.shrink();
    }
    final use = info.upload + info.download;
    final total = info.total;
    final progress = (use / total).clamp(0.0, 1.0).toDouble();

    final useShow = use.traffic.show;
    final totalShow = total.traffic.show;
    final expireShow = info.expire != 0
        ? DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).show
        : context.appLocalizations.infiniteTime;
    final baseStyle = context.textTheme.bodyMedium;
    final valueStyle = baseStyle?.toSoftBold.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final metaStyle = baseStyle?.toLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$useShow / $totalShow',
                style: valueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(expireShow, style: metaStyle, maxLines: 1),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          minHeight: 4,
          value: progress,
          backgroundColor: context.colorScheme.primary.opacity15,
        ),
      ],
    );
  }
}
