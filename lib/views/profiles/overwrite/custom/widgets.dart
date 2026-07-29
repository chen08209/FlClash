import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class InfoMessageButton extends StatelessWidget {
  final String message;

  const InfoMessageButton({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return CommonMinIconButtonTheme(
      child: IconButton(
        onPressed: () {
          globalState.showMessage(message: TextSpan(text: message));
        },
        icon: Icon(Icons.info, size: 20.ap, color: context.colorScheme.error),
      ),
    );
  }
}

Widget fadeAndSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInExpo).animate(animation),
    child: FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.1)
          .chain(CurveTween(curve: Curves.easeOutExpo))
          .animate(secondaryAnimation),
      child: const FadeForwardsPageTransitionsBuilder().buildTransitions(
        ModalRoute.of(context) as PageRoute,
        context,
        animation,
        secondaryAnimation,
        child,
      ),
    ),
  );
}
