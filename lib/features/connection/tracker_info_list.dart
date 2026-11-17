import 'package:fl_clash/models/models.dart';
import 'package:flutter/widgets.dart';

import 'connection_rows.dart';
import 'tracker_info_item.dart';

/// A connection's row in [rows], built again only when its details change.
Widget Function(int id) trackerInfoRows(
  ConnectionRows rows, {
  required String detailTitle,
  ValueChanged<TrackerInfo>? onClose,
}) =>
    (id) => _TrackerInfoRow(
      rows: rows,
      id: id,
      details: rows.detailsOf(id),
      detailTitle: detailTitle,
      onClose: onClose,
    );

class _TrackerInfoRow extends StatefulWidget {
  final ConnectionRows rows;
  final int id;
  final TrackerInfo details;
  final String detailTitle;
  final ValueChanged<TrackerInfo>? onClose;

  const _TrackerInfoRow({
    required this.rows,
    required this.id,
    required this.details,
    required this.detailTitle,
    required this.onClose,
  });

  @override
  State<_TrackerInfoRow> createState() => _TrackerInfoRowState();
}

class _TrackerInfoRowState extends State<_TrackerInfoRow> {
  late var _details = widget.details;
  var _due = false;
  Widget? _built;

  @override
  void didUpdateWidget(_TrackerInfoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.detailTitle != oldWidget.detailTitle) {
      _take();
    } else if (identical(widget.details, _details)) {
      return;
    } else if (!widget.rows.staggersDetails) {
      _take();
    } else if (!_due) {
      _due = true;
      widget.rows.later(_takeLater);
    }
  }

  void _take() {
    _details = widget.details;
    _built = null;
  }

  void _takeLater() {
    _due = false;
    if (mounted && !identical(widget.details, _details)) {
      setState(_take);
    }
  }

  @override
  Widget build(BuildContext context) => _built ??= TrackerInfoItem(
    key: ValueKey(widget.id),
    trackerInfo: _details,
    onClose: widget.onClose,
    detailTitle: widget.detailTitle,
    latest: () => widget.rows.heldInfoOf(widget.id) ?? _details,
    traffic: widget.rows.traffic,
  );
}
