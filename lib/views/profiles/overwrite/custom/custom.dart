import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'groups.dart';
import 'rules.dart';

class CustomContent extends ConsumerWidget {
  const CustomContent({super.key});

  void _handleUseDefault(WidgetRef ref, int profileId) async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: currentAppLocalizations.confirmOverwriteTip),
    );
    if (res != true) {
      return;
    }
    final clashConfig = await ref.read(clashConfigProvider(profileId).future);
    await database.setProfileCustomData(
      profileId,
      clashConfig.proxyGroups,
      clashConfig.rules,
    );
  }

  void _handleToProxyGroupsView(BuildContext context, int profileId) {
    BaseNavigator.push(context, CustomProxyGroupsView(profileId));
  }

  void _handleToRulesView(BuildContext context, int profileId) {
    BaseNavigator.push(context, CustomRulesView(profileId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    ref.listen(proxyGroupsProvider(profileId), (_, _) {});
    ref.listen(profileCustomRulesProvider(profileId), (_, _) {});
    ref.listen(customOverwriteDateProvider(profileId), (_, _) {});
    final proxyGroupNum =
        ref.watch(proxyGroupsCountProvider(profileId)).value ?? -1;
    final ruleNum = ref.watch(customRulesCountProvider(profileId)).value ?? -1;
    final defaults = ref.watch(
      clashConfigProvider(profileId).select((state) {
        final clashConfig = state.value;
        return (
          hasGroups: clashConfig?.proxyGroups.isNotEmpty ?? false,
          hasRules: clashConfig?.rules.isNotEmpty ?? false,
        );
      }),
    );
    final hasDefaultGroups = defaults.hasGroups;
    final hasDefaultRules = defaults.hasRules;
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Column(
            children: [InfoHeader(info: Info(label: appLocalizations.custom))],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: MoreActionButton(
            label: appLocalizations.proxyGroup,
            onPressed: () {
              _handleToProxyGroupsView(context, profileId);
            },
            trailing: _CountBadge(count: proxyGroupNum),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        SliverToBoxAdapter(
          child: MoreActionButton(
            label: appLocalizations.rule,
            onPressed: () {
              _handleToRulesView(context, profileId);
            },
            trailing: _CountBadge(count: ruleNum),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        if ((proxyGroupNum == 0 && hasDefaultGroups) ||
            (ruleNum == 0 && hasDefaultRules) ||
            kDebugMode)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _QuickFillBanner(
              onPressed: () {
                _handleUseDefault(ref, profileId);
              },
            ),
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      shape: AppShape.md,
      child: Container(
        constraints: const BoxConstraints(minWidth: 44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          '$count',
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _QuickFillBanner extends StatelessWidget {
  const _QuickFillBanner({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(shape: AppShape.md),
        margin: const EdgeInsets.all(12),
        child: MaterialBanner(
          elevation: 0,
          dividerColor: Colors.transparent,
          content: Text(appLocalizations.configDataDetected),
          actions: [
            CommonMinFilledButtonTheme(
              child: FilledButton.tonal(
                onPressed: onPressed,
                child: Text(appLocalizations.quickFill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
