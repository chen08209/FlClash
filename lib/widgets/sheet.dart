import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'side_sheet.dart';

showExtendPage(
  BuildContext context, {
  required Widget body,
  required String title,
  double? extendPageWidth,
  bool isScaffold = false,
  bool isBlur = true,
  Widget? action,
}) {
  final NavigatorState navigator = Navigator.of(context);
  final globalKey = GlobalKey();
  final uniqueBody = Container(
    key: globalKey,
    child: body,
  );
  final isMobile =
      globalState.appController.appState.viewMode == ViewMode.mobile;
  if (isMobile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommonScaffold(
          title: title,
          body: uniqueBody,
        ),
      ),
    );
    return;
  }
  final isNotSide = isMobile || isScaffold;
  navigator.push(
    ModalSideSheetRoute(
      modalBarrierColor: Colors.black38,
      builder: (context) {
        final commonScaffold = CommonScaffold(
          automaticallyImplyLeading: isNotSide,
          actions: isNotSide
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
        return SizedBox(
          width: isMobile ? context.width : extendPageWidth ?? 300,
          child: commonScaffold,
        );
      },
      constraints: const BoxConstraints(),
      filter: isBlur ? filter : null,
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
