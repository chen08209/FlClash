import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
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

  // Flexible(
  //   flex: 0,
  //   child: Row(
  //     children: [
  //       Expanded(
  //         child: Padding(
  //           padding: kTabLabelPadding,
  //           child: Text(
  //             title,
  //             style: Theme.of(context).textTheme.titleMedium,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: kToolbarHeight,
  //         width: kToolbarHeight,
  //         child: CloseButton(),
  //       ),
  //     ],
  //   ),
  // )
  navigator.push(
    ModalSideSheetRoute(
      modalBarrierColor: Colors.black38,
      builder: (context) => LayoutBuilder(
        builder: (_, __) {
          final isMobile = context.isMobile;
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
            title: Text(title),
            body: uniqueBody,
          );
          return AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: isMobile ? context.width : extendPageWidth ?? 300,
            child: commonScaffold,
          );
        },
      ),
      constraints: const BoxConstraints(),
      filter: appConstant.filter,
    ),
  );
}
