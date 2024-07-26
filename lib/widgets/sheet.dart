import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'side_sheet.dart';

showExtendPage(
  BuildContext context, {
  required Widget body,
  required String title,
  double? extendPageWidth,
  Widget? action,
}) {
  final NavigatorState navigator = Navigator.of(context);
  final globalKey = GlobalKey();
  final uniqueBody = Container(
    key: globalKey,
    child: body,
  );
  navigator.push(
    ModalSideSheetRoute(
      modalBarrierColor: Colors.black38,
      builder: (context) => Selector<AppState, double>(
        selector: (_, appState) => appState.viewWidth,
        builder: (_, viewWidth, __) {
          final isMobile =
              globalState.appController.appState.viewMode == ViewMode.mobile;
          final commonScaffold = CommonScaffold(
            automaticallyImplyLeading: isMobile ? true : false,
            actions: isMobile
                ? null
                : [
                    const SizedBox(
                      height: kToolbarHeight,
                      width: kToolbarHeight,
                      child: CloseButton(),
                    ),
                  ],
            title: title,
            body: uniqueBody,
          );
          return AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: isMobile ? viewWidth : extendPageWidth ?? 300,
            child: commonScaffold,
          );
        },
      ),
      constraints: const BoxConstraints(),
      filter: filter,
    ),
  );
}

showSheet({
  required BuildContext context,
  required WidgetBuilder builder,
  required String title,
  bool isScrollControlled = true,
  double width = 320,
}) {
  final viewMode = globalState.appController.appState.viewMode;
  final isMobile = viewMode == ViewMode.mobile;
  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: (context) {
        return SafeArea(
          child: builder(
            context,
          ),
        );
      },
      showDragHandle: true,
      useSafeArea: true,
    );
  } else {
    showModalSideSheet(
      useSafeArea: true,
      isScrollControlled: isScrollControlled,
      context: context,
      constraints: BoxConstraints(
        maxWidth: width,
      ),
      body: SafeArea(
        child: builder(context),
      ),
      title: title,
    );
  }
}
