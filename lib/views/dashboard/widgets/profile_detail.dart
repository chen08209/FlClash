import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/profiles/preview.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaml/yaml.dart';

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

void showProfilesSheet(BuildContext context) {
  showSheet<void>(
    context: context,
    builder: (_) => const ProfilesView(picker: true),
  );
}

typedef ProfileStats = ({int groups, int proxies, int rules, int providers});

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

({String md5, ConfigCounts counts})? _countsCache;

// package:yaml holds a document in many times its size.
const _maxCountedConfigBytes = 8 << 20;

ConfigCounts? _cachedCounts() {
  if (globalState.lastConfigCounts case final counts?) {
    return counts;
  }
  final cache = _countsCache;
  final md5 = globalState.lastConfigMd5;
  return cache != null && cache.md5 == md5 ? cache.counts : null;
}

ConfigCounts? _countConfigFile(String path) {
  final file = File(path);
  if (file.lengthSync() > _maxCountedConfigBytes) {
    return null;
  }
  final config = loadYaml(file.readAsStringSync());
  return configCountsOf(config is Map ? config : const {});
}

/// Parsed in an isolate: a large profile takes far longer than a frame.
Future<ConfigCounts?> _loadCounts() async {
  if (_cachedCounts() case final counts?) {
    return counts;
  }
  final md5 = globalState.lastConfigMd5;
  final counts = await compute(_countConfigFile, await appPath.configFilePath);
  if (md5 != null && counts != null) {
    _countsCache = (md5: md5, counts: counts);
  }
  return counts;
}

mixin ConfigCountsWatch<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  ConfigCounts? configCounts = _cachedCounts();
  bool configCountsFailed = false;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    if (configCounts == null) {
      unawaited(_reloadCounts());
    }
  }

  Future<void> _reloadCounts() async {
    final generation = ++_generation;
    ConfigCounts? counts;
    var failed = false;
    try {
      counts = await _loadCounts();
    } catch (error) {
      commonPrint.log('read applied config error: $error');
      failed = true;
    }
    if (!mounted || generation != _generation) {
      return;
    }
    setState(() {
      configCounts = counts ?? configCounts;
      configCountsFailed = failed || counts == null;
    });
  }

  /// Called from build: groups refresh after every applied setup.
  void watchConfigCounts() {
    ref.listen(groupsProvider, (_, _) {
      final cached = _cachedCounts();
      if (cached == null) {
        unawaited(_reloadCounts());
      } else if (cached != configCounts) {
        _generation++;
        setState(() {
          configCounts = cached;
          configCountsFailed = false;
        });
      }
    });
  }
}

class ProfileDetailSheet extends ConsumerStatefulWidget {
  const ProfileDetailSheet({super.key});

  @override
  ConsumerState<ProfileDetailSheet> createState() => _ProfileDetailSheetState();
}

class _ProfileDetailSheetState extends ConsumerState<ProfileDetailSheet>
    with ConfigCountsWatch<ProfileDetailSheet> {
  void _handlePreview(Profile profile) {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    watchConfigCounts();
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
          tooltip: appLocalizations.runtimeConfig,
          onPressed: () => _handlePreview(profile),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.contentTopPadding,
              bottom: 20 + context.bottomInset,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverList.list(
                  children: [
                    _StatsGrid(
                      stats: switch (configCounts) {
                        final counts? => profileStatsOf(counts, providers),
                        null => null,
                      },
                      failed: configCountsFailed,
                    ),
                    if (subscriptionInfo != null && subscriptionInfo.total > 0)
                      generateSection(
                        title: appLocalizations.subscriptionInfo,
                        items: [
                          ListItem(
                            title: SubscriptionInfoView(
                              subscriptionInfo: subscriptionInfo,
                            ),
                          ),
                        ],
                      ),
                    generateSection(
                      title: appLocalizations.profile,
                      items: [
                        _InfoRow(
                          label: appLocalizations.lastUpdated,
                          value: LastUpdateTimeText(
                            lastUpdateDate: profile.lastUpdateDate,
                          ),
                        ),
                        if (profile.type != ProfileType.custom)
                          _InfoRow(
                            label: appLocalizations.extendMode,
                            value: Text(
                              _extendLabel(context, profile.extendType),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (providers.isNotEmpty)
                  ExternalProvidersSliver(providers: providers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _extendLabel(BuildContext context, ExtendType type) {
  return switch (type) {
    ExtendType.standard => context.appLocalizations.standard,
    ExtendType.script => context.appLocalizations.script,
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
      (appLocalizations.proxies, stats?.proxies),
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
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.all(AppCorner.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            value ?? '0',
            maxLines: 1,
            style: AppTextStyle.title2
                .of(context, emphasized: true)
                .copyWith(color: colorScheme.onSurface),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: colorScheme.onSurfaceVariant),
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
        style: AppTextStyle.subheadline
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
        child: value,
      ),
    );
  }
}
