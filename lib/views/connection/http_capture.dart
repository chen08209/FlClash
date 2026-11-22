import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/advanced.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Says on the connections page whether HTTP capture records, and opens
/// [HttpCaptureView]; a phone's bar, which the feed title shares, holds it as
/// a toggle-styled button rather than a labeled chip.
class HttpCaptureEntry extends ConsumerWidget {
  const HttpCaptureEntry({super.key, required this.isAndroid});

  final bool isAndroid;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    await showNestedSheet<void>(
      context,
      builder: (_) => HttpCaptureView(isAndroid: isAndroid),
    );
    if (context.mounted) {
      _giveWayToBar(context, ref);
    }
  }

  /// Turning decryption on from the panel moves connections into the bottom
  /// bar; this page, opened from the tools list, then gives way to that one.
  void _giveWayToBar(BuildContext context, WidgetRef ref) {
    final route = ModalRoute.of(context);
    final inBar = ref
        .read(currentNavigationItemsStateProvider)
        .value
        .any((item) => item.label == PageLabel.requests);
    if (!inBar || route == null || route.isFirst) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.requests);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final capturing = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.mitm.enable && state.mitm.capture,
      ),
    );
    final label = capturing
        ? appLocalizations.httpCapturing
        : appLocalizations.httpCaptureOff;
    if (ref.watch(isMobileViewProvider)) {
      return AppBarActionButton(
        data: IconButtonData(
          glyph: AppGlyphs.eye,
          tooltip: label,
          isSelected: capturing,
          onPressed: () => _open(context, ref),
        ),
      );
    }
    return Chip(
      label: label,
      selected: capturing,
      onPressed: () => _open(context, ref),
    );
  }
}

class HttpCaptureView extends ConsumerWidget {
  const HttpCaptureView({super.key, required this.isAndroid});

  final bool isAndroid;

  void _update(WidgetRef ref, Mitm Function(Mitm) update) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mitm: update(state.mitm)));
  }

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
        padding: context.listInsets.page().copyWith(
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
                    ? (value) => _update(
                        ref,
                        (state) => state.copyWith(capture: value),
                      )
                    : null,
              ),
            ],
            footer: switch ((enable, noHost && !hasModule)) {
              (false, _) => appLocalizations.httpCaptureNeedsDecryption,
              (true, true) => appLocalizations.httpCaptureNoHosts,
              (true, false) => appLocalizations.httpCaptureDesc,
            },
          ),
          if (!enable)
            generateSection(
              items: [
                ListItem.open(
                  leading: const GlyphIcon(AppGlyphs.lockOpen),
                  title: Text(appLocalizations.goToMitmSettings),
                  widget: AdvancedConfigView(isAndroid: isAndroid),
                ),
              ],
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
                onChanged: (value) => _update(
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
