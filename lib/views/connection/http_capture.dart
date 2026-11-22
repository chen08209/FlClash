import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool httpCapturing(PatchClashConfig state) =>
    state.mitm.enable && state.mitm.capture;

/// No listed host and no module to list one: capture records nothing.
bool httpCaptureHasNoHost(PatchClashConfig state, bool hasModule) =>
    !hasModule && state.mitm.hostname.every((line) => line.startsWith('-'));

void _update(WidgetRef ref, Mitm Function(Mitm) update) {
  ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => state.copyWith(mitm: update(state.mitm)));
}

List<PopupMenuItem> httpCaptureMenuItems(
  WidgetRef ref,
  AppLocalizations appLocalizations, {
  required Mitm mitm,
  required bool isAndroid,
}) {
  final limit = mitm.captureLimit(isAndroid: isAndroid);
  final options = mitmCaptureOptions(isAndroid: isAndroid);
  return [
    PopupMenuItem(
      label: appLocalizations.turnOn,
      subtitle: appLocalizations.httpCaptureMemoryOnly,
      checked: mitm.capture,
      section: PopupMenuSection(title: appLocalizations.httpCapture),
      onPressed: () => _update(ref, (state) => state.copyWith(capture: true)),
    ),
    PopupMenuItem(
      label: appLocalizations.turnOff,
      checked: !mitm.capture,
      onPressed: () => _update(ref, (state) => state.copyWith(capture: false)),
    ),
    PopupMenuItem(
      label: appLocalizations.httpCaptureLimit,
      subtitle: '$limit',
      subItems: [
        for (final option
            in options.contains(limit)
                ? options
                : ([...options, limit]..sort()))
          PopupMenuItem(
            label: '$option',
            checked: option == limit,
            onPressed: () =>
                _update(ref, (state) => state.copyWith(captureEntries: option)),
          ),
      ],
    ),
  ];
}
