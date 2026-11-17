import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_selection.dart';
import 'tracker_texts.dart';
import 'tracker_app_well.dart';
import 'tracker_clock.dart';

class _NoSelection implements ValueListenable<int?> {
  const _NoSelection();

  @override
  int? get value => null;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

/// Connections a record names, each opening beside the list where a page
/// shows one there and in a sheet elsewhere.
class RelatedConnections extends StatelessWidget {
  final String title;
  final List<int> ids;
  final bool atTop;
  final ValueChanged<TrackerInfo>? onOpenConnection;

  const RelatedConnections({
    super.key,
    required this.title,
    required this.ids,
    required this.atTop,
    required this.onOpenConnection,
  });

  @override
  Widget build(BuildContext context) => _opening(
    onOpenConnection,
    generateSection(
      title: title,
      atTop: atTop,
      items: [for (final id in ids) _relatedRow(id)],
    ),
  );
}

/// [RelatedConnections] as slivers that build only the rows in view.
class SliverRelatedConnections extends StatelessWidget {
  final String title;
  final List<int> ids;
  final bool atTop;
  final ValueChanged<TrackerInfo>? onOpenConnection;

  const SliverRelatedConnections({
    super.key,
    required this.title,
    required this.ids,
    required this.atTop,
    required this.onOpenConnection,
  });

  @override
  Widget build(BuildContext context) => _opening(
    onOpenConnection,
    generateSliverSection(
      title: title,
      atTop: atTop,
      items: ids,
      itemBuilder: _relatedRow,
    ),
  );
}

Widget _opening(ValueChanged<TrackerInfo>? onOpen, Widget section) =>
    onOpen == null
    ? section
    : TrackerSelection(
        selected: const _NoSelection(),
        onSelect: onOpen,
        child: section,
      );

Widget _relatedRow(int id) => Consumer(
  key: ValueKey(id),
  builder: (context, ref, _) {
    final trackerInfo = ref.watch(requestsProvider.select((log) => log[id]));
    if (trackerInfo == null) {
      return const SizedBox.shrink();
    }
    return RelatedConnectionRow(trackerInfo: trackerInfo);
  },
);

class RelatedConnectionRow extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const RelatedConnectionRow({super.key, required this.trackerInfo});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final metadata = trackerInfo.metadata;
    final failure = trackerInfo.failure;
    final route = [
      trackerEndpointText(metadata.destinationIP, metadata.destinationPort),
      trackerInfo.chains.firstOrNull ?? '',
    ].where((part) => part.isNotEmpty).join(' · ');
    return DecorationListItem(
      onPressed: () => openTrackerInfo(
        context,
        trackerInfo,
        appLocalizations.details(appLocalizations.connection),
      ),
      contentPadding: ListItem.chevronPaddingOf(context),
      leading: TrackerAppWell(
        trackerInfo: trackerInfo,
        size: listLeadingSlotWidth,
        showsState: false,
      ),
      title: Text(
        metadata.process.isNotEmpty ? metadata.process : metadata.host,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: failure != null
          ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: appLocalizations.connectionsFailed,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                  TextSpan(text: ' · ${failure.kind.label}'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : TrackerLifetime(
              trackerInfo: trackerInfo,
              builder: (lifetime) => Text(
                [
                  route,
                  trackerInfo.isActive
                      ? '${appLocalizations.connectionsActive} $lifetime'
                      : '${appLocalizations.connectionClosed} $lifetime',
                ].where((part) => part.isNotEmpty).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
      trailing: const GlyphIcon(Glyphs.chevronForward),
    );
  }
}
