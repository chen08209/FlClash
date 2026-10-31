import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_trust.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/mitm_modules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void _updateMitm(WidgetRef ref, Mitm Function(Mitm) update) {
  ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => state.copyWith(mitm: update(state.mitm)));
}

ConfigWriter<T> _mitmWriter<T>(Mitm Function(Mitm, T) update) {
  return (ref, value) => _updateMitm(ref, (state) => update(state, value));
}

Future<bool> _generateCertificate(MitmCa ca, String title) async {
  final res = await globalState.loadingRun<bool>(
    () async {
      await ca.generate();
      return true;
    },
    tag: LoadingTag.mitm,
    title: title,
  );
  return res == true;
}

class MitmView extends ConsumerStatefulWidget {
  const MitmView({super.key, required this.isAndroid});

  final bool isAndroid;

  @override
  ConsumerState<MitmView> createState() => _MitmViewState();
}

class _MitmViewState extends ConsumerState<MitmView> {
  late final AppLifecycleListener _lifecycle;

  bool get isAndroid => widget.isAndroid;

  @override
  void initState() {
    super.initState();
    // The user may come back from installing the certificate in Settings.
    _lifecycle = AppLifecycleListener(onResume: _checkTrust);
    _checkTrust();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _checkTrust() {
    unawaited(ref.read(mitmTrustStateProvider.notifier).refresh());
  }

  String _trustLabel(
    AppLocalizations appLocalizations,
    AsyncValue<MitmTrustCheck> trust,
  ) {
    if (trust.value case final check?) {
      return switch (check.trust) {
        MitmTrust.ready => appLocalizations.mitmTrustReady,
        MitmTrust.untrusted => appLocalizations.mitmTrustUntrusted,
        MitmTrust.notInstalled ||
        MitmTrust.notGenerated => appLocalizations.mitmTrustNotInstalled,
      };
    }
    if (trust.error case final error?) {
      return compactError(error);
    }
    return appLocalizations.mitmTrustChecking;
  }

  String? _certificateTip(
    AppLocalizations appLocalizations, {
    required bool canTrust,
    required MitmTrustCheck? check,
  }) {
    if (!canTrust) {
      return appLocalizations.mitmCertificateExportTip;
    }
    if (isAndroid) {
      return check?.systemStore == true
          ? null
          : appLocalizations.mitmCertificateAndroidReadyTip;
    }
    if (check?.trust == MitmTrust.ready) {
      return null;
    }
    final lines = [
      if (check?.certutilInstall case final command?)
        appLocalizations.mitmCertutilMissing(command)
      else if (check?.missingStores case final stores? when stores.isNotEmpty)
        appLocalizations.mitmMissingStores(stores.toSet().join(', ')),
      if (system.isLinux) appLocalizations.mitmCertificateLinuxTip,
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }

  Future<void> _showDetails(
    BuildContext context,
    MitmCertificate certificate,
  ) async {
    await dialogs.showAlert(
      title: certificate.subject,
      message: TextSpan(
        text: [
          context.appLocalizations.validUntil(certificate.notAfter.show),
          'SHA-256\n${certificate.fingerprint}',
        ].join('\n\n'),
      ),
    );
  }

  Future<bool> _confirmAndroidInstall(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final appLocalizations = context.appLocalizations;
    await ref.read(mitmTrustStateProvider.notifier).refresh();
    final root = ref.read(mitmTrustStateProvider).value?.rootAvailable == true;
    final res = await dialogs.showMessage(
      title: appLocalizations.installCertificate,
      message: TextSpan(
        text: root
            ? appLocalizations.mitmInstallSystemCaTip
            : appLocalizations.mitmInstallUserCaTip,
      ),
      confirmText: appLocalizations.installCertificate,
    );
    return res == true;
  }

  Future<void> _install(
    BuildContext context,
    WidgetRef ref, {
    bool confirm = true,
  }) async {
    if (isAndroid && confirm && !await _confirmAndroidInstall(context, ref)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    final trust = ref.read(mitmTrustStateProvider.notifier);
    final outcome = await globalState.loadingRun<MitmInstallOutcome?>(
      trust.install,
      tag: LoadingTag.mitm,
      title: appLocalizations.installCertificate,
    );
    if (!context.mounted) {
      return;
    }
    final check = ref.read(mitmTrustStateProvider).value;
    switch (outcome) {
      // Only su installs straight away on Android.
      case MitmInstallOutcome.installed
          when isAndroid && check?.systemStore != true:
        await dialogs.showAlert(
          message: TextSpan(text: appLocalizations.mitmRootPendingReboot),
        );
      case MitmInstallOutcome.untilReboot:
        await dialogs.showAlert(
          message: TextSpan(text: appLocalizations.mitmRootUntilReboot),
        );
      case MitmInstallOutcome.installed when check?.trust == MitmTrust.ready:
        dialogs.showBanner(
          appLocalizations.installCertificateSuccess,
          level: BannerLevel.success,
        );
      case MitmInstallOutcome.saved:
        final ca = ref.read(mitmCaProvider).value;
        final open = await dialogs.showMessage(
          title: appLocalizations.installCertificate,
          message: TextSpan(
            text: appLocalizations.mitmCertificateSavedTip(
              ca == null ? mitmCertificateFileName : mitmSavedFileName(ca),
            ),
          ),
          confirmText: appLocalizations.openSettings,
        );
        if (open == true) {
          await app?.openCertificateSettings();
        }
      case MitmInstallOutcome.installed || MitmInstallOutcome.prompted || null:
        break;
    }
  }

  Future<void> _export(
    BuildContext context,
    MitmCertificate certificate,
  ) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      final uri = await picker.saveFile(
        mitmCertificateFileName,
        utf8.encode(certificate.pem),
      );
      return uri != null;
    }, title: appLocalizations.exportCertificate);
    if (res == true && context.mounted) {
      dialogs.showBanner(
        appLocalizations.exportSuccess,
        level: BannerLevel.success,
      );
    }
  }

  Future<void> _regenerate(
    BuildContext context,
    WidgetRef ref, {
    required MitmCertificate old,
    required bool canTrust,
  }) async {
    final appLocalizations = context.appLocalizations;
    final systemStore =
        ref.read(mitmTrustStateProvider).value?.systemStore == true;
    final res = await dialogs.showMessage(
      title: appLocalizations.regenerateCertificate,
      message: TextSpan(text: appLocalizations.regenerateCertificateTip),
      destructive: true,
    );
    if (res != true || !context.mounted) {
      return;
    }
    final removed = await globalState.loadingRun<bool>(
      ref.read(mitmTrustStateProvider.notifier).regenerate,
      tag: LoadingTag.mitm,
      title: appLocalizations.regenerateCertificate,
    );
    if (removed == null || !context.mounted) {
      return;
    }
    if (!removed) {
      if (isAndroid &&
          systemStore &&
          !await ref.read(rootAccessProvider.future)) {
        await dialogs.showAlert(
          message: TextSpan(
            text: appLocalizations.mitmOldSystemCertificateLeftTip(old.subject),
          ),
        );
        return;
      }
      if (!context.mounted) {
        return;
      }
      if (isAndroid) {
        final open = await dialogs.showMessage(
          message: TextSpan(
            text: appLocalizations.mitmRemoveOldCertificateTip(old.subject),
          ),
          confirmText: appLocalizations.openSettings,
        );
        if (open == true) {
          await app?.openCertificateSettings(userCredentials: true);
        }
        return;
      }
      await dialogs.showAlert(
        message: TextSpan(
          text: appLocalizations.mitmOldCertificateLeftTip(old.subject),
        ),
      );
    }
    if (canTrust && (!isAndroid || systemStore) && context.mounted) {
      await _install(context, ref, confirm: false);
    }
  }

  List<Widget> _certificateItems(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MitmCertificate?> state, {
    required bool canTrust,
  }) {
    final appLocalizations = context.appLocalizations;
    final certificate = state.value;
    if (certificate == null) {
      final error = state.error;
      return [
        ListItem(
          title: Text(appLocalizations.generateCertificate),
          subtitle: error == null ? null : Text(compactError(error)),
          onTap: () => _generateCertificate(
            ref.read(mitmCaProvider.notifier),
            appLocalizations.generateCertificate,
          ),
        ),
      ];
    }
    final trust = ref.watch(mitmTrustStateProvider);
    final installable = switch (trust.value) {
      MitmTrustCheck(trust: MitmTrust.notInstalled || MitmTrust.untrusted) =>
        canTrust,
      MitmTrustCheck(
        trust: MitmTrust.ready,
        systemStore: false,
        rootAvailable: true,
      ) =>
        canTrust,
      _ => false,
    };
    return [
      ListItem(
        title: Text(certificate.subject),
        subtitle: Text(_trustLabel(appLocalizations, trust)),
        onTap: () => _showDetails(context, certificate),
      ),
      if (installable)
        ListItem(
          title: Text(
            trust.value?.trust == MitmTrust.untrusted
                ? appLocalizations.trustCertificate
                : appLocalizations.installCertificate,
          ),
          onTap: () => _install(context, ref),
        ),
      ListItem(
        title: Text(appLocalizations.exportCertificate),
        onTap: () => _export(context, certificate),
      ),
      ListItem(
        title: Text(appLocalizations.regenerateCertificate),
        onTap: () =>
            _regenerate(context, ref, old: certificate, canTrust: canTrust),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final certificate = ref.watch(mitmCaProvider);
    final canTrust =
        ref.watch(mitmTrustStoreProvider) != null &&
        !ref.watch(safeModeProvider);
    final check = certificate.value == null
        ? null
        : ref.watch(mitmTrustStateProvider).value;
    return Scaffold(
      title: appLocalizations.mitm,
      isLoading: ref.watch(loadingProvider(LoadingTag.mitm)),
      body: NullStatusSwitcher(
        isLoading: certificate.isLoading && !certificate.hasValue,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: context.contentTopPadding,
                bottom: 16 + context.bottomInset,
              ),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        generateSection(
                          items: [
                            const _MitmEnableItem(),
                            _MitmCaptureItem(isAndroid: isAndroid),
                          ],
                        ),
                        generateSection(
                          title: appLocalizations.certificate,
                          items: _certificateItems(
                            context,
                            ref,
                            certificate,
                            canTrust: canTrust,
                          ),
                          footer: _certificateTip(
                            appLocalizations,
                            canTrust: canTrust,
                            check: check,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        generateSection(
                          title: appLocalizations.mitmModules,
                          items: const [MitmModulesItem()],
                        ),
                        generateSection(
                          items: const [_MitmHostnameItem()],
                          footer: appLocalizations.mitmHostnameDesc,
                        ),
                        generateSection(
                          title: appLocalizations.options,
                          items: [
                            ConfigToggleItem(
                              title: (l) => l.skipServerCertVerify,
                              selector: patchClashConfigProvider.select(
                                (state) => state.mitm.skipServerCertVerify,
                              ),
                              onChanged: _mitmWriter(
                                (state, value) =>
                                    state.copyWith(skipServerCertVerify: value),
                              ),
                            ),
                            ConfigToggleItem(
                              title: (l) => l.blockQuic,
                              selector: patchClashConfigProvider.select(
                                (state) => state.mitm.autoQuicBlock,
                              ),
                              onChanged: _mitmWriter(
                                (state, value) =>
                                    state.copyWith(autoQuicBlock: value),
                              ),
                            ),
                            ConfigToggleItem(
                              title: (l) => l.http2,
                              selector: patchClashConfigProvider.select(
                                (state) => state.mitm.h2,
                              ),
                              onChanged: _mitmWriter(
                                (state, value) => state.copyWith(h2: value),
                              ),
                            ),
                            ConfigToggleItem(
                              title: (l) => l.decryptUntrusted,
                              selector: patchClashConfigProvider.select(
                                (state) => state.mitm.decryptUntrusted,
                              ),
                              onChanged: _mitmWriter(
                                (state, value) =>
                                    state.copyWith(decryptUntrusted: value),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _MitmEnableItem extends ConsumerWidget {
  const _MitmEnableItem();

  Future<void> _handleChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final config = ref.read(patchClashConfigProvider.notifier);
    if (value) {
      final appLocalizations = context.appLocalizations;
      final ca = ref.read(mitmCaProvider.notifier);
      final hasCertificate = ref.read(mitmCaProvider).value != null;
      final res = await dialogs.showMessage(
        title: appLocalizations.httpsDecryption,
        message: TextSpan(text: appLocalizations.mitmEnableTip),
      );
      if (res != true) {
        return;
      }
      if (!hasCertificate &&
          !await _generateCertificate(
            ca,
            appLocalizations.generateCertificate,
          )) {
        return;
      }
    }
    config.update(
      (state) => state.copyWith(mitm: state.mitm.copyWith(enable: value)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(
      patchClashConfigProvider.select((state) => state.mitm.enable),
    );
    return ListItem.toggle(
      title: Text(context.appLocalizations.httpsDecryption),
      value: enable,
      onChanged: (value) => _handleChanged(context, ref, value),
    );
  }
}

class _MitmCaptureItem extends ConsumerWidget {
  const _MitmCaptureItem({required this.isAndroid});

  final bool isAndroid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final capture = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.mitm.enable && state.mitm.capture,
      ),
    );
    return ListItem.open(
      title: Text(appLocalizations.httpCapture),
      subtitle: Text(
        capture ? appLocalizations.enabled : appLocalizations.disabled,
      ),
      widget: _MitmCaptureView(isAndroid: isAndroid),
    );
  }
}

class _MitmCaptureView extends ConsumerWidget {
  const _MitmCaptureView({required this.isAndroid});

  final bool isAndroid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (enable, capture, limit) = ref.watch(
      patchClashConfigProvider.select(
        (state) => (
          state.mitm.enable,
          state.mitm.capture,
          state.mitm.captureLimit(isAndroid: isAndroid),
        ),
      ),
    );
    final noHost = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.mitm.enable &&
            state.mitm.capture &&
            state.mitm.hostname.every((line) => line.startsWith('-')),
      ),
    );
    final hasModule = ref.watch(
      mitmModulesProvider.select(
        (state) => state.value?.any((module) => module.enabled) == true,
      ),
    );
    final options = mitmCaptureOptions(isAndroid: isAndroid);
    return Scaffold(
      title: appLocalizations.httpCapture,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.sectionsTopPadding,
          bottom: 16 + context.bottomInset,
        ),
        children: [
          generateSection(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.httpCapture),
                value: capture,
                onChanged: enable
                    ? (value) => _updateMitm(
                        ref,
                        (state) => state.copyWith(capture: value),
                      )
                    : null,
              ),
            ],
            footer: noHost && !hasModule
                ? appLocalizations.httpCaptureNoHosts
                : appLocalizations.httpCaptureDesc,
          ),
          generateSection(
            items: [
              ListItem<int>.options(
                title: Text(appLocalizations.httpCaptureLimit),
                options: options.contains(limit)
                    ? options
                    : ([...options, limit]..sort()),
                value: limit,
                textBuilder: (value) => '$value',
                onChanged: (value) => _updateMitm(
                  ref,
                  (state) => state.copyWith(captureEntries: value),
                ),
              ),
            ],
            footer: appLocalizations.httpCaptureLimitDesc(
              mitmCaptureBytes(isAndroid: isAndroid).traffic.show,
              mitmMaxBodySize(isAndroid: isAndroid).traffic.show,
            ),
          ),
        ],
      ),
    );
  }
}

class _MitmHostnameItem extends ConsumerWidget {
  const _MitmHostnameItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final count = ref.watch(
      patchClashConfigProvider.select((state) => state.mitm.hostname.length),
    );
    final invalid = ref.watch(mitmHostnameIssuesProvider).value?.length ?? 0;
    return ListItem.open(
      title: Text(appLocalizations.hostname),
      subtitle: Text(switch ((count, invalid)) {
        (0, _) => appLocalizations.none,
        (_, 0) => appLocalizations.itemsCount(count),
        _ => appLocalizations.invalidOfCount(invalid, count),
      }),
      widget: const _MitmHostnameView(),
    );
  }
}

class _MitmHostnameView extends ConsumerWidget {
  const _MitmHostnameView();

  List<String> _linesOf(WidgetRef ref) =>
      ref.read(patchClashConfigProvider).mitm.hostname;

  void _save(WidgetRef ref, List<String> lines) {
    _updateMitm(ref, (state) => state.copyWith(hostname: lines));
  }

  Future<void> _handleAddOrUpdate(
    BuildContext context,
    WidgetRef ref, [
    String? line,
  ]) async {
    final res = await showListEntryDialog(
      context,
      entries: _linesOf(ref),
      entry: line,
      valueLabel: context.appLocalizations.hostname,
    );
    if (res == null || !context.mounted) {
      return;
    }
    final current = _linesOf(ref);
    _save(
      ref,
      line == null
          ? [...current, res]
          : [for (final item in current) item == line ? res : item],
    );
  }

  Future<void> _handleQuickEdit(BuildContext context, WidgetRef ref) {
    return showListQuickEdit(
      context,
      title: context.appLocalizations.hostname,
      items: _linesOf(ref),
      onChanged: (lines) => _save(ref, lines),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = context.appLocalizations.hostname;
    final issues = ref.watch(mitmHostnameIssuesProvider).value ?? const {};
    final errorStyle = TextStyle(color: context.colorScheme.error);
    return ListEditorPage<String, String>(
      title: title,
      idOf: (line) => line,
      itemsOf: (ref) => ref.watch(
        patchClashConfigProvider.select((state) => state.mitm.hostname),
      ),
      itemBuilder:
          (context, ref, line, index, isEditing, isSelected, onToggleSelected) {
            final issue = issues[line];
            return SelectedDecorationListItem(
              title: Text(line),
              subtitle: issue == null ? null : Text(issue, style: errorStyle),
              invalid: issue != null,
              isEditing: isEditing,
              isSelected: isSelected,
              onSelected: onToggleSelected,
              onPressed: () => _handleAddOrUpdate(context, ref, line),
            );
          },
      onReorder: (oldIndex, newIndex) =>
          _save(ref, _linesOf(ref).copyAndReorder(oldIndex, newIndex)),
      onAdd: () => _handleAddOrUpdate(context, ref),
      onQuickEdit: () => _handleQuickEdit(context, ref),
      onDelete: (lines) => _save(ref, [
        for (final line in _linesOf(ref))
          if (!lines.contains(line)) line,
      ]),
      searchFieldsOf: (line) => [line],
      emptyLabel: context.appLocalizations.nullTip(title),
    );
  }
}
