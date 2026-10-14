import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/ntp.dart';
import 'package:fl_clash/views/config/sniffer.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dialers.dart';
import 'groups.dart';
import 'providers.dart';
import 'rules.dart';

void showCustomProfileSheet(BuildContext context, int profileId) {
  showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(
      builder: (_) => CustomProfileView(profileId: profileId),
    ),
  );
}

void _push(BuildContext context, Widget view) {
  if (isSheetPage(context)) {
    Navigator.of(context).push(PagedSheetRoute<void>(builder: (_) => view));
    return;
  }
  BaseNavigator.push(context, view);
}

class CustomProfileView extends ConsumerStatefulWidget {
  final int profileId;

  /// A new profile is dropped again when it is left as it was created.
  final bool isNew;

  const CustomProfileView({
    super.key,
    required this.profileId,
    this.isNew = false,
  });

  @override
  ConsumerState<CustomProfileView> createState() => _CustomProfileViewState();
}

class _CustomProfileViewState extends ConsumerState<CustomProfileView>
    with RouteSettledMixin<CustomProfileView> {
  late SetupAction _setupAction;
  late ProfilesAction _profilesAction;
  late final Profile? _initialProfile;
  late final _overview = _Overview(showsTun: system.isDesktop);
  late final _groups = CustomProxyGroupsSection(widget.profileId);
  var _discarded = false;
  var _discardOnDispose = false;
  var _loaded = false;
  List<Object?>? _loadedInputs;
  var _edited = false;
  var _importing = false;

  @override
  void initState() {
    super.initState();
    _setupAction = ref.read(setupActionProvider.notifier);
    _profilesAction = ref.read(profilesActionProvider.notifier);
    _initialProfile = ref.read(profileProvider(widget.profileId));
  }

  bool get _isUntouched {
    if (!routeSettled) {
      return true;
    }
    final profileId = widget.profileId;
    final profile = ref.read(profileProvider(profileId));
    return profile != null &&
        profile.label == _initialProfile?.label &&
        profile.overrides == const ProfileOverrides() &&
        ref.read(proxyGroupsProvider(profileId)).value?.isEmpty == true &&
        ref.read(profileRulesProvider(profileId)).value?.isEmpty == true;
  }

  List<Object?> get _inputs {
    final profileId = widget.profileId;
    return [
      ref.read(profileProvider(profileId)),
      ref.read(customProfileDataProvider(profileId)),
      ref.read(profileRulesProvider(profileId)).value,
    ];
  }

  @override
  void didSettleRoute() => setState(() {});

  bool get _isEmpty {
    final profileId = widget.profileId;
    return ref.read(profileProvider(profileId))?.overrides ==
            const ProfileOverrides() &&
        ref.read(proxyGroupsProvider(profileId)).value?.isEmpty == true &&
        ref.read(profileRulesProvider(profileId)).value?.isEmpty == true &&
        ref.read(proxyDialersProvider(profileId)).value?.isEmpty == true;
  }

  Future<void> _handleImportFromUrl() async {
    final url = await dialogs.showUrlInput(
      title: context.appLocalizations.importUrl,
    );
    if (url == null || !mounted) {
      return;
    }
    await _import(() async {
      final response = await request.getFileResponseForUrl(url);
      return decompressUnlabeled(response.data ?? Uint8List(0));
    });
  }

  Future<void> _handleImportFromFile() async {
    final file = await globalState.safeRun(picker.pickerFile);
    if (file == null || !mounted) {
      return;
    }
    await _import(file.readBytes);
  }

  Future<void> _import(Future<Uint8List> Function() readBytes) async {
    final appLocalizations = context.appLocalizations;
    setState(() {
      _importing = true;
    });
    try {
      final config = await globalState.safeRun(
        () async => _profilesAction.readCustomImport(
          widget.profileId,
          await readBytes(),
        ),
        silence: false,
        title: appLocalizations.import,
      );
      if (config == null || !mounted) {
        return;
      }
      if (!_isEmpty) {
        final res = await dialogs.showMessage(
          message: TextSpan(text: appLocalizations.importConfigReplaceTip),
        );
        if (res != true || !mounted) {
          return;
        }
      }
      await _profilesAction.importCustomProfile(widget.profileId, config);
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
        });
      }
    }
  }

  /// Done as the pop starts, so the page uncovered on the way out no longer
  /// lists the profile.
  void _discardIfUntouched() {
    if (_discarded || !widget.isNew || !_isUntouched) {
      return;
    }
    _discarded = true;
    unawaited(_profilesAction.deleteProfile(widget.profileId));
  }

  Future<bool> _nameBeforeLeaving(BuildContext context) async {
    final profile = ref.read(profileProvider(widget.profileId));
    if (profile != null &&
        profile.label == _initialProfile?.label &&
        !_isUntouched) {
      await renameProfile(context, ref, profile, selectAll: true);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = widget.profileId;
    final label = ref.watch(
      profileProvider(
        profileId,
      ).select((state) => state?.realLabel ?? _initialProfile?.realLabel ?? ''),
    );
    // Reads nothing until the route settles, since loading mid-transition
    // drops frames.
    _loaded =
        _loaded ||
        (routeSettled &&
            ref.watch(
              customProfileDataProvider(
                profileId,
              ).select((state) => state != null),
            ) &&
            !ref.watch(
              profileRulesProvider(
                profileId,
              ).select((state) => state.isLoading),
            ));
    if (_loaded) {
      _loadedInputs ??= _inputs;
    }
    return CommonPopScope(
      onPop: widget.isNew ? _nameBeforeLeaving : null,
      onPopSuccess: _discardIfUntouched,
      child: ProfileIdProvider(
        profileId: profileId,
        child: CommonScaffold(
          title: label,
          isLoading: _importing,
          actions: [
            CommonPopupBox(
              targetBuilder: (open) => FilledButton(
                onPressed: _loaded && !_importing
                    ? () =>
                          open(offset: Offset(0, context.isMobileView ? 0 : 20))
                    : null,
                child: Text(appLocalizations.import),
              ),
              popupBuilder: (_) => CommonPopupMenu(
                items: [
                  CommonPopupMenuItem(
                    glyph: AppGlyphs.cloudDownload,
                    label: appLocalizations.importUrl,
                    onPressed: _handleImportFromUrl,
                  ),
                  CommonPopupMenuItem(
                    glyph: AppGlyphs.importFile,
                    label: appLocalizations.importFile,
                    onPressed: _handleImportFromFile,
                  ),
                ],
              ),
            ),
          ],
          body: NullStatusSwitcher(
            isEmpty: !_loaded,
            nullStatus: const NullStatus(
              illustration: NullStatusIllustration.profile,
            ),
            child: ScrollConfiguration(
              behavior: const ShowBarScrollBehavior(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: context.contentTopPadding),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).copyWith(bottom: 24),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(child: _overview),
                        _groups,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    _discardOnDispose = !_discarded && widget.isNew && _isUntouched;
    _edited =
        _loadedInputs != null &&
        !const DeepCollectionEquality().equals(_loadedInputs, _inputs);
    super.deactivate();
  }

  @override
  void dispose() {
    if (_discardOnDispose) {
      final profileId = widget.profileId;
      // Providers cannot change while the tree is unmounting.
      unawaited(Future(() => _profilesAction.deleteProfile(profileId)));
    } else if (!_discarded && _edited) {
      final profileId = widget.profileId;
      scheduleMicrotask(() {
        _profilesAction.touchProfile(profileId);
        _setupAction.autoApplyProfile();
      });
    }
    super.dispose();
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.showsTun});

  final bool showsTun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final sections = [
      (AppGlyphs.rules, appLocalizations.rule, CustomRulesView(profileId)),
      (
        AppGlyphs.resources,
        appLocalizations.providers,
        CustomProvidersView(profileId),
      ),
      (AppGlyphs.dns, 'DNS', DnsView.profile(profileId)),
      (
        AppGlyphs.sliders,
        appLocalizations.more,
        _MoreSectionsView(profileId, showsTun: showsTun),
      ),
    ];
    Widget tile(int index, Widget value, {bool invalid = false}) {
      final (glyph, label, view) = sections[index];
      return _OverviewTile(
        glyph: glyph,
        label: label,
        invalid: invalid,
        onPressed: () => _push(context, view),
        value: value,
      );
    }

    ref.listen(customProfileDataProvider(profileId), (_, _) {});
    final ruleNum = ref.watch(
      profileRulesProvider(profileId).select((state) => state.value?.length),
    );
    final issueCounts = ref.watch(
      customProfileIssuesProvider(profileId).select(
        (state) => (
          proxyGroups: state.proxyGroups.length,
          rules: state.rules.length,
          dialers: state.dialers.length,
          dns: state.dns.length,
          ntp: state.ntp.length,
        ),
      ),
    );
    final issueCount =
        issueCounts.proxyGroups +
        issueCounts.rules +
        issueCounts.dialers +
        issueCounts.dns +
        issueCounts.ntp;
    final dialerCount = ref.watch(_dialerCount(profileId));
    final providers = referencedProviders(ref, profileId);
    final missingProviders = ref.watch(
      customProfileDataProvider(profileId).select(
        (state) => state != null
            ? [
                for (final name in providers.proxy)
                  if (!state.proxyProviders.contains(name)) name,
                for (final name in providers.rule)
                  if (!state.ruleProviders.contains(name)) name,
              ].length
            : 0,
      ),
    );
    final status = ref.watch(_sectionStatus(profileId));
    final moreInEffect = [
      dialerCount > 0,
      status.ntp,
      status.sniffer,
      showsTun && status.tunSettings > 0,
    ].where((inEffect) => inEffect).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ErrorBanner(
          message: issueCount > 0
              ? appLocalizations.customIssuesSummary(issueCount)
              : null,
        ),
        _TileGrid(
          children: [
            tile(
              0,
              _CountText(count: ruleNum, issueCount: issueCounts.rules),
              invalid: issueCounts.rules > 0,
            ),
            tile(
              1,
              _CountText(
                count: providers.proxy.length + providers.rule.length,
                issueCount: missingProviders,
              ),
              invalid: missingProviders > 0,
            ),
            tile(
              2,
              _StatusText(
                _enabledText(appLocalizations, status.dns),
                active: status.dns,
              ),
              invalid: issueCounts.dns > 0,
            ),
            tile(
              3,
              _StatusText(
                moreInEffect > 0
                    ? appLocalizations.sectionsInEffect(moreInEffect)
                    : appLocalizations.defaultText,
                active: moreInEffect > 0,
              ),
              invalid: issueCounts.dialers + issueCounts.ntp > 0,
            ),
          ],
        ),
      ],
    );
  }
}

typedef _SectionStatus = ({bool dns, bool ntp, bool sniffer, int tunSettings});

ProviderListenable<_SectionStatus> _sectionStatus(int profileId) =>
    profileProvider(profileId).select((profile) {
      final overrides = profile?.overrides ?? const ProfileOverrides();
      return (
        dns: overrides.customDnsEnabled,
        ntp: overrides.customNtpEnabled,
        sniffer: overrides.customSnifferEnabled,
        tunSettings: overrides.tunOverrideKeys.length,
      );
    });

ProviderListenable<int> _dialerCount(int profileId) =>
    customProfileDataProvider(profileId).select(
      (state) => state == null
          ? 0
          : state.dialers.keys.where(state.namedProxies.contains).length,
    );

String _enabledText(AppLocalizations l, bool enabled) =>
    enabled ? l.enabled : l.disabled;

class _MoreSectionsView extends ConsumerWidget {
  const _MoreSectionsView(this.profileId, {required this.showsTun});

  final int profileId;
  final bool showsTun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final status = ref.watch(_sectionStatus(profileId));
    final dialerCount = ref.watch(_dialerCount(profileId));
    final (:hasDialerIssues, :hasNtpIssues) = ref.watch(
      customProfileIssuesProvider(profileId).select(
        (state) => (
          hasDialerIssues: state.dialers.isNotEmpty,
          hasNtpIssues: state.ntp.isNotEmpty,
        ),
      ),
    );
    Widget section(Glyph glyph, String title, Widget state, Widget view) {
      return ListItem(
        leading: GlyphIcon(glyph),
        title: Text(title),
        subtitle: state,
        onTap: () => _push(context, view),
      );
    }

    return CommonScaffold(
      title: appLocalizations.more,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 16),
        children: [
          generateSectionV3(
            items: [
              section(
                AppGlyphs.link,
                appLocalizations.dialerProxy,
                Text(
                  dialerCount > 0
                      ? appLocalizations.proxiesCount(
                          dialerCount,
                          dialerCount.compact,
                        )
                      : appLocalizations.none,
                  style: hasDialerIssues
                      ? TextStyle(color: context.colorScheme.error)
                      : null,
                ),
                CustomProxyDialersView(profileId),
              ),
              section(
                AppGlyphs.clock,
                'NTP',
                Text(
                  _enabledText(appLocalizations, status.ntp),
                  style: hasNtpIssues
                      ? TextStyle(color: context.colorScheme.error)
                      : null,
                ),
                NtpView(profileId),
              ),
              section(
                AppGlyphs.eye,
                appLocalizations.sniffer,
                Text(_enabledText(appLocalizations, status.sniffer)),
                SnifferView(profileId),
              ),
              if (showsTun)
                section(
                  AppGlyphs.vpn,
                  appLocalizations.tun,
                  Text(
                    status.tunSettings > 0
                        ? appLocalizations.settingsCount(status.tunSettings)
                        : appLocalizations.defaultText,
                  ),
                  TunView(profileId),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Balances its rows, so four tiles that fit three abreast make two rows of
/// two rather than three and one.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  static const _spacing = 8.0;
  static const _minTileWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + _spacing) ~/ (_minTileWidth + _spacing))
                .clamp(1, children.length);
        final rows = (children.length / fit).ceil();
        final columns = (children.length / rows).ceil();
        return Column(
          spacing: _spacing,
          children: [
            for (var start = 0; start < children.length; start += columns)
              Row(
                spacing: _spacing,
                children: [
                  for (var index = start; index < start + columns; index++)
                    Expanded(
                      child: index < children.length
                          ? children[index]
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.glyph,
    required this.label,
    required this.onPressed,
    required this.value,
    this.invalid = false,
  });

  final Glyph glyph;
  final String label;
  final VoidCallback onPressed;
  final Widget value;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return CommonCard(
      type: context.isInBottomSheet
          ? CommonCardType.filled
          : CommonCardType.plain,
      radius: AppCorner.lg,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: invalid
                    ? colorScheme.errorContainer
                    : colorScheme.secondaryContainer,
                shape: AppShape.circle,
              ),
              child: GlyphIcon(
                glyph,
                size: 20,
                color: invalid
                    ? colorScheme.onErrorContainer
                    : colorScheme.onSecondaryContainer,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  DefaultTextStyle.merge(
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountText extends StatelessWidget {
  const _CountText({required this.count, this.issueCount = 0});

  final int? count;
  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final count = this.count?.toString() ?? '';
    if (issueCount == 0) {
      return Text(count);
    }
    return Text(
      '$issueCount / $count',
      style: TextStyle(color: context.colorScheme.error),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText(this.text, {required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: active ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
