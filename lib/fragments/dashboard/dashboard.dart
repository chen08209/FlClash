import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/start_button.dart';

class DashboardFragment extends ConsumerStatefulWidget {
  const DashboardFragment({super.key});

  @override
  ConsumerState<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends ConsumerState<DashboardFragment>
    with PageMixin {
  final key = GlobalKey<SuperGridState>();

  @override
  initState() {
    ref.listenManual(
      isCurrentPageProvider(PageLabel.dashboard),
      (prev, next) {
        if (prev != next && next == true) {
          initPageState();
        }
      },
      fireImmediately: true,
    );
    return super.initState();
  }

  @override
  Widget? get floatingActionButton => const StartButton();

  @override
  List<Widget> get actions => [
        ValueListenableBuilder(
          valueListenable: key.currentState!.addedChildrenNotifier,
          builder: (_, addedChildren, child) {
            return ValueListenableBuilder(
              valueListenable: key.currentState!.isEditNotifier,
              builder: (_, isEdit, child) {
                if (!isEdit || addedChildren.isEmpty) {
                  return Container();
                }
                return child!;
              },
              child: child,
            );
          },
          child: IconButton(
            onPressed: () {
              key.currentState!.showAddModal();
            },
            icon: Icon(
              Icons.add_circle,
            ),
          ),
        ),
        IconButton(
          icon: ValueListenableBuilder(
            valueListenable: key.currentState!.isEditNotifier,
            builder: (_, isEdit, ___) {
              return isEdit
                  ? Icon(Icons.save)
                  : Icon(
                      Icons.edit,
                    );
            },
          ),
          onPressed: () {
            key.currentState!.isEditNotifier.value =
                !key.currentState!.isEditNotifier.value;
          },
        ),
      ];

  _handleSave(List<GridItem> girdItems, WidgetRef ref) {
    final dashboardWidgets = girdItems
        .map(
          (item) => DashboardWidget.getDashboardWidget(item),
        )
        .toList();
    ref.read(appSettingProvider.notifier).updateState(
          (state) => state.copyWith(dashboardWidgets: dashboardWidgets),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final columns = max(4 * ((dashboardState.viewWidth / 320).ceil()), 8);
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16).copyWith(
          bottom: 88,
        ),
        child: SuperGrid(
          key: key,
          crossAxisCount: columns,
          crossAxisSpacing: 16.ap,
          mainAxisSpacing: 16.ap,
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
          onSave: (girdItems) {
            _handleSave(girdItems, ref);
          },
          addedItemsBuilder: (girdItems) {
            return DashboardWidget.values
                .where(
                  (item) =>
                      !girdItems.contains(item.widget) &&
                      item.platforms.contains(
                        SupportPlatform.currentPlatform,
                      ),
                )
                .map((item) => item.widget)
                .toList();
          },
        ),
      ),
    );
  }
}
