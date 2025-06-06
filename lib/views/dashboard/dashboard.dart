import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  dispose() {
    _isEditNotifier.dispose();
    _addedWidgetsNotifier.dispose();
    super.dispose();
  }

  Widget _buildIsEdit(_IsEditWidgetBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _isEditNotifier,
      builder: (_, isEdit, ___) {
        return builder(isEdit);
      },
    );
  }

  List<Widget> _buildActions() {
    return [
      _buildIsEdit((isEdit) {
        return isEdit
            ? ValueListenableBuilder(
                valueListenable: _addedWidgetsNotifier,
                builder: (_, addedChildren, child) {
                  if (addedChildren.isEmpty) {
                    return Container();
                  }
                  return child!;
                },
                child: IconButton(
                  onPressed: () {
                    _showAddWidgetsModal();
                  },
                  icon: Icon(
                    Icons.add_circle,
                  ),
                ),
              )
            : SizedBox();
      }),
      IconButton(
        icon: _buildIsEdit((isEdit) {
          return isEdit
              ? Icon(Icons.save)
              : Icon(
                  Icons.edit,
                );
        }),
        onPressed: _handleUpdateIsEdit,
      ),
    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_, type) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, __) {
            return AdaptiveSheetScaffold(
              type: type,
              body: _AddDashboardWidgetModal(
                items: value,
                onAdd: (gridItem) {
                  key.currentState?.handleAdd(gridItem);
                },
              ),
              title: appLocalizations.add,
            );
          },
        );
      },
      context: context,
    );
  }

  void _handleUpdateIsEdit() {
    if (_isEditNotifier.value == true) {
      _handleSave();
    }
    _isEditNotifier.value = !_isEditNotifier.value;
  }

  void _handleSave() {
    final children = key.currentState?.children;
    if (children == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardWidgets = children
          .map(
            (item) => DashboardWidget.getDashboardWidget(item),
          )
          .toList();
      ref.read(appSettingProvider.notifier).updateState(
            (state) => state.copyWith(dashboardWidgets: dashboardWidgets),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final columns = max(4 * ((dashboardState.viewWidth / 320).ceil()), 8);
    final spacing = 16.ap;
    final children = [
      ...dashboardState.dashboardWidgets
          .where(
            (item) => item.platforms.contains(
              SupportPlatform.currentPlatform,
            ),
          )
          .map(
            (item) => item.widget,
          ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addedWidgetsNotifier.value = DashboardWidget.values
          .where(
            (item) =>
                !children.contains(item.widget) &&
                item.platforms.contains(
                  SupportPlatform.currentPlatform,
                ),
          )
          .map((item) => item.widget)
          .toList();
    });
    return CommonScaffold(
      title: appLocalizations.dashboard,
      actions: _buildActions(),
      floatingActionButton: const StartButton(),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(16).copyWith(
              bottom: 88,
            ),
            child: _buildIsEdit((isEdit) {
              return isEdit
                  ? SystemBackBlock(
                      child: CommonPopScope(
                        child: SuperGrid(
                          key: key,
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          children: [
                            ...dashboardState.dashboardWidgets
                                .where(
                                  (item) => item.platforms.contains(
                                    SupportPlatform.currentPlatform,
                                  ),
                                )
                                .map(
                                  (item) => item.widget,
                                ),
                          ],
                          onUpdate: () {
                            _handleSave();
                          },
                        ),
                        onPop: () {
                          _handleUpdateIsEdit();
                          return false;
                        },
                      ),
                    )
                  : Grid(
                      crossAxisCount: columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      children: children,
                    );
            })),
      ),
    );
  }
}

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final Function(GridItem item) onAdd;

  const _AddDashboardWidgetModal({
    required this.items,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          16,
        ),
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: () {
                        onAdd(item);
                      },
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

class _AddedContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onAdd;

  const _AddedContainer({
    required this.child,
    required this.onAdd,
  });

  @override
  State<_AddedContainer> createState() => _AddedContainerState();
}

class _AddedContainerState extends State<_AddedContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_AddedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {}
  }

  Future<void> _handleAdd() async {
    widget.onAdd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(
          child: widget.child,
        ),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton.filled(
                iconSize: 20,
                padding: EdgeInsets.all(2),
                onPressed: _handleAdd,
                icon: Icon(
                  Icons.add,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
