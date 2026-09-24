import 'dart:async';
import 'dart:math';

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

class _DashboardViewState extends ConsumerState<DashboardView>
    with SingleTickerProviderStateMixin {
  final key = GlobalKey<SuperGridState>();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _addedWidgetsNotifier = ValueNotifier<List<GridItem>>([]);
  late final _addSheetController = SnapSheetController(vsync: this);
  int _landingCount = 0;

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
    _addSheetController.dispose();
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
    showSnapSheet(
      context,
      detents: const [0.85],
      collapsedDetent: 0.2,
      controller: _addSheetController,
      builder: (sheetContext, scrollController) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, _) {
            return CommonScaffold(
              body: _AddDashboardWidgetModal(
                items: value,
                scrollController: scrollController,
                onAdd: (gridItem, from) =>
                    _addWidget(sheetContext, gridItem, from),
              ),
              title: context.appLocalizations.add,
            );
          },
        );
      },
    );
  }

  void _addWidget(BuildContext sheetContext, GridItem item, Rect from) {
    final grid = key.currentState;
    if (grid == null) {
      return;
    }
    final isLast = _addedWidgetsNotifier.value.length <= 1;
    if (isLast || !_addSheetController.isAttached) {
      Navigator.of(sheetContext).pop();
      grid.addItem(item, from: from);
      return;
    }
    _addSheetController.collapse();
    _landingCount++;
    unawaited(
      grid.addItem(item, from: from).whenComplete(() {
        if (--_landingCount == 0 && mounted) {
          _addSheetController.restore();
        }
      }),
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
          // SingleChildScrollView snaps a bounce back to its edge whenever a
          // card's refresh relays it out; a sliver viewport keeps the overscroll.
          child: ValueListenableBuilder(
            valueListenable: _addSheetController,
            builder: (context, sheetHeight, _) {
              final padding = const EdgeInsets.all(16).copyWith(
                top: context.contentTopPadding,
                bottom: 16 + max(BottomInsetScope.of(context), sheetHeight),
              );
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: padding,
                    sliver: SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: dashboardMaxGridWidth,
                          ),
                          child: LayoutBuilder(
                            builder: (_, constraints) {
                              final band = DashboardGridBand.of(
                                constraints.maxWidth,
                              );
                              final columns = band.columns;
                              final grid = SuperGrid(
                                key: key,
                                editing: isEdit,
                                crossAxisCount: columns,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                onChanged: _saveDashboardWidgets,
                                revealPadding: padding.copyWith(
                                  left: 0,
                                  right: 0,
                                ),
                                children: children,
                              );
                              return DashboardWidgetMetrics(
                                unitHeight: dashboardUnitHeight(
                                  constraints.maxWidth,
                                ),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

typedef _AddCallback = void Function(GridItem item, Rect from);

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final ScrollController? scrollController;
  final _AddCallback onAdd;

  const _AddDashboardWidgetModal({
    required this.items,
    required this.scrollController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        controller: scrollController,
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
    onAdd(box.localToGlobal(Offset.zero) & box.size);
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
                  iconSize: 16,
                  padding: const EdgeInsets.all(4),
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
