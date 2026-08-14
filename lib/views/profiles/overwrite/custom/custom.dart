import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'groups.dart';
import 'rules.dart';

class CustomContent extends ConsumerWidget {
  const CustomContent({super.key});

  void _handleUseDefault(WidgetRef ref, int profileId) async {
    final res = await globalState.showMessage(
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
    final vm2 = ref.watch(
      clashConfigProvider(profileId).select((state) {
        final clashConfig = state.value;
        return VM2(
          clashConfig?.proxyGroups.isNotEmpty ?? false,
          clashConfig?.rules.isNotEmpty ?? false,
        );
      }),
    );
    final hasDefaultGroups = vm2.a;
    final hasDefaultRules = vm2.b;
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
            trailing: Card.filled(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(minWidth: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    '$proxyGroupNum',
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        SliverToBoxAdapter(
          child: MoreActionButton(
            label: appLocalizations.rule,
            onPressed: () {
              _handleToRulesView(context, profileId);
            },
            trailing: Card.filled(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(minWidth: 44),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  '$ruleNum',
                  style: context.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        if ((proxyGroupNum == 0 && hasDefaultGroups) ||
            (ruleNum == 0 && hasDefaultRules) ||
            kDebugMode)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                margin: const EdgeInsets.all(12),
                child: MaterialBanner(
                  elevation: 0,
                  dividerColor: Colors.transparent,
                  content: Text(appLocalizations.configDataDetected),
                  actions: [
                    CommonMinFilledButtonTheme(
                      child: FilledButton.tonal(
                        onPressed: () {
                          _handleUseDefault(ref, profileId);
                        },
                        child: Text(appLocalizations.quickFill),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
