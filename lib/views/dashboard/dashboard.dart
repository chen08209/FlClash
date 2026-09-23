import 'package:defer_pointer/defer_pointer.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widget_metrics.dart';
import 'widget_registry.dart';
import 'widgets/core_status_button.dart';
import 'widgets/start_button.dart';

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final key = GlobalKey<SuperGridState>();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _addedWidgetsNotifier = ValueNotifier<List<GridItem>>([]);

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      dashboardStateProvider.select((state) => state.dashboardWidgets),
      (_, dashboardWidgets) => _syncAddedWidgets(dashboardWidgets),
      fireImmediately: true,
    );
  }

  void _syncAddedWidgets(List<DashboardWidget> dashboardWidgets) {
    bool onThisPlatform(DashboardWidget item) =>
        item.platforms.contains(SupportPlatform.currentPlatform);
    final shown = dashboardWidgets
        .where(onThisPlatform)
        .map((item) => item.widget)
        .toSet();
    _addedWidgetsNotifier.value = DashboardWidget.values
        .where((item) => onThisPlatform(item) && !shown.contains(item.widget))
        .map((item) => item.widget)
        .toList();
  }

  @override
  void dispose() {
    _isEditNotifier.dispose();
    _addedWidgetsNotifier.dispose();
    super.dispose();
  }

  Widget _buildIsEdit(_IsEditWidgetBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _isEditNotifier,
      builder: (_, isEdit, _) {
        return builder(isEdit);
      },
    );
  }

  List<Widget> _buildActions(bool isEdit) {
    return [
      if (!isEdit && coreLib == null) const CoreStatusButton(),
      if (isEdit)
        ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, addedChildren, child) {
            if (addedChildren.isEmpty) {
              return Container();
            }
            return child!;
          },
          child: IconButton(
            tooltip: context.appLocalizations.addWidget,
            onPressed: () {
              _showAddWidgetsModal();
            },
            icon: const GlyphIcon(AppGlyphs.addCircle),
          ),
        ),
      FadeRotationScaleBox(
        child: isEdit
            ? IconButton(
                tooltip: context.appLocalizations.save,
                key: const ValueKey(true),
                icon: const GlyphIcon(
                  AppGlyphs.save,
                  key: ValueKey('save-icon'),
                ),
                onPressed: _handleExitEdit,
              )
            : IconButton(
                tooltip: context.appLocalizations.edit,
                key: const ValueKey(false),
                icon: const GlyphIcon(
                  AppGlyphs.edit,
                  key: ValueKey('edit-icon'),
                ),
                onPressed: _handleEnterEdit,
              ),
      ),
    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, _) {
            return CommonScaffold(
              body: _AddDashboardWidgetModal(
                items: value,
                onAdd: (gridItem, from) {
                  key.currentState?.addItem(gridItem, from: from);
                },
              ),
              title: context.appLocalizations.add,
            );
          },
        );
      },
      context: context,
    );
  }

  void _handleEnterEdit() {
    _isEditNotifier.value = true;
  }

  void _handleExitEdit() {
    _isEditNotifier.value = false;
  }

  void _saveDashboardWidgets(List<GridItem> items) {
    final dashboardWidgets = items.map(dashboardWidgetOf).toList();
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(dashboardWidgets: dashboardWidgets));
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final spacing = 14.mAp;
    final children = [
      ...dashboardState.dashboardWidgets
          .where(
            (item) => item.platforms.contains(SupportPlatform.currentPlatform),
          )
          .map((item) => item.widget),
    ];
    return _buildIsEdit(
      (isEdit) => CommonScaffold(
        title: context.appLocalizations.dashboard,
        actions: _buildActions(isEdit),
        floatingActionButton: hasProfile ? const StartButton() : null,
        body: Align(
          alignment: Alignment.topCenter,
          child: Builder(
            builder: (context) => SingleChildScrollView(
              padding: const EdgeInsets.all(16).copyWith(
                top: context.contentTopPadding,
                bottom: 16 + BottomInsetScope.of(context),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: dashboardMaxGridWidth),
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final band = DashboardGridBand.of(constraints.maxWidth);
                      final columns = band.columns;
                      final grid = SuperGrid(
                        key: key,
                        editing: isEdit,
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        onChanged: _saveDashboardWidgets,
                        children: children,
                      );
                      return DashboardWidgetMetrics(
                        unitHeight: dashboardUnitHeight(constraints.maxWidth),
                        child: isEdit
                            ? BackLayerScope(
                                onBack: _handleExitEdit,
                                child: grid,
                              )
                            : grid,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef _AddCallback = void Function(GridItem item, Rect from);

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final _AddCallback onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(top: context.contentTopPadding),
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: (from) => onAdd(item, from),
                      child: child,
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _AddedContainer extends StatelessWidget {
  final Widget child;
  final ValueChanged<Rect> onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  void _handleAdd(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final from = box.localToGlobal(Offset.zero) & box.size;
    Navigator.of(context).pop();
    onAdd(from);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: child),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: ElasticButton(
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton.filled(
                  tooltip: context.appLocalizations.add,
                  iconSize: 20,
                  padding: const EdgeInsets.all(2),
                  onPressed: () => _handleAdd(context),
                  icon: const GlyphIcon(AppGlyphs.add, fill: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
