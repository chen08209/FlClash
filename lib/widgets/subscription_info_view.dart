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
    
    // 检查是否过期
    final now = DateTime.now();
    final isExpired = subscriptionInfo?.expire != null &&
        subscriptionInfo!.expire != 0 &&
        DateTime.fromMillisecondsSinceEpoch(subscriptionInfo!.expire * 1000, isUtc: true)
            .add(const Duration(hours: 8)) // 转换为东8区
            .isBefore(now);
    
    final expireShow = subscriptionInfo?.expire != null &&
            subscriptionInfo!.expire != 0
        ? DateTime.fromMillisecondsSinceEpoch(subscriptionInfo!.expire * 1000, isUtc: true)
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
        Row(
          children: [
            Expanded(
              child: Text(
                "$useShow / $totalShow · $expireShow",
                style: context.textTheme.labelMedium?.toLight,
              ),
            ),
            if (isExpired) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/subscription_store');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '续费',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    );
  }
}
