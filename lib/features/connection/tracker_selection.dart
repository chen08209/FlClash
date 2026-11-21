import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_info_item.dart';

/// Where a page shows the connection a row opens beside its list, the rows
/// select it here rather than each opening a sheet of its own.
class TrackerSelection extends InheritedWidget {
  final ValueListenable<String?> selected;
  final ValueChanged<TrackerInfo> onSelect;

  const TrackerSelection({
    super.key,
    required this.selected,
    required this.onSelect,
    required super.child,
  });

  static TrackerSelection? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TrackerSelection>();

  @override
  bool updateShouldNotify(TrackerSelection oldWidget) =>
      selected != oldWidget.selected || onSelect != oldWidget.onSelect;
}

void openTrackerInfo(
  BuildContext context,
  TrackerInfo trackerInfo,
  String detailTitle,
) {
  final selection = TrackerSelection.maybeOf(context);
  if (selection == null) {
    showTrackerInfoDetail(context, trackerInfo, detailTitle);
  } else {
    selection.onSelect(trackerInfo);
  }
}

/// Builds [builder] with whether the row of [id] is the selected one, and
/// scrolls the row into view when it becomes so.
class TrackerSelected extends StatefulWidget {
  final String id;
  final Widget Function(BuildContext context, bool selected) builder;

  const TrackerSelected({super.key, required this.id, required this.builder});

  @override
  State<TrackerSelected> createState() => _TrackerSelectedState();
}

class _TrackerSelectedState extends State<TrackerSelected> {
  ValueListenable<String?>? _selected;
  var _isSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selected = TrackerSelection.maybeOf(context)?.selected;
    if (selected != _selected) {
      _selected?.removeListener(_handleSelected);
      _selected = selected?..addListener(_handleSelected);
      _isSelected = selected?.value == widget.id;
    }
  }

  @override
  void didUpdateWidget(TrackerSelected oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _isSelected = _selected?.value == widget.id;
    }
  }

  @override
  void dispose() {
    _selected?.removeListener(_handleSelected);
    super.dispose();
  }

  void _handleSelected() {
    final isSelected = _selected?.value == widget.id;
    if (isSelected == _isSelected) {
      return;
    }
    setState(() => _isSelected = isSelected);
    if (isSelected) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  void _reveal() {
    if (!mounted) {
      return;
    }
    final row = context.findRenderObject() as RenderBox?;
    final viewport =
        Scrollable.maybeOf(
              context,
              axis: Axis.vertical,
            )?.context.findRenderObject()
            as RenderBox?;
    if (row == null || viewport == null || !row.attached) {
      return;
    }
    final top = row.localToGlobal(Offset.zero, ancestor: viewport).dy;
    if (top >= 0 && top + row.size.height <= viewport.size.height) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isSelected);
}

class TrackerInfoHeader extends StatelessWidget {
  final TrackerInfo trackerInfo;

  /// Sets the header a size smaller, for a detail read beside a table.
  final bool compact;

  const TrackerInfoHeader({
    super.key,
    required this.trackerInfo,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final metadata = trackerInfo.metadata;
    final active = trackerInfo.isActive;
    final subtitle = [
      trackerInfo.progressText,
      metadata.network.toUpperCase(),
      metadata.destinationPort,
    ].where((part) => part.isNotEmpty).join(' · ');
    final state = active
        ? appLocalizations.connectionsActive
        : appLocalizations.connectionClosed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            TrackerAppWell(trackerInfo: trackerInfo, size: compact ? 40 : 44),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    trackerInfo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.headline.of(context),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TrackerLifetime(
              trackerInfo: trackerInfo,
              builder: (lifetime) => TonalChip(
                label: '$state · $lifetime',
                color: active
                    ? colorScheme.successContainer
                    : context.raisedSurfaceLevel.colorOf(colorScheme),
                foregroundColor: active
                    ? colorScheme.onSuccessContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            ...trackerLabels(context, trackerInfo),
          ],
        ),
      ],
    );
  }
}

/// The selected connection beside the list, as its latest version.
class TrackerInfoDetailCard extends ConsumerWidget {
  final String id;
  final VoidCallback onClose;

  const TrackerInfoDetailCard({
    super.key,
    required this.id,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerInfo = ref.watch(requestsProvider.select((log) => log[id]));
    if (trackerInfo == null) {
      return const SizedBox.shrink();
    }
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TrackerInfoHeader(
                    trackerInfo: trackerInfo,
                    compact: true,
                  ),
                ),
                PopupAnchor(
                  targetBuilder: (open) => IconButton(
                    tooltip: context.appLocalizations.more,
                    onPressed: open,
                    icon: const GlyphIcon(AppGlyphs.more),
                  ),
                  popupBuilder: (context) => PopupMenu(
                    items: trackerInfoMenuItems(
                      context,
                      trackerInfo,
                      inDetail: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.appLocalizations.close,
                  onPressed: onClose,
                  icon: const GlyphIcon(AppGlyphs.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: BottomInsetScope(
                inset: 0,
                child: TopInsetScope(
                  inset: 8,
                  child: TrackerInfoDetailView(
                    trackerInfo: trackerInfo,
                    compact: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The selected connection in a side sheet, stepping to the rows around it.
/// Its bar has no room for a title beside the steps, so the connection's
/// header heads its body instead.
class TrackerInfoDetailSheet extends StatelessWidget {
  final ValueListenable<String?> selected;

  /// Read out rather than shown.
  final String title;
  final void Function(int step)? onStep;
  final bool Function(int step)? canStep;

  /// Changes what [canStep] says besides [selected].
  final Listenable? refresh;

  /// The page's, which a sheet over it does not inherit.
  final TrackerMenuActions? actions;

  const TrackerInfoDetailSheet({
    super.key,
    required this.selected,
    required this.title,
    this.onStep,
    this.canStep,
    this.refresh,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final onStep = this.onStep;
    final canStep = this.canStep ?? (_) => true;
    return ListenableBuilder(
      listenable: Listenable.merge([selected, refresh]),
      builder: (context, _) => Consumer(
        builder: (context, ref, _) {
          final id = selected.value;
          final trackerInfo = id == null
              ? null
              : ref.watch(requestsProvider.select((log) => log[id]));
          return Scaffold(
            titleWidget: Semantics(
              header: true,
              label: title,
              child: const SizedBox.shrink(),
            ),
            iconActions: [
              if (onStep != null) ...[
                IconButtonData(
                  glyph: AppGlyphs.chevronUp,
                  tooltip: appLocalizations.previousItem,
                  onPressed: canStep(-1) ? () => onStep(-1) : null,
                ),
                IconButtonData(
                  glyph: AppGlyphs.chevronDown,
                  tooltip: appLocalizations.nextItem,
                  onPressed: canStep(1) ? () => onStep(1) : null,
                ),
              ],
            ],
            menuItems: trackerInfo == null
                ? const []
                : trackerInfoMenuItems(
                    context,
                    trackerInfo,
                    actions: actions,
                    inDetail: true,
                  ),
            body: trackerInfo == null
                ? const SizedBox.shrink()
                : TrackerInfoDetailView(
                    key: ValueKey(trackerInfo.id),
                    trackerInfo: trackerInfo,
                    header: TrackerInfoHeader(
                      trackerInfo: trackerInfo,
                      compact: true,
                    ),
                    compact: true,
                  ),
          );
        },
      ),
    );
  }
}
