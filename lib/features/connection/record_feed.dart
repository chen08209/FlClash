import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A segment's records, oldest first, what the search keeps of them, and
/// whether its list follows the newest.
class RecordFeed<T> extends ChangeNotifier {
  final List<String> Function(T item) _searchFieldsOf;
  var _items = <T>[];
  var _query = '';
  var _following = true;
  var _hovered = false;
  List<T>? _shown;

  RecordFeed(this._searchFieldsOf);

  List<T> get items => _items;

  @protected
  set items(List<T> items) {
    if (identical(items, _items)) {
      return;
    }
    _items = items;
    _shown = null;
    notifyListeners();
  }

  bool get isSearching => SearchQuery(_query).isNotEmpty;

  List<T> get shown => _shown ??= isSearching
      ? _items.whereMatches(SearchQuery(_query), _searchFieldsOf).toList()
      : _items;

  void search(String query) {
    if (query == _query) {
      return;
    }
    _query = query;
    _shown = null;
    notifyListeners();
  }

  bool get following => _following;

  set following(bool following) {
    if (following == _following) {
      return;
    }
    final held = holdsNew;
    _following = following;
    _holdChanged(held);
    notifyListeners();
  }

  /// Whether new records wait to go in: while the pointer rests on a list
  /// that follows the newest, so a row does not move out from under it.
  bool get holdsNew => _hovered && _following;

  set hovered(bool hovered) {
    if (hovered == _hovered) {
      return;
    }
    final held = holdsNew;
    _hovered = hovered;
    _holdChanged(held);
  }

  void _holdChanged(bool held) {
    if (held != holdsNew) {
      held ? release() : hold();
    }
  }

  @protected
  void hold() {}

  @protected
  void release() {}
}

/// A segment's list under the minute each record started in: its empty
/// state, the scrollbar with a time hint, and following the newest.
class RecordFeedView<T> extends StatefulWidget {
  final MinuteRows<T> rows;
  final bool isEmpty;
  final bool isSearching;
  final NullStatus nullStatus;
  final ScrollController controller;
  final DateTime? Function(double fraction) timeAt;
  final bool following;
  final VoidCallback onStopFollowing;
  final VoidCallback onFollow;

  /// Whether the pointer rests on a list with records in it, told on desktop.
  final ValueChanged<bool> onHover;
  final Widget Function(T item) itemBuilder;

  const RecordFeedView({
    super.key,
    required this.rows,
    required this.isEmpty,
    required this.isSearching,
    required this.nullStatus,
    required this.controller,
    required this.timeAt,
    required this.following,
    required this.onStopFollowing,
    required this.onFollow,
    required this.onHover,
    required this.itemBuilder,
  });

  @override
  State<RecordFeedView<T>> createState() => _RecordFeedViewState<T>();
}

class _RecordFeedViewState<T> extends State<RecordFeedView<T>> {
  late final _physics = FollowEndScrollPhysics(
    isFollowing: () => widget.following,
  );
  var _pointerIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = widget.controller;
      if (mounted &&
          !widget.following &&
          controller.hasClients &&
          FollowEndScrollPhysics.isAtEnd(controller.position)) {
        widget.onFollow();
      }
    });
  }

  @override
  void didUpdateWidget(RecordFeedView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pointerIn && widget.isEmpty != oldWidget.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tellHover();
        }
      });
    }
  }

  void _setPointerIn(bool pointerIn) {
    _pointerIn = pointerIn;
    _tellHover();
  }

  void _tellHover() => widget.onHover(_pointerIn && !widget.isEmpty);

  @override
  Widget build(BuildContext context) {
    final list = NullStatusSwitcher(
      isEmpty: widget.isEmpty,
      isSearching: widget.isSearching,
      nullStatus: widget.nullStatus,
      child: FloatingScrollbar(
        controller: widget.controller,
        hintBuilder: (fraction) => widget.timeAt(fraction)?.showFull ?? '',
        child: ScrollToEndBox(
          controller: widget.controller,
          enable: widget.following,
          onCancelToEnd: widget.onStopFollowing,
          onResumeToEnd: widget.onFollow,
          child: RecordMinuteList<T>(
            rows: widget.rows,
            physics: _physics,
            controller: widget.controller,
            padding: context.listInsets.page(bottom: 16 + context.bottomInset),
            itemBuilder: widget.itemBuilder,
          ),
        ),
      ),
    );
    if (!isDesktopPlatform) {
      return list;
    }
    return MouseRegion(
      onEnter: (_) => _setPointerIn(true),
      onExit: (_) => _setPointerIn(false),
      child: list,
    );
  }
}

/// The record at [fraction] of [items], for a scrollbar's hint.
T recordAtFraction<T>(List<T> items, double fraction) =>
    items[(fraction * (items.length - 1)).round()];

/// Builds [builder] with whether [selected] holds this row's record.
class RecordSelected<T> extends StatefulWidget {
  final ValueListenable<T?> selected;
  final bool Function(T? selected) holds;
  final Widget Function(BuildContext context, bool selected) builder;

  const RecordSelected({
    super.key,
    required this.selected,
    required this.holds,
    required this.builder,
  });

  @override
  State<RecordSelected<T>> createState() => _RecordSelectedState<T>();
}

class _RecordSelectedState<T> extends State<RecordSelected<T>> {
  late var _isSelected = widget.holds(widget.selected.value);

  @override
  void initState() {
    super.initState();
    widget.selected.addListener(_handleSelected);
  }

  @override
  void didUpdateWidget(RecordSelected<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      oldWidget.selected.removeListener(_handleSelected);
      widget.selected.addListener(_handleSelected);
    }
    _isSelected = widget.holds(widget.selected.value);
  }

  @override
  void dispose() {
    widget.selected.removeListener(_handleSelected);
    super.dispose();
  }

  void _handleSelected() {
    final isSelected = widget.holds(widget.selected.value);
    if (isSelected == _isSelected) {
      return;
    }
    setState(() => _isSelected = isSelected);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isSelected);
}
