import 'package:material_ui/material_ui.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// Estimates the rows a far jump skips; [SliverList] lays out every one.
class SuperSliverReorderableList extends SliverReorderableList {
  const SuperSliverReorderableList({
    super.key,
    required super.itemBuilder,
    required super.itemCount,
    required super.onReorderItem,
    super.proxyDecorator,
  });

  @override
  SliverReorderableListState createState() =>
      _SuperSliverReorderableListState();
}

class _SuperSliverReorderableListState extends SliverReorderableListState {
  @override
  Widget build(BuildContext context) {
    final sliver = super.build(context);
    if (sliver is! SliverList) {
      return sliver;
    }
    return SuperSliverList(delegate: sliver.delegate);
  }
}
