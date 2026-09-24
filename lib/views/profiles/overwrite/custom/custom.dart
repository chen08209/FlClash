import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_proxies.dart';
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
    await globalState.safeRun(() async {
      final clashConfig = await ref.read(clashConfigProvider(profileId).future);
      final proxies = feature.customProxies
          ? await _readConfigProxies(ref, profileId)
          : null;
      await database.setProfileCustomData(
        profileId,
        proxies,
        clashConfig.proxyGroups,
        clashConfig.rules,
      );
    });
  }

  Future<List<CustomProxy>> _readConfigProxies(
    WidgetRef ref,
    int profileId,
  ) async {
    final rawProxies = (await ref
        .read(coreHandlerProvider)
        .getConfig(profileId))['proxies'];
    if (rawProxies != null && rawProxies is! List) {
      throw const FormatException('proxies');
    }
    return [
      for (final item in rawProxies ?? const [])
        if (item is Map) CustomProxy.fromDefinition(item),
    ];
  }

  void _handleToProxiesView(BuildContext context, int profileId) {
    BaseNavigator.push(context, CustomProxiesView(profileId));
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
    ref.listen(customProxiesProvider(profileId), (_, _) {});
    ref.listen(profileCustomRulesProvider(profileId), (_, _) {});
    ref.listen(customOverwriteDateProvider(profileId), (_, _) {});
    final proxyNum =
        ref.watch(customProxiesCountProvider(profileId)).value ?? -1;
    final proxyGroupNum =
        ref.watch(proxyGroupsCountProvider(profileId)).value ?? -1;
    final ruleNum = ref.watch(customRulesCountProvider(profileId)).value ?? -1;
    final issueCounts = ref.watch(
      customOverwriteIssuesProvider(profileId).select(
        (state) => (
          proxies: state.proxies.length,
          proxyGroups: state.proxyGroups.length,
          rules: state.rules.length,
        ),
      ),
    );
    final issueCount =
        issueCounts.proxies + issueCounts.proxyGroups + issueCounts.rules;
    final generalIssues = ref
        .watch(
          customOverwriteIssuesProvider(
            profileId,
          ).select((state) => SelectValue(state.general)),
        )
        .value;
    final issueMessages = [
      if (issueCount > 0) appLocalizations.overwriteIssuesSummary(issueCount),
      for (final issue in generalIssues) issue.getMessage(context),
    ];
    final defaults = ref.watch(
      clashConfigProvider(profileId).select((state) {
        final clashConfig = state.value;
        return (
          hasProxies: clashConfig?.proxies.isNotEmpty ?? false,
          hasGroups: clashConfig?.proxyGroups.isNotEmpty ?? false,
          hasRules: clashConfig?.rules.isNotEmpty ?? false,
        );
      }),
    );
    final hasDefaultProxies = defaults.hasProxies;
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
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: OverwriteErrorBanner(
              message: issueMessages.isEmpty ? null : issueMessages.join('\n'),
            ),
          ),
        ),
        if (feature.customProxies) ...[
          SliverToBoxAdapter(
            child: MoreActionButton(
              label: appLocalizations.proxies,
              onPressed: () {
                _handleToProxiesView(context, profileId);
              },
              trailing: _CountBadge(
                count: proxyNum,
                issueCount: issueCounts.proxies,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
        ],
        SliverToBoxAdapter(
          child: MoreActionButton(
            label: appLocalizations.proxyGroup,
            onPressed: () {
              _handleToProxyGroupsView(context, profileId);
            },
            trailing: _CountBadge(
              count: proxyGroupNum,
              issueCount: issueCounts.proxyGroups,
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
            trailing: _CountBadge(
              count: ruleNum,
              issueCount: issueCounts.rules,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        if ((feature.customProxies && proxyNum == 0 && hasDefaultProxies) ||
            (proxyGroupNum == 0 && hasDefaultGroups) ||
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
  const _CountBadge({required this.count, this.issueCount = 0});

  final int count;
  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final invalid = issueCount > 0;
    final foreground = invalid ? colorScheme.onErrorContainer : null;
    return Card.filled(
      shape: AppShape.md,
      color: invalid ? colorScheme.errorContainer : null,
      child: Container(
        constraints: const BoxConstraints(minWidth: 44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            if (invalid)
              GlyphIcon(AppGlyphs.error, size: 14, color: foreground),
            Text(
              invalid ? '$issueCount / $count' : '$count',
              style: context.textTheme.bodySmall?.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
          ],
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
              child: ElasticButton(
                child: FilledButton.tonal(
                  onPressed: onPressed,
                  child: Text(appLocalizations.quickFill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
