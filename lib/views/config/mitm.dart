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
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
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

class MitmOptionsView extends ConsumerStatefulWidget {
  const MitmOptionsView({super.key, required this.isAndroid});

  final bool isAndroid;

  @override
  ConsumerState<MitmOptionsView> createState() => _MitmOptionsViewState();
}

class _MitmOptionsViewState extends ConsumerState<MitmOptionsView>
    with RouteSettledMixin<MitmOptionsView> {
  late final AppLifecycleListener _lifecycle;

  bool get isAndroid => widget.isAndroid;

  @override
  void initState() {
    super.initState();
    // The user may come back from installing the certificate in Settings.
    _lifecycle = AppLifecycleListener(onResume: _checkTrust);
  }

  @override
  void didSettleRoute() => unawaited(
    whenNothingAnimates().then((_) {
      if (mounted) {
        _checkTrust();
      }
    }),
  );

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
      if (check?.untrustedStores case final stores? when stores.isNotEmpty)
        appLocalizations.mitmUntrustedStores(stores.toSet().join(', ')),
      if (system.isLinux) appLocalizations.mitmCertificateLinuxTip,
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }

  Future<void> _showDetails(
    BuildContext context,
    WidgetRef ref,
    MitmCertificate certificate, {
    required bool removable,
  }) async {
    final appLocalizations = context.appLocalizations;
    final title = certificate.subject;
    final message = TextSpan(
      text: [
        appLocalizations.validUntil(certificate.notAfter.show),
        'SHA-256\n${certificate.fingerprint}',
      ].join('\n\n'),
    );
    if (!removable) {
      await dialogs.showAlert(title: title, message: message);
      return;
    }
    final remove = await dialogs.showMessage(
      title: title,
      message: message,
      cancelText: appLocalizations.close,
      confirmText: appLocalizations.removeCertificate,
      destructive: true,
    );
    if (remove == true && context.mounted) {
      await _remove(context, ref, certificate);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    MitmCertificate certificate,
  ) async {
    final appLocalizations = context.appLocalizations;
    final outcome = await globalState.loadingRun<MitmRemoveOutcome?>(
      ref.read(mitmTrustStateProvider.notifier).remove,
      tag: LoadingTag.mitm,
      title: appLocalizations.removeCertificate,
    );
    if (!context.mounted) {
      return;
    }
    switch (outcome) {
      case MitmRemoveOutcome.removed:
        dialogs.showBanner(
          appLocalizations.removeCertificateSuccess,
          level: BannerLevel.success,
        );
      case MitmRemoveOutcome.userStore:
        final open = await dialogs.showMessage(
          title: appLocalizations.mitmRemoveInSettings,
          message: TextSpan(
            text: appLocalizations.mitmRemoveUserCertificateTip(
              certificate.subject,
            ),
          ),
          confirmText: appLocalizations.openSettings,
        );
        if (open == true) {
          await app?.openCertificateSettings(userCredentials: true);
        }
      case MitmRemoveOutcome.needsRoot:
        await dialogs.showAlert(
          title: appLocalizations.mitmCannotRemove,
          message: TextSpan(
            text: appLocalizations.mitmRemoveSystemCertificateTip,
          ),
        );
      case MitmRemoveOutcome.failed:
        dialogs.showBanner(
          appLocalizations.mitmSystemStoreRemoveFailed,
          level: BannerLevel.error,
        );
      case null:
        break;
    }
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

  Widget _trustGlyph(
    BuildContext context, {
    required MitmCertificate? certificate,
    required AsyncValue<MitmTrustCheck> trust,
  }) {
    final colorScheme = context.colorScheme;
    final color = certificate == null
        ? colorScheme.onSurfaceVariant
        : trust.value?.trust == MitmTrust.ready
        ? colorScheme.success
        : trust.hasError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    return GlyphIcon(AppGlyphs.certificate, size: 32, color: color);
  }

  List<Widget> _certificateItems(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MitmCertificate?> state, {
    required bool canTrust,
  }) {
    final appLocalizations = context.appLocalizations;
    final certificate = state.value;
    final trust = ref.watch(mitmTrustStateProvider);
    final leading = _trustGlyph(
      context,
      certificate: certificate,
      trust: trust,
    );
    if (certificate == null) {
      final error = state.error;
      return [
        ListItem(
          leading: leading,
          title: Text(appLocalizations.generateCertificate),
          subtitle: error == null ? null : Text(compactError(error)),
          onTap: () => _generateCertificate(
            ref.read(mitmCaProvider.notifier),
            appLocalizations.generateCertificate,
          ),
        ),
      ];
    }
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
      ContextMenuRegion(
        menuItems: [
          PopupMenuItem(
            glyph: AppGlyphs.export,
            label: appLocalizations.exportCertificate,
            onPressed: () => _export(context, certificate),
          ),
        ],
        child: ListItem(
          leading: leading,
          title: Text(certificate.subject),
          subtitle: Text(_trustLabel(appLocalizations, trust)),
          onTap: () {
            if (installable) {
              _install(context, ref);
            } else if (!canTrust) {
              _export(context, certificate);
            } else {
              _showDetails(
                context,
                ref,
                certificate,
                removable: switch (trust.value?.trust) {
                  MitmTrust.ready || MitmTrust.untrusted => true,
                  _ => false,
                },
              );
            }
          },
        ),
      ),
      ListItem(
        title: Text(
          appLocalizations.regenerateCertificate,
          style: TextStyle(color: context.colorScheme.error),
        ),
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
      title: appLocalizations.options,
      isLoading: ref.watch(loadingProvider(LoadingTag.mitm)),
      body: NullStatusSwitcher(
        isLoading: certificate.isLoading && !certificate.hasValue,
        child: ListView(
          padding: context.listInsets.page().copyWith(
            top: context.contentTopPadding,
            bottom: 16 + context.bottomInset,
          ),
          children: [
            generateSection(
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
            generateSection(
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
                    (state, value) => state.copyWith(autoQuicBlock: value),
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
                    (state, value) => state.copyWith(decryptUntrusted: value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MitmEnableItem extends ConsumerWidget {
  const MitmEnableItem({super.key});

  Future<void> _handleChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final config = ref.read(patchClashConfigProvider.notifier);
    if (value) {
      final appLocalizations = context.appLocalizations;
      final ca = ref.read(mitmCaProvider.notifier);
      final hasCertificate = ref
          .read(mitmCaProvider.future)
          .then((ca) => ca != null, onError: (_) => false);
      final res = await dialogs.showMessage(
        title: appLocalizations.httpsDecryption,
        message: TextSpan(text: appLocalizations.mitmEnableTip),
      );
      if (res != true) {
        return;
      }
      if (!await hasCertificate &&
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
      leading: const GlyphIcon(AppGlyphs.lockOpen),
      title: Text(context.appLocalizations.httpsDecryption),
      value: enable,
      onChanged: (value) => _handleChanged(context, ref, value),
    );
  }
}

class MitmHostnameItem extends ConsumerWidget {
  const MitmHostnameItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final count = ref.watch(
      patchClashConfigProvider.select((state) => state.mitm.hostname.length),
    );
    final invalid = ref.watch(mitmHostnameIssuesProvider).value?.length ?? 0;
    return ListItem.open(
      leading: const GlyphIcon(AppGlyphs.target),
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
