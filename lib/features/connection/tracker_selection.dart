import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_rows.dart';
import 'tracker_menu.dart';
import 'tracker_app_well.dart';
import 'tracker_clock.dart';
import 'tracker_texts.dart';
import 'tracker_info_detail.dart';

/// Where a page shows the connection a row opens beside its list, the rows
/// select it here rather than each opening a sheet of its own.
class TrackerSelection extends InheritedWidget {
  final ValueListenable<int?> selected;
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

void showTrackerInfoDetail(
  BuildContext context,
  TrackerInfo trackerInfo,
  String title, {
  bool opensRequests = false,
}) {
  // A connection cleared from the log keeps the state it was last seen in.
  var current = trackerInfo;
  final actions = TrackerMenuScope.of(context);
  showNestedSheet<void>(
    context,
    builder: (_) => TrackerMenuScope(
      actions: actions ?? const TrackerMenuActions(),
      child: DetailSheet(
        title: title,
        menu: Consumer(
          builder: (context, ref, _) => DetailMenuButton(
            items: () => trackerDetailMenuItems(context, ref, current),
          ),
        ),
        child: TrackerClock(
          child: Consumer(
            builder: (context, ref, _) {
              current =
                  ref.watch(
                    requestsProvider.select((log) => log[trackerInfo.id]),
                  ) ??
                  current;
              return TrackerInfoDetailView(
                trackerInfo: current,
                opensRequests: opensRequests,
                header: TrackerInfoHeader(
                  trackerInfo: current,
                  showsMenu: false,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
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
  final int id;
  final Widget Function(BuildContext context, bool selected) builder;

  const TrackerSelected({super.key, required this.id, required this.builder});

  @override
  State<TrackerSelected> createState() => _TrackerSelectedState();
}

class _TrackerSelectedState extends State<TrackerSelected> {
  ValueListenable<int?>? _selected;
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

class TrackerInfoHeader extends ConsumerWidget {
  final TrackerInfo trackerInfo;

  /// Off where a sheet's bar holds the menu.
  final bool showsMenu;

  const TrackerInfoHeader({
    super.key,
    required this.trackerInfo,
    this.showsMenu = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final close = TrackerMenuScope.of(context)?.close;
    return DetailHeader(
      well: (size) => TrackerAppWell(trackerInfo: trackerInfo, size: size),
      title: trackerInfo.title,
      subtitle: TrackerLifetime(
        trackerInfo: trackerInfo,
        builder: (lifetime) => Text.rich(
          TextSpan(
            children: [
              for (final (index, part) in trackerHeadlineParts(
                appLocalizations,
                trackerInfo,
                lifetime,
              ).indexed) ...[
                if (index > 0) const TextSpan(text: ' · '),
                TextSpan(
                  text: part.text,
                  style: part.failed
                      ? TextStyle(color: context.colorScheme.error)
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (close != null && trackerInfo.isActive)
          AppBarActionButton(
            data: IconButtonData(
              glyph: AppGlyphs.block,
              tooltip: appLocalizations.closeConnection,
              onPressed: () => close(trackerInfo),
            ),
            icon: GlyphIcon(AppGlyphs.block, color: context.colorScheme.error),
          ),
        if (showsMenu)
          DetailMenuButton(
            items: () => trackerDetailMenuItems(context, ref, trackerInfo),
          ),
      ],
    );
  }
}

/// The detail of the selected connection, while the log or [rows] hold it.
class TrackerSelectedDetail extends StatelessWidget {
  final ValueListenable<int?> selected;
  final ConnectionRows rows;

  /// Read out rather than shown.
  final String title;

  const TrackerSelectedDetail({
    super.key,
    required this.selected,
    required this.rows,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      explicitChildNodes: true,
      child: ValueListenableBuilder(
        valueListenable: selected,
        builder: (context, id, _) => Consumer(
          builder: (context, ref, _) {
            if (id == null) {
              return const SizedBox.shrink();
            }
            final trackerInfo = ref.watch(
              requestsProvider.select((log) => log[id]),
            );
            if (trackerInfo != null) {
              return _detail(trackerInfo);
            }
            return ListenableBuilder(
              listenable: rows,
              builder: (context, _) => switch (rows.heldInfoOf(id)) {
                final trackerInfo? => _detail(trackerInfo),
                null => const SizedBox.shrink(),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _detail(TrackerInfo trackerInfo) => DetailPane(
    key: ValueKey(trackerInfo.id),
    child: TrackerInfoDetailView(
      trackerInfo: trackerInfo,
      header: TrackerInfoHeader(trackerInfo: trackerInfo),
    ),
  );
}

/// The selected connection in a side sheet.
class TrackerInfoDetailSheet extends StatelessWidget {
  final ValueListenable<int?> selected;
  final ConnectionRows rows;

  /// Read out rather than shown.
  final String title;

  const TrackerInfoDetailSheet({
    super.key,
    required this.selected,
    required this.rows,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => TopInsetScope(
    inset: MediaQuery.paddingOf(context).top + 16,
    child: TrackerSelectedDetail(selected: selected, rows: rows, title: title),
  );
}
