import 'dart:async';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adds the host of a connection to the hostnames or excludes it, so that the
/// list can be filled from what the apps really connect to.
typedef MitmHostChange = ({
  String title,
  String tip,
  Mitm Function(Mitm) update,
});

/// Whether decrypting the host of [metadata] can be turned on or off from here.
MitmHostChange? mitmHostChangeOf(
  AppLocalizations appLocalizations,
  Metadata metadata,
  Mitm mitm,
) {
  final host = metadata.host;
  if (!mitm.enable || host.isEmpty || metadata.network.toLowerCase() != 'tcp') {
    return null;
  }
  final hostname = mitm.hostname;
  final decrypted = metadata.mitm || metadata.mitmRefused;
  if (!hostname.contains('-$host') && (decrypted || hostname.contains(host))) {
    return (
      title: appLocalizations.mitmExcludeHost,
      tip: appLocalizations.mitmExcludeHostTip(host),
      update: (mitm) => mitm.excludingHost(host),
    );
  }
  return (
    title: appLocalizations.mitmDecryptHost,
    tip: appLocalizations.mitmDecryptHostTip(host),
    update: (mitm) => mitm.decryptingHost(host),
  );
}

Future<void> applyMitmHostChange(WidgetRef ref, MitmHostChange change) async {
  final res = await dialogs.showMessage(
    title: change.title,
    message: TextSpan(text: change.tip),
  );
  if (res != true) {
    return;
  }
  ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => state.copyWith(mitm: change.update(state.mitm)));
}

class MitmHostSection extends ConsumerWidget {
  final Metadata metadata;
  final bool last;

  const MitmHostSection({super.key, required this.metadata, this.last = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final change = mitmHostChangeOf(
      appLocalizations,
      metadata,
      ref.watch(patchClashConfigProvider.select((state) => state.mitm)),
    );
    if (change == null) {
      return const SizedBox.shrink();
    }
    return generateSection(
      title: appLocalizations.httpsDecryption,
      items: [
        ListItem(
          title: Text(change.title),
          onTap: () => applyMitmHostChange(ref, change),
        ),
      ],
      footer: metadata.mitmRefused
          ? appLocalizations.mitmClientRefusedCertificate
          : null,
      last: last,
    );
  }
}
