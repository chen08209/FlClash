import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/ntp.dart';
import 'package:fl_clash/views/config/sniffer.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/views/profiles/preview.dart';
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

Widget _sectionRow(
  BuildContext context,
  Glyph glyph,
  String title,
  Widget state,
  Widget view,
) {
  return ListItem(
    leading: GlyphIcon(glyph),
    title: Text(title),
    subtitle: state,
    trailing: const GlyphIcon(AppGlyphs.chevronForward),
    onTap: () => _push(context, view),
  );
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

class _CustomProfileViewState extends ConsumerState<CustomProfileView> {
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
    if (!_loaded) {
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
          destructive: true,
          confirmText: appLocalizations.replace,
        );
        if (res != true || !mounted) {
          return;
        }
      }
      await _profilesAction.importCustomProfile(widget.profileId, config);
      final dropped = [
        if (config.droppedSubRules > 0)
          appLocalizations.customImportDroppedSubRules(
            config.droppedSubRules,
            config.droppedSubRules.compact,
          ),
      ];
      if (dropped.isNotEmpty && mounted) {
        unawaited(
          dialogs.showMessage(
            title: appLocalizations.import,
            message: TextSpan(text: dropped.join('\n\n')),
            cancelable: false,
          ),
        );
      }
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

  void _handleRename() {
    final profile = ref.read(profileProvider(widget.profileId));
    if (profile != null) {
      unawaited(renameProfile(context, ref, profile));
    }
  }

  void _handlePreview() {
    final profile = ref.read(profileProvider(widget.profileId));
    if (profile != null) {
      _push(context, PreviewProfileView(profile: profile));
    }
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
    _loaded =
        _loaded ||
        (ref.watch(
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
          titleMenuItems: [
            CommonPopupMenuItem(
              glyph: AppGlyphs.textShort,
              label: appLocalizations.rename,
              onPressed: _handleRename,
            ),
            CommonPopupMenuItem(
              glyph: AppGlyphs.eye,
              label: appLocalizations.runtimeConfig,
              onPressed: _handlePreview,
            ),
          ],
          isLoading: _importing,
          actions: [
            CommonPopupBox(
              targetBuilder: (open) => FilledButton(
                onPressed: _loaded && !_importing ? open : null,
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
            isLoading: !_loaded,
            loadingStatus: const NullStatus(
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
    Widget row(int index, Widget state) {
      final (glyph, title, view) = sections[index];
      return _sectionRow(context, glyph, title, state, view);
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
        generateSection(
          items: [
            row(0, _CountText(count: ruleNum, issueCount: issueCounts.rules)),
            row(
              1,
              _CountText(
                count: providers.proxy.length + providers.rule.length,
                issueCount: missingProviders,
              ),
            ),
            row(
              2,
              _StatusText(
                _enabledText(appLocalizations, status.dns),
                active: status.dns,
                invalid: issueCounts.dns > 0,
              ),
            ),
            row(
              3,
              _StatusText(
                moreInEffect > 0
                    ? appLocalizations.sectionsInEffect(moreInEffect)
                    : appLocalizations.defaultText,
                active: moreInEffect > 0,
                invalid: issueCounts.dialers + issueCounts.ntp > 0,
              ),
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
    return CommonScaffold(
      title: appLocalizations.more,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 16),
        children: [
          generateSection(
            items: [
              _sectionRow(
                context,
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
              _sectionRow(
                context,
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
              _sectionRow(
                context,
                AppGlyphs.eye,
                appLocalizations.sniffer,
                Text(_enabledText(appLocalizations, status.sniffer)),
                SnifferView(profileId),
              ),
              if (showsTun)
                _sectionRow(
                  context,
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
  const _StatusText(this.text, {required this.active, this.invalid = false});

  final String text;
  final bool active;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: invalid
            ? colorScheme.error
            : active
            ? colorScheme.tertiary
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
