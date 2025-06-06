import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';

class SubscriptionInfoView extends StatelessWidget {
  final SubscriptionInfo? subscriptionInfo;

  const SubscriptionInfoView({
    super.key,
    this.subscriptionInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptionInfo == null) {
      return Container();
    }
    if (subscriptionInfo?.total == 0) {
      return Container();
    }
    final use = subscriptionInfo!.upload + subscriptionInfo!.download;
    final total = subscriptionInfo!.total;
    final progress = use / total;

    final useShow = TrafficValue(value: use).show;
    final totalShow = TrafficValue(value: total).show;
    final expireShow = subscriptionInfo?.expire != null &&
            subscriptionInfo!.expire != 0
        ? DateTime.fromMillisecondsSinceEpoch(subscriptionInfo!.expire * 1000)
            .show
        : appLocalizations.infiniteTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          minHeight: 6,
          value: progress,
          backgroundColor: context.colorScheme.primary.opacity15,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '$useShow / $totalShow · $expireShow',
          style: context.textTheme.labelMedium?.toLight,
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    );
  }
}
