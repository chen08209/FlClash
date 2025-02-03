import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/start_button.dart';

class DashboardFragment extends StatefulWidget {
  const DashboardFragment({super.key});

  @override
  State<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  final key = GlobalKey<SuperGridState>();

  _initScaffold(bool isCurrent) {
    if (!isCurrent) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commonScaffoldState = context.commonScaffoldState;
      commonScaffoldState?.floatingActionButton = const StartButton();
      commonScaffoldState?.actions = [
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActiveBuilder(
      label: "dashboard",
      builder: (isCurrent, child) {
        _initScaffold(isCurrent);
        return child!;
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(
            bottom: 88,
          ),
          child: Selector2<AppState, Config, DashboardState>(
            selector: (_, appState, config) => DashboardState(
              dashboardWidgets: config.appSetting.dashboardWidgets,
              viewWidth: appState.viewWidth,
            ),
            builder: (_, state, ___) {
              final columns = max(4 * ((state.viewWidth / 350).ceil()), 8);
              return SuperGrid(
                key: key,
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ...state.dashboardWidgets
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
                  final dashboardWidgets = girdItems
                      .map(
                        (item) => DashboardWidget.getDashboardWidget(item),
                      )
                      .toList();
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    dashboardWidgets: dashboardWidgets,
                  );
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
              );
            },
          ),
        ),
      ),
    );
  }
}
