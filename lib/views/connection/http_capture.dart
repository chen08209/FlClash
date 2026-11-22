import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/config/advanced.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Says in the requests page's bar whether HTTP capture records, as a toggled
/// button, and opens [HttpCaptureView].
class HttpCaptureEntry extends ConsumerWidget {
  const HttpCaptureEntry({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    await showNestedSheet<void>(
      context,
      builder: (_) => const HttpCaptureView(),
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
    final capturing = ref.watch(patchClashConfigProvider.select(httpCapturing));
    final label = capturing
        ? appLocalizations.httpCapturing
        : appLocalizations.httpCaptureOff;
    return AppBarActionButton(
      data: IconButtonData(
        glyph: AppGlyphs.eye,
        tooltip: label,
        isSelected: capturing,
        onPressed: () => _open(context, ref),
      ),
    );
  }
}

bool httpCapturing(PatchClashConfig state) =>
    state.mitm.enable && state.mitm.capture;

void _update(WidgetRef ref, Mitm Function(Mitm) update) {
  ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => state.copyWith(mitm: update(state.mitm)));
}

/// Turns capture on and off, and leads to decryption's settings while
/// decryption, which capture needs, is off.
class HttpCaptureSwitch extends ConsumerWidget {
  final bool last;

  const HttpCaptureSwitch({super.key, this.last = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (enable, capture) = ref.watch(
      patchClashConfigProvider.select(
        (state) => (state.mitm.enable, state.mitm.capture),
      ),
    );
    final noHost = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            httpCapturing(state) &&
            state.mitm.hostname.every((line) => line.startsWith('-')),
      ),
    );
    final hasModule = ref.watch(
      mitmModulesProvider.select(
        (state) => state.value?.any((module) => module.enabled) == true,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        generateSection(
          items: [
            ListItem.toggle(
              title: Text(appLocalizations.httpCapture),
              value: capture,
              onChanged: enable
                  ? (value) =>
                        _update(ref, (state) => state.copyWith(capture: value))
                  : null,
            ),
          ],
          footer: switch ((enable, noHost && !hasModule)) {
            (false, _) => appLocalizations.httpCaptureNeedsDecryption,
            (true, true) => appLocalizations.httpCaptureNoHosts,
            (true, false) => appLocalizations.httpCaptureDesc,
          },
          last: last && enable,
        ),
        if (!enable)
          generateSection(
            items: [
              ListItem.open(
                leading: const GlyphIcon(AppGlyphs.lockOpen),
                title: Text(appLocalizations.goToMitmSettings),
                widget: const AdvancedConfigView(),
              ),
            ],
          ),
      ],
    );
  }
}

class HttpCaptureView extends ConsumerWidget {
  const HttpCaptureView({super.key, this.isAndroid});

  final bool? isAndroid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isAndroid = this.isAndroid ?? system.isAndroid;
    final limit = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.mitm.captureLimit(isAndroid: isAndroid),
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
          const HttpCaptureSwitch(),
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
            last: true,
          ),
        ],
      ),
    );
  }
}
