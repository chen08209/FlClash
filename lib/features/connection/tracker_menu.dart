import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_mitm_host.dart';
import 'tracker_texts.dart';

/// What a page lets a connection's menu do to its list.
class TrackerMenuActions {
  final ValueChanged<TrackerInfo>? close;
  final ValueChanged<TrackerInfo>? onlyApp;
  final ValueChanged<TrackerInfo>? hideHost;

  const TrackerMenuActions({this.close, this.onlyApp, this.hideHost});
}

class TrackerMenuScope extends InheritedWidget {
  final TrackerMenuActions actions;

  const TrackerMenuScope({
    super.key,
    required this.actions,
    required super.child,
  });

  static TrackerMenuActions? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TrackerMenuScope>()?.actions;

  @override
  bool updateShouldNotify(TrackerMenuScope oldWidget) => false;
}

/// What the ⋯ at the head of a connection's detail offers.
List<PopupMenuItem> trackerDetailMenuItems(
  BuildContext context,
  WidgetRef ref,
  TrackerInfo trackerInfo,
) {
  final appLocalizations = context.appLocalizations;
  final metadata = trackerInfo.metadata;
  final destination = trackerEndpointText(
    metadata.destinationIP,
    metadata.destinationPort,
  );
  final mitmChange = mitmHostChangeOf(
    appLocalizations,
    metadata,
    ref.read(patchClashConfigProvider).mitm,
  );
  return [
    if (metadata.host.isNotEmpty)
      copyMenuItem(appLocalizations.copyHost, metadata.host),
    if (destination.isNotEmpty)
      copyMenuItem(appLocalizations.copyDestination, destination),
    copyMenuItem(
      appLocalizations.copySummary,
      trackerSummaryText(appLocalizations, trackerInfo),
    ),
    if (mitmChange != null)
      PopupMenuItem(
        glyph: AppGlyphs.lock,
        label: mitmChange.title,
        section: const PopupMenuSection(),
        onPressed: () => applyMitmHostChange(ref, mitmChange),
      ),
  ];
}
