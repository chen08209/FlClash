import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _statSpacing = 8.0;

Future<void> syncProfile(WidgetRef ref, Profile profile) async {
  await globalState.loadingRun(() async {
    await ref
        .read(profilesActionProvider.notifier)
        .updateProfile(profile, showLoading: true);
  }, tag: LoadingTag.profiles);
}

void showProfileDetailSheet(BuildContext context) {
  showSheet<void>(context: context, builder: (_) => const ProfileDetailSheet());
}

typedef ConfigCounts = ({int groups, int proxies, int rules});

typedef ProfileStats = ({int groups, int proxies, int rules, int providers});

/// Counts what the Core was handed, overwrites included, rather than what the
/// profile file declares.
ConfigCounts configCountsOf(Map<String, dynamic> config) {
  int lengthOf(Object? value) => value is List ? value.length : 0;
  return (
    groups: lengthOf(config['proxy-groups']),
    proxies: lengthOf(config['proxies']),
    rules: lengthOf(config['rules']),
  );
}

ProfileStats profileStatsOf(
  ConfigCounts counts,
  List<ExternalProvider> providers,
) {
  final providedProxies = providers
      .where((provider) => provider.type == 'Proxy')
      .fold(0, (sum, provider) => sum + provider.count);
  return (
    groups: counts.groups,
    proxies: counts.proxies + providedProxies,
    rules: counts.rules,
    providers: providers.length,
  );
}

/// Kept until another config is applied: parsing one is slow on a large profile.
({String md5, ConfigCounts counts})? _countsCache;

ConfigCounts? _cachedCounts() {
  final cache = _countsCache;
  final md5 = globalState.lastConfigMd5;
  return cache != null && cache.md5 == md5 ? cache.counts : null;
}

class ProfileDetailSheet extends ConsumerStatefulWidget {
  const ProfileDetailSheet({super.key});

  @override
  ConsumerState<ProfileDetailSheet> createState() => _ProfileDetailSheetState();
}

class _ProfileDetailSheetState extends ConsumerState<ProfileDetailSheet> {
  ConfigCounts? _counts = _cachedCounts();
  var _failed = false;
  var _loadStarted = false;
  var _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) {
      return;
    }
    _loadStarted = true;
    if (_counts == null) {
      unawaited(_load(afterRoute: true));
    }
  }

  // Decoding a large config mid-transition drops the sheet's frames.
  Future<void> _load({bool afterRoute = false}) async {
    final generation = ++_generation;
    if (afterRoute) {
      await whenRouteSettled(context);
      if (!mounted) {
        return;
      }
    }
    final md5 = globalState.lastConfigMd5;
    ConfigCounts? counts;
    try {
      counts = configCountsOf(
        await ref.read(coreHandlerProvider).getAppliedConfig(),
      );
    } catch (error) {
      commonPrint.log(
        'read applied config error: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
    if (!mounted || generation != _generation) {
      return;
    }
    if (counts != null && md5 != null) {
      _countsCache = (md5: md5, counts: counts);
    }
    setState(() {
      _counts = counts ?? _counts;
      _failed = counts == null;
    });
  }

  void _handlePreview(Profile profile) {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Groups refresh after every applied setup, and after a proxy switch too.
    ref.listen(groupsProvider, (_, _) {
      if (_cachedCounts() == null) {
        unawaited(_load());
      }
    });
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return const SizedBox.shrink();
    }
    final providers = ref.watch(providersProvider);
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final appLocalizations = context.appLocalizations;
    final subscriptionInfo = profile.subscriptionInfo;
    return CommonScaffold(
      title: profile.realLabel,
      iconActions: [
        if (profile.type == ProfileType.url)
          IconButtonData(
            glyph: AppGlyphs.sync,
            tooltip: appLocalizations.sync,
            isLoading: isUpdating,
            onPressed: () => syncProfile(ref, profile),
          ),
        IconButtonData(
          glyph: AppGlyphs.eye,
          tooltip: appLocalizations.preview,
          onPressed: () => _handlePreview(profile),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        children: [
          _StatsGrid(
            stats: switch (_counts) {
              final counts? => profileStatsOf(counts, providers),
              null => null,
            },
            failed: _failed,
          ),
          if (subscriptionInfo != null && subscriptionInfo.total > 0)
            generateSectionV3(
              title: appLocalizations.subscriptionInfo,
              items: [
                ListItem(
                  title: SubscriptionInfoView(
                    subscriptionInfo: subscriptionInfo,
                  ),
                ),
              ],
            ),
          generateSectionV3(
            title: appLocalizations.profile,
            items: [
              _InfoRow(
                label: appLocalizations.lastUpdated,
                value: LastUpdateTimeText(
                  lastUpdateDate: profile.lastUpdateDate,
                ),
              ),
              _InfoRow(
                label: appLocalizations.overrideMode,
                value: Text(_overwriteLabel(context, profile.overwriteType)),
              ),
            ],
          ),
          if (providers.isNotEmpty)
            generateSectionV3(
              title: appLocalizations.providers,
              items: [
                for (final provider in providers)
                  _ProviderRow(provider: provider),
              ],
            ),
        ],
      ),
    );
  }
}

String _overwriteLabel(BuildContext context, OverwriteType type) {
  return switch (type) {
    OverwriteType.standard => context.appLocalizations.standard,
    OverwriteType.script => context.appLocalizations.script,
    OverwriteType.custom => context.appLocalizations.overwriteTypeCustom,
  };
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.failed});

  final ProfileStats? stats;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final stats = this.stats;
    final tiles = [
      (appLocalizations.proxyGroup, stats?.groups),
      (appLocalizations.proxyNode, stats?.proxies),
      (appLocalizations.rules, stats?.rules),
      (appLocalizations.providers, stats?.providers),
    ];
    Widget rowOf(Iterable<(String, int?)> pair) {
      return Row(
        spacing: _statSpacing,
        children: [
          for (final (label, value) in pair)
            Expanded(
              child: _StatTile(
                label: label,
                value: value?.toString() ?? (failed ? '-' : null),
              ),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        spacing: _statSpacing,
        children: [rowOf(tiles.take(2)), rowOf(tiles.skip(2))],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: AppShape.all(AppCorner.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            value ?? '0',
            maxLines: 1,
            style: context.textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(label),
      trailing: DefaultTextStyle.merge(
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        child: value,
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.provider});

  final ExternalProvider provider;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final count = switch (provider.type) {
      'Proxy' => appLocalizations.proxiesCount(provider.count),
      _ => appLocalizations.rulesCount(provider.count),
    };
    return ListItem(
      title: EmojiText(
        provider.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(count),
      trailing: Text(
        provider.updateAt.getLastUpdateTimeDesc(context),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
